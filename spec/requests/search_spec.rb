require 'rails_helper'

RSpec.describe 'Search API', type: :request do 
    describe 'GET /api/v1/search' do 
        let(:api_key) { 'test-key-12345'}

        before do 
            ENV['API_KEYS']= api_key
        end

        context 'when q parameter is missing' do
            it 'returns a 400 with error message' do 
                get '/api/v1/search', headers: { 'X-API-Key' => api_key }
                expect(response).to have_http_status(:bad_request)
                expect(JSON.parse(response.body)['error']).to eq('q parameter is required')
            end
        end
    end
end