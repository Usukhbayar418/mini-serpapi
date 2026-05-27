module Api
  module V1
    class HistoryController < ApplicationController
      before_action :authenticate_api_key!

      def index
        limit = (params[:limit] || 20).to_i.clamp(1, 100)

        records = SearchHistory.where(api_key: @api_key)
                              .order(created_at: :desc)
                              .limit(limit)

        render json: {
          count: records.size,
          history: records.map do |r|
            {
              id: r.id,
              query: r.query,
              engine: r.engine,
              results_count: r.results_count,
              duration_ms: r.duration_ms,
              created_at: r.created_at
            }
          end
        }
      rescue StandardError => e
        render json: { error: e.message }, status: 500
      end
    end
  end
end