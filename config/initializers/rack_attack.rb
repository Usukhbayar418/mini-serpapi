class Rack::Attack
    Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

    # Throttle requests to 5 requests per minute per IP address
    throttle("search/api_key", limit: 30, period: 1.minute) do |req|
      if req.path.start_with?("/api/v1/search")
        req.get_header("HTTP_X_API_KEY")
      end
    end
end
