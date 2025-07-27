# frozen_string_literal: true

# PerformanceOptimized concern provides caching and performance monitoring
# capabilities for controllers in the Lani platform
module PerformanceOptimized
  extend ActiveSupport::Concern

  included do
    before_action :start_performance_monitoring
    after_action :log_performance_metrics
    around_action :with_performance_monitoring
  end

  class_methods do
    # Configure caching for specific actions
    def cache_action(action_name, expires_in: 1.hour, vary_by: [], if: nil, unless: nil)
      before_action(only: action_name) do
        @cache_config = {
          expires_in: expires_in,
          vary_by: vary_by,
          if: binding.local_variable_get(:if),
          unless: binding.local_variable_get(:unless)
        }
      end
    end

    # Configure fragment caching for views
    def cache_fragments(*fragment_names, expires_in: 1.hour)
      before_action do
        @fragment_cache_config = {
          fragments: fragment_names,
          expires_in: expires_in
        }
      end
    end
  end

  private

  def start_performance_monitoring
    @performance_start_time = Time.current
    @performance_metrics = {
      controller: self.class.name,
      action: action_name,
      start_time: @performance_start_time,
      user_id: current_user&.id,
      request_id: request.request_id
    }
  end

  def with_performance_monitoring
    ActiveSupport::Notifications.instrument('controller.performance', @performance_metrics) do
      yield
    end
  end

  def log_performance_metrics
    return unless @performance_start_time

    duration = (Time.current - @performance_start_time) * 1000 # Convert to milliseconds
    
    @performance_metrics.merge!(
      duration_ms: duration.round(2),
      status: response.status,
      cache_hits: cache_hits_count,
      db_queries: db_query_count,
      memory_usage: memory_usage_mb
    )

    # Log slow requests
    if duration > slow_request_threshold
      Rails.logger.warn "Slow request detected: #{@performance_metrics}"
    end

    # Log to performance monitoring service (e.g., New Relic, DataDog)
    if Rails.env.production?
      log_to_monitoring_service(@performance_metrics)
    end
  end

  # Caching helpers
  def cache_key_for(object, *suffixes)
    key_parts = [object.class.name.underscore]
    
    if object.respond_to?(:cache_key_with_version)
      key_parts << object.cache_key_with_version
    elsif object.respond_to?(:cache_key)
      key_parts << object.cache_key
    else
      key_parts << object.id
    end
    
    key_parts.concat(suffixes.map(&:to_s))
    key_parts.join('/')
  end

  def cache_key_for_collection(collection, *suffixes)
    return 'empty' if collection.empty?

    key_parts = [collection.first.class.name.underscore.pluralize]
    
    if collection.respond_to?(:cache_key)
      key_parts << collection.cache_key
    else
      # Generate cache key based on collection contents
      ids = collection.map(&:id).sort
      updated_ats = collection.map { |item| item.updated_at.to_f }.sort
      key_parts << "#{ids.hash}-#{updated_ats.hash}"
    end
    
    key_parts.concat(suffixes.map(&:to_s))
    key_parts.join('/')
  end

  def cache_unless_user_specific?
    !user_specific_content?
  end

  def user_specific_content?
    # Override in controllers that have user-specific content
    true
  end

  # Fragment caching helpers
  def cache_fragment(fragment_name, expires_in: 1.hour, &block)
    cache_key = fragment_cache_key(fragment_name)
    
    Rails.cache.fetch(cache_key, expires_in: expires_in) do
      capture(&block) if block_given?
    end
  end

  def fragment_cache_key(fragment_name)
    key_parts = [
      'fragment',
      controller_name,
      action_name,
      fragment_name.to_s
    ]
    
    # Add user-specific key if needed
    if user_specific_content?
      key_parts << "user_#{current_user&.id}"
    end
    
    # Add locale if internationalization is enabled
    key_parts << I18n.locale.to_s if defined?(I18n)
    
    key_parts.join('/')
  end

  def expire_fragment_cache(fragment_name)
    cache_key = fragment_cache_key(fragment_name)
    Rails.cache.delete(cache_key)
  end

  # Database query optimization
  def with_query_optimization
    original_query_count = db_query_count
    
    yield
    
    queries_executed = db_query_count - original_query_count
    
    if queries_executed > n_plus_one_threshold
      Rails.logger.warn "Potential N+1 query detected: #{queries_executed} queries in #{action_name}"
    end
  end

  # Memory optimization
  def optimize_memory_usage
    # Force garbage collection for memory-intensive operations
    GC.start if should_force_gc?
  end

  def should_force_gc?
    # Force GC if memory usage is high or for specific actions
    memory_usage_mb > memory_threshold || memory_intensive_action?
  end

  def memory_intensive_action?
    %w[export bulk_update import].include?(action_name)
  end

  # Response optimization
  def optimize_response
    # Enable compression for large responses
    if response.body.bytesize > compression_threshold
      response.headers['Content-Encoding'] = 'gzip'
    end
    
    # Set appropriate cache headers
    set_cache_headers if cacheable_response?
  end

  def set_cache_headers
    if @cache_config
      expires_in = @cache_config[:expires_in]
      response.headers['Cache-Control'] = "public, max-age=#{expires_in.to_i}"
      response.headers['Expires'] = expires_in.from_now.httpdate
    end
  end

  def cacheable_response?
    response.successful? && request.get? && !user_specific_content?
  end

  # Performance monitoring helpers
  def cache_hits_count
    # This would be tracked by the cache service
    CacheService.instance.cache_stats[:hit_rate] rescue 0
  end

  def db_query_count
    # Track database queries using ActiveRecord notifications
    @db_query_count ||= 0
  end

  def memory_usage_mb
    # Get current memory usage in MB
    `ps -o rss= -p #{Process.pid}`.to_i / 1024.0 rescue 0
  end

  def slow_request_threshold
    Rails.env.production? ? 1000 : 2000 # milliseconds
  end

  def n_plus_one_threshold
    10 # queries
  end

  def memory_threshold
    500 # MB
  end

  def compression_threshold
    1024 # bytes
  end

  def log_to_monitoring_service(metrics)
    # Integration with monitoring services
    # Example: NewRelic, DataDog, etc.
    
    # NewRelic example:
    # NewRelic::Agent.record_custom_event('ControllerPerformance', metrics)
    
    # DataDog example:
    # Datadog::Statsd.new.histogram('lani.controller.duration', metrics[:duration_ms])
    
    Rails.logger.info "Performance metrics: #{metrics.to_json}"
  end

  # Cache invalidation helpers
  def invalidate_related_caches(object)
    case object
    when Project
      CacheService.invalidate_project(object.id)
      invalidate_user_caches_for_project(object)
    when Task
      CacheService.invalidate_task(object.id, object.project_id)
    when User
      CacheService.invalidate_user_projects(object.id)
    end
  end

  def invalidate_user_caches_for_project(project)
    project.users.find_each do |user|
      CacheService.invalidate_user_projects(user.id)
    end
  end

  # Batch processing optimization
  def process_in_batches(collection, batch_size: 100)
    collection.find_in_batches(batch_size: batch_size) do |batch|
      yield batch
      
      # Optimize memory between batches
      GC.start if batch_size > 50
    end
  end

  # API response optimization
  def optimize_json_response(data)
    # Use Oj for faster JSON serialization if available
    if defined?(Oj)
      Oj.dump(data, mode: :compat)
    else
      data.to_json
    end
  end

  # Background job optimization
  def enqueue_background_job(job_class, *args)
    # Use appropriate queue based on job priority
    queue = determine_job_queue(job_class)
    job_class.set(queue: queue).perform_later(*args)
  end

  def determine_job_queue(job_class)
    case job_class.name
    when /Export/, /Report/
      'low_priority'
    when /Sync/, /Api/
      'medium_priority'
    when /Notification/, /Email/
      'high_priority'
    else
      'default'
    end
  end
end
