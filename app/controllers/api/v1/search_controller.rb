module Api 
    module V1
        class SearchController < ApplicationController
            before_action :authenticate_api_key!
            def index
                query = params[:q]
                engine = params[:engine] || 'brave'

                if query.blank? 
                    return render json: {error: 'q parameter is required'}, status: 400
                end

                unless %w[google duckduckgo gogo news brave images].include?(engine)
                    return render json: {error: 'engine must be one of: brave, duckduckgo, google, gogo, news, images'}, status: 400
                end

                result = SearchService.new(query, engine).search
                render json: result
                
            rescue StandardError => e
                render json: {error: e.message}, status: 500
            end

            private
            
            def authenticate_api_key!
                api_key = request.headers['X-API-Key']
                valid_keys = ENV['API_KEYS'].to_s.split(',').map(&:strip)
                unless valid_keys.include?(api_key)
                    render json: { error: 'Unauthorized' }, status: :unauthorized
                end
            end
        end
    end
end