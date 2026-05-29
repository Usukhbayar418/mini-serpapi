require 'rails_helper'

RSpec.describe 'Search API', type: :request do
  describe 'GET /api/v1/search' do
    let(:api_key) { 'test-key-12345' }
    let(:headers) { { 'X-API-Key' => api_key } }

    before do
      ENV['API_KEYS'] = api_key
    end

    context 'authentication' do
      it 'returns 401 when X-API-Key header is missing' do
        get '/api/v1/search', params: { q: 'test' }
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['error']).to eq('Unauthorized')
      end

      it 'returns 401 when X-API-Key is invalid' do
        get '/api/v1/search',
            params: { q: 'test' },
            headers: { 'X-API-Key' => 'wrong-key' }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'parameter validation' do
      it 'returns 400 when q is missing' do
        get '/api/v1/search', headers: headers
        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)['error']).to eq('q parameter is required')
      end

      it 'returns 400 when engine is invalid' do
        get '/api/v1/search',
            params: { q: 'test', engine: 'bing' },
            headers: headers
        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)['error']).to include('engine must be one of')
      end
    end
  end
end