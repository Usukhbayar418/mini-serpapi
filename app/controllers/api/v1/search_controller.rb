module Api 
    module V1
        class SearchController < ApplicationController
            def index
                query = params[:q]
                engine = params[:engine] || 'duckduckgo'

                if query.blank? 
                    return render json: {error: 'q parameter is required'}, status: 400
                end

                unless %w[google duckduckgo gogo news].include?(engine)
                    return render json: {error: 'engine must be google or duckduckgo'}, status: 400
                end

                result = SearchService.new(query, engine).search
                render json: result
                
            rescue StandardError => e
                render json: {error: e.message}, status: 500
            end
        end
    end
end