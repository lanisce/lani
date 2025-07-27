# frozen_string_literal: true

# CacheService provides centralized caching strategies for the Lani platform
# Implements multi-level caching with Redis backend and intelligent cache invalidation
class CacheService
  include Singleton

  # Cache key prefixes for different data types
  PREFIXES = {
    project: 'project',
    task: 'task',
    user: 'user',
    budget: 'budget',
    transaction: 'transaction',
    report: 'report',
    api: 'api',
    session: 'session'
  }.freeze

  # Default cache expiration times
  EXPIRATION_TIMES = {
    short: 5.minutes,
    medium: 1.hour,
    long: 24.hours,
    permanent: 1.week
  }.freeze

  class << self
    delegate :fetch, :read, :write, :delete, :exist?, :clear, to: :instance
  end

  def initialize
    @cache = Rails.cache
  end

  # Fetch data with caching, using block for cache miss
  def fetch(key, expires_in: EXPIRATION_TIMES[:medium], **options, &block)
    cache_key = normalize_key(key)
    
    @cache.fetch(cache_key, expires_in: expires_in, **options) do
      result = block.call if block_given?
      log_cache_operation(:write, cache_key, result)
      result
    end
  rescue => e
    Rails.logger.error "Cache fetch error for key #{cache_key}: #{e.message}"
    block.call if block_given?
  end

  # Read from cache
  def read(key)
    cache_key = normalize_key(key)
    result = @cache.read(cache_key)
    log_cache_operation(:read, cache_key, result)
    result
  rescue => e
    Rails.logger.error "Cache read error for key #{cache_key}: #{e.message}"
    nil
  end

  # Write to cache
  def write(key, value, expires_in: EXPIRATION_TIMES[:medium], **options)
    cache_key = normalize_key(key)
    success = @cache.write(cache_key, value, expires_in: expires_in, **options)
    log_cache_operation(:write, cache_key, value) if success
    success
  rescue => e
    Rails.logger.error "Cache write error for key #{cache_key}: #{e.message}"
    false
  end

  # Delete from cache
  def delete(key)
    cache_key = normalize_key(key)
    success = @cache.delete(cache_key)
    log_cache_operation(:delete, cache_key) if success
    success
  rescue => e
    Rails.logger.error "Cache delete error for key #{cache_key}: #{e.message}"
    false
  end

  # Check if key exists in cache
  def exist?(key)
    cache_key = normalize_key(key)
    @cache.exist?(cache_key)
  rescue => e
    Rails.logger.error "Cache exist check error for key #{cache_key}: #{e.message}"
    false
  end

  # Clear all cache or specific pattern
  def clear(pattern = nil)
    if pattern
      delete_matched(pattern)
    else
      @cache.clear
    end
  rescue => e
    Rails.logger.error "Cache clear error: #{e.message}"
    false
  end

  # Project-specific caching methods
  def cache_project(project)
    key = project_key(project.id)
    write(key, project.as_json(include: [:tasks, :project_memberships]), expires_in: EXPIRATION_TIMES[:long])
  end

  def fetch_project(project_id)
    key = project_key(project_id)
    fetch(key, expires_in: EXPIRATION_TIMES[:long]) do
      Project.includes(:tasks, :project_memberships).find(project_id).as_json
    end
  end

  def invalidate_project(project_id)
    delete(project_key(project_id))
    delete_matched("#{PREFIXES[:project]}:#{project_id}:*")
    invalidate_user_projects_for_project(project_id)
  end

  # Task-specific caching methods
  def cache_task(task)
    key = task_key(task.id)
    write(key, task.as_json, expires_in: EXPIRATION_TIMES[:medium])
  end

  def fetch_task(task_id)
    key = task_key(task_id)
    fetch(key, expires_in: EXPIRATION_TIMES[:medium]) do
      Task.find(task_id).as_json
    end
  end

  def invalidate_task(task_id, project_id = nil)
    delete(task_key(task_id))
    invalidate_project(project_id) if project_id
  end

  # User-specific caching methods
  def cache_user_projects(user_id, projects)
    key = user_projects_key(user_id)
    write(key, projects.as_json, expires_in: EXPIRATION_TIMES[:medium])
  end

  def fetch_user_projects(user_id)
    key = user_projects_key(user_id)
    fetch(key, expires_in: EXPIRATION_TIMES[:medium]) do
      User.find(user_id).projects.includes(:project_memberships).as_json
    end
  end

  def invalidate_user_projects(user_id)
    delete(user_projects_key(user_id))
  end

  # Report caching methods
  def cache_report(report_type, params, data)
    key = report_key(report_type, params)
    write(key, data, expires_in: EXPIRATION_TIMES[:short])
  end

  def fetch_report(report_type, params)
    key = report_key(report_type, params)
    read(key)
  end

  def invalidate_reports
    delete_matched("#{PREFIXES[:report]}:*")
  end

  # API response caching methods
  def cache_api_response(endpoint, params, response)
    key = api_key(endpoint, params)
    write(key, response, expires_in: EXPIRATION_TIMES[:short])
  end

  def fetch_api_response(endpoint, params)
    key = api_key(endpoint, params)
    read(key)
  end

  def invalidate_api_cache(endpoint = nil)
    if endpoint
      delete_matched("#{PREFIXES[:api]}:#{endpoint}:*")
    else
      delete_matched("#{PREFIXES[:api]}:*")
    end
  end

  # Session caching methods
  def cache_session_data(session_id, data)
    key = session_key(session_id)
    write(key, data, expires_in: EXPIRATION_TIMES[:medium])
  end

  def fetch_session_data(session_id)
    key = session_key(session_id)
    read(key)
  end

  def invalidate_session(session_id)
    delete(session_key(session_id))
  end

  # Cache warming methods
  def warm_cache_for_user(user)
    # Pre-load frequently accessed data
    fetch_user_projects(user.id)
    
    user.projects.find_each do |project|
      fetch_project(project.id)
    end
  end

  def warm_cache_for_project(project)
    cache_project(project)
    
    project.tasks.find_each do |task|
      cache_task(task)
    end
  end

  # Cache statistics
  def cache_stats
    {
      redis_info: redis_info,
      cache_size: cache_size,
      hit_rate: calculate_hit_rate
    }
  end

  private

  def normalize_key(key)
    case key
    when String
      key
    when Array
      key.join(':')
    when Hash
      key.map { |k, v| "#{k}=#{v}" }.join(':')
    else
      key.to_s
    end
  end

  def project_key(project_id)
    "#{PREFIXES[:project]}:#{project_id}"
  end

  def task_key(task_id)
    "#{PREFIXES[:task]}:#{task_id}"
  end

  def user_projects_key(user_id)
    "#{PREFIXES[:user]}:#{user_id}:projects"
  end

  def report_key(report_type, params)
    param_hash = Digest::MD5.hexdigest(params.to_json)
    "#{PREFIXES[:report]}:#{report_type}:#{param_hash}"
  end

  def api_key(endpoint, params)
    param_hash = Digest::MD5.hexdigest(params.to_json)
    "#{PREFIXES[:api]}:#{endpoint}:#{param_hash}"
  end

  def session_key(session_id)
    "#{PREFIXES[:session]}:#{session_id}"
  end

  def delete_matched(pattern)
    if @cache.respond_to?(:delete_matched)
      @cache.delete_matched(pattern)
    else
      # Fallback for cache stores that don't support pattern deletion
      Rails.logger.warn "Cache store doesn't support pattern deletion: #{pattern}"
    end
  end

  def invalidate_user_projects_for_project(project_id)
    # Find all users associated with the project and invalidate their project cache
    project = Project.find_by(id: project_id)
    return unless project

    project.users.find_each do |user|
      invalidate_user_projects(user.id)
    end
  end

  def log_cache_operation(operation, key, value = nil)
    return unless Rails.env.development?

    case operation
    when :read
      Rails.logger.debug "Cache READ: #{key} #{value ? 'HIT' : 'MISS'}"
    when :write
      Rails.logger.debug "Cache WRITE: #{key}"
    when :delete
      Rails.logger.debug "Cache DELETE: #{key}"
    end
  end

  def redis_info
    return {} unless @cache.is_a?(ActiveSupport::Cache::RedisCacheStore)

    @cache.redis.info
  rescue => e
    Rails.logger.error "Error getting Redis info: #{e.message}"
    {}
  end

  def cache_size
    return 0 unless @cache.is_a?(ActiveSupport::Cache::RedisCacheStore)

    @cache.redis.dbsize
  rescue => e
    Rails.logger.error "Error getting cache size: #{e.message}"
    0
  end

  def calculate_hit_rate
    # This would require implementing hit/miss tracking
    # For now, return a placeholder
    0.0
  end
end
