require 'rails_helper'

RSpec.describe 'History API', type: :request do
  describe 'GET /api/v1/history' do
    let(:api_key) { 'test-key-12345' }
    let(:other_api_key) { 'other-key-99999' }
    let(:headers) { { 'X-API-Key' => api_key } }

    before do
      ENV['API_KEYS'] = "#{api_key},#{other_api_key}"
    end

    it 'returns 401 when X-API-Key is missing' do
      get '/api/v1/history'
      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns empty history when no records exist' do
      get '/api/v1/history', headers: headers
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['count']).to eq(0)
      expect(body['history']).to eq([])
    end

    it 'returns only records for the calling api_key' do
      SearchHistory.create!(query: 'mine', engine: 'brave', api_key: api_key,
                            results_count: 10, duration_ms: 100)
      SearchHistory.create!(query: 'theirs', engine: 'brave', api_key: other_api_key,
                            results_count: 5, duration_ms: 50)

      get '/api/v1/history', headers: headers
      body = JSON.parse(response.body)

      expect(body['count']).to eq(1)
      expect(body['history'].first['query']).to eq('mine')
    end

    it 'orders results by created_at descending (newest first)' do
      SearchHistory.create!(query: 'old', engine: 'brave', api_key: api_key,
                            results_count: 1, duration_ms: 1,
                            created_at: 1.hour.ago)
      SearchHistory.create!(query: 'new', engine: 'brave', api_key: api_key,
                            results_count: 1, duration_ms: 1)

      get '/api/v1/history', headers: headers
      body = JSON.parse(response.body)

      expect(body['history'].first['query']).to eq('new')
      expect(body['history'].last['query']).to eq('old')
    end

    it 'respects the limit parameter' do
      3.times do |i|
        SearchHistory.create!(query: "q#{i}", engine: 'brave', api_key: api_key,
                              results_count: 1, duration_ms: 1)
      end

      get '/api/v1/history', params: { limit: 2 }, headers: headers
      body = JSON.parse(response.body)

      expect(body['count']).to eq(2)
    end
  end
end
