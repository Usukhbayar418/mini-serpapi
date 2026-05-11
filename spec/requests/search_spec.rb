require 'rails_helper'

RSpec.describe 'Search API', type: :request do 
    describe 'GET /api/v1/search' do 
        context 'when q parameter is missing' do
            it 'returns a 400 with error message' do 
                #1. Arrange
                #2. Act
                get '/api/v1/search'
                #3. Assert
                expect(response).to have_http_status(:bad_request)
                expect(JSON.parse(response.body)['error']).to eq('q parameter is required')
            end
        end
    end
end