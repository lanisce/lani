# Service for integrating with external APIs (OpenProject, Maybe, Nextcloud, Medusa)
class ExternalApiService
  include HTTParty
  
  class << self
    # OpenProject API Integration
    def openproject_client(base_url = nil, api_key = nil)
      @openproject_client ||= OpenProjectClient.new(
        base_url: base_url || Rails.application.credentials.openproject&.base_url || ENV['OPENPROJECT_BASE_URL'],
        api_key: api_key || Rails.application.credentials.openproject&.api_key || ENV['OPENPROJECT_API_KEY']
      )
    end

    # Maybe Finance API Integration (for financial data patterns)
    def maybe_client(base_url = nil, api_key = nil)
      @maybe_client ||= MaybeClient.new(
        base_url: base_url || Rails.application.credentials.maybe&.base_url || ENV['MAYBE_BASE_URL'],
        api_key: api_key || Rails.application.credentials.maybe&.api_key || ENV['MAYBE_API_KEY']
      )
    end

    # Nextcloud API Integration (already implemented)
    def nextcloud_client
      @nextcloud_client ||= NextcloudService.new
    end

    # Medusa API Integration
    def medusa_client(base_url = nil, api_key = nil)
      @medusa_client ||= MedusaClient.new(
        base_url: base_url || Rails.application.credentials.medusa&.base_url || ENV['MEDUSA_BASE_URL'],
        api_key: api_key || Rails.application.credentials.medusa&.api_key || ENV['MEDUSA_API_KEY']
      )
    end
  end

  # OpenProject API Client
  class OpenProjectClient
    include HTTParty
    
    def initialize(base_url:, api_key:)
      @base_url = base_url
      @api_key = api_key
      self.class.base_uri @base_url
      self.class.headers 'Authorization' => "Basic #{Base64.encode64("apikey:#{@api_key}").chomp}"
      self.class.headers 'Content-Type' => 'application/json'
    end

    # Get projects using OpenProject API v3
    def projects(filters: {})
      response = self.class.get('/api/v3/projects', query: filters)
      handle_response(response)
    end

    # Get work packages (tasks) using OpenProject API v3
    def work_packages(project_id: nil, filters: {})
      query_params = filters.dup
      query_params[:filters] = [{ project: { operator: '=', values: [project_id.to_s] } }].to_json if project_id
      
      response = self.class.get('/api/v3/work_packages', query: query_params)
      handle_response(response)
    end

    # Create work package using OpenProject API v3
    def create_work_package(project_id:, subject:, description: nil, type_id: 1)
      body = {
        subject: subject,
        description: { raw: description },
        _links: {
          project: { href: "/api/v3/projects/#{project_id}" },
          type: { href: "/api/v3/types/#{type_id}" }
        }
      }

      response = self.class.post('/api/v3/work_packages', body: body.to_json)
      handle_response(response)
    end

    # Update work package using OpenProject API v3 PATCH
    def update_work_package(work_package_id:, attributes:)
      response = self.class.patch("/api/v3/work_packages/#{work_package_id}", body: attributes.to_json)
      handle_response(response)
    end

    private

    def handle_response(response)
      case response.code
      when 200..299
        response.parsed_response
      when 401
        raise "OpenProject API: Unauthorized - check your API key"
      when 404
        raise "OpenProject API: Resource not found"
      else
        raise "OpenProject API Error: #{response.code} - #{response.message}"
      end
    end
  end

  # Maybe Finance API Client (for financial patterns)
  class MaybeClient
    include HTTParty
    
    def initialize
      @base_url = Rails.application.credentials.dig(:maybe, :base_url) || ENV['MAYBE_BASE_URL']
      @api_key = Rails.application.credentials.dig(:maybe, :api_key) || ENV['MAYBE_API_KEY']
      
      if @base_url && @api_key
        self.class.base_uri @base_url
        @options = {
          headers: {
            'Authorization' => "Bearer #{@api_key}",
            'Content-Type' => 'application/json',
            'Accept' => 'application/json'
          },
          timeout: 30
        }
      end
    end
    
    def budgets
      return mock_budgets unless configured?
      
      begin
        response = self.class.get('/api/v1/budgets', @options)
        
        if response.success?
          budgets = response.parsed_response.is_a?(Array) ? response.parsed_response : [response.parsed_response]
          Rails.logger.info "Maybe: Retrieved #{budgets.size} budgets"
          budgets
        else
          Rails.logger.warn "Maybe API returned #{response.code}: #{response.message}"
          mock_budgets
        end
      rescue Net::TimeoutError, Net::OpenTimeout
        Rails.logger.error "Maybe API timeout"
        mock_budgets
      rescue => e
        Rails.logger.error "Maybe API Error: #{e.class} - #{e.message}"
        mock_budgets
      end
    end
    
    def transactions(limit: 50)
      return mock_transactions unless configured?
      
      begin
        response = self.class.get('/api/v1/transactions', @options.merge(query: { limit: limit }))
        
        if response.success?
          transactions = response.parsed_response.is_a?(Array) ? response.parsed_response : [response.parsed_response]
          Rails.logger.info "Maybe: Retrieved #{transactions.size} transactions"
          transactions
        else
          Rails.logger.warn "Maybe API returned #{response.code}: #{response.message}"
          mock_transactions
        end
      rescue Net::TimeoutError, Net::OpenTimeout
        Rails.logger.error "Maybe API timeout"
        mock_transactions
      rescue => e
        Rails.logger.error "Maybe API Error: #{e.class} - #{e.message}"
        mock_transactions
      end
    end
    
    def accounts
      return mock_accounts unless configured?
      
      begin
        response = self.class.get('/api/v1/accounts', @options)
        
        if response.success?
          accounts = response.parsed_response.is_a?(Array) ? response.parsed_response : [response.parsed_response]
          Rails.logger.info "Maybe: Retrieved #{accounts.size} accounts"
          accounts
        else
          Rails.logger.warn "Maybe API returned #{response.code}: #{response.message}"
          mock_accounts
        end
      rescue Net::TimeoutError, Net::OpenTimeout
        Rails.logger.error "Maybe API timeout"
        mock_accounts
      rescue => e
        Rails.logger.error "Maybe API Error: #{e.class} - #{e.message}"
        mock_accounts
      end
    end
    
    def create_budget(attributes)
      return nil unless configured?
      
      begin
        payload = {
          name: attributes[:name],
          amount: attributes[:amount],
          category: attributes[:category],
          period_start: attributes[:period_start],
          period_end: attributes[:period_end]
        }
        
        response = self.class.post('/api/v1/budgets', @options.merge(body: payload.to_json))
        
        if response.success?
          Rails.logger.info "Maybe: Created budget #{response.parsed_response['id']}"
          response.parsed_response
        else
          Rails.logger.error "Maybe: Failed to create budget - #{response.code}: #{response.body}"
          nil
        end
      rescue => e
        Rails.logger.error "Maybe API Error creating budget: #{e.class} - #{e.message}"
        nil
      end
    end
    
    def create_transaction(attributes)
      return nil unless configured?
      
      begin
        payload = {
          description: attributes[:description],
          amount: attributes[:amount],
          transaction_type: attributes[:transaction_type],
          category: attributes[:category],
          transaction_date: attributes[:transaction_date]
        }
        
        response = self.class.post('/api/v1/transactions', @options.merge(body: payload.to_json))
        
        if response.success?
          Rails.logger.info "Maybe: Created transaction #{response.parsed_response['id']}"
          response.parsed_response
        else
          Rails.logger.error "Maybe: Failed to create transaction - #{response.code}: #{response.body}"
          nil
        end
      rescue => e
        Rails.logger.error "Maybe API Error creating transaction: #{e.class} - #{e.message}"
        nil
      end
    end
    
    private
    
    def configured?
      @base_url.present? && @api_key.present?
    end

    # Mock data following Maybe's patterns when API not configured
    def mock_accounts
      [
        { id: 1, name: "Checking Account", balance: 2500.00, type: "checking" },
        { id: 2, name: "Savings Account", balance: 15000.00, type: "savings" },
        { id: 3, name: "Credit Card", balance: -850.00, type: "credit" }
      ]
    end

    def mock_transactions
      [
        { id: 1, amount: -45.67, description: "Grocery Store", category: "Food", date: 1.day.ago },
        { id: 2, amount: -12.50, description: "Coffee Shop", category: "Food", date: 2.days.ago },
        { id: 3, amount: 2500.00, description: "Salary", category: "Income", date: 7.days.ago }
      ]
    end

    def mock_budgets
      [
        { id: 1, name: "Food & Dining", amount: 500.00, spent: 234.50, category: "food" },
        { id: 2, name: "Transportation", amount: 200.00, spent: 89.25, category: "transport" },
        { id: 3, name: "Entertainment", amount: 150.00, spent: 67.80, category: "entertainment" }
      ]
    end

    def handle_response(response)
      case response.code
      when 200..299
        response.parsed_response
      when 401
        raise "Maybe API: Unauthorized - check your API key"
      when 404
        raise "Maybe API: Resource not found"
      else
        raise "Maybe API Error: #{response.code} - #{response.message}"
      end
    end
  end

  # Medusa API Client
  class MedusaClient
    include HTTParty
    
    def initialize(base_url:, api_key:)
      @base_url = base_url
      @api_key = api_key
      self.class.base_uri @base_url if @base_url
      self.class.headers 'Authorization' => "Bearer #{@api_key}" if @api_key
      self.class.headers 'Content-Type' => 'application/json'
    end

    # Get products using Medusa API
    def products(filters: {})
      return mock_products unless configured?
      response = self.class.get('/store/products', query: filters)
      handle_response(response)
    end

    # Get product by ID
    def product(product_id)
      return mock_products.first unless configured?
      response = self.class.get("/store/products/#{product_id}")
      handle_response(response)
    end

    private

    def configured?
      @base_url.present? && @api_key.present?
    end

    def mock_products
      [
        { id: 1, title: "Project Management Service", price: 99.99, description: "Professional project management consultation" },
        { id: 2, title: "Design Assets Package", price: 49.99, description: "UI/UX design assets for projects" }
      ]
    end

    def handle_response(response)
      case response.code
      when 200..299
        response.parsed_response
      when 401
        raise "Medusa API: Unauthorized - check your API key"
      when 404
        raise "Medusa API: Resource not found"
      else
        raise "Medusa API Error: #{response.code} - #{response.message}"
      end
    end
  end
end
