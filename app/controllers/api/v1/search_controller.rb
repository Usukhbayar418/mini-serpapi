module Api
  module V1
    class SearchController < ApplicationController
      before_action :authenticate_api_key!

        def index
            query = params[:q]
            engine = params[:engine] || "brave"

            if query.blank?
                return render json: { error: "q parameter is required" }, status: 400
            end
            unless %w[google duckduckgo gogo news brave images].include?(engine)
                return render json: { error: "engine must be one of: brave, duckduckgo, google, gogo, news, images" }, status: 400
            end

            started_at = Time.now
            result = SearchService.new(query, engine).search
            duration_ms = ((Time.now - started_at) * 1000).round

            SearchHistory.create(
                query: query,
                engine: engine,
                api_key: @api_key,
                results_count: result[:total_results] || 0,
                duration_ms: duration_ms,
                ip: request.remote_ip,
                user_agent: request.user_agent
            )

        render json: result
    rescue StandardError => e
        render json: { error: e.message }, status: 500
    end
    end
  end
end
