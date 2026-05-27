class ApplicationController < ActionController::API
    protected 

    def authenticate_api_key!
        @api_key = request.headers["X-API-Key"]
        valid_keys = ENV["API_KEYS"].to_s.split(",").map(&:strip)
        unless valid_keys.include?(@api_key)
            render json: { error: "Unauthorized" }, status: :unauthorized
        end
    end
end
