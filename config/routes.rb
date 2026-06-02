Rails.application.routes.draw do
  root to: proc {
    body = {
      name: "mini-serpapi",
      status: "ok",
      version: "1.0",
      endpoints: {
        search: "GET /api/v1/search?q=<query>&engine=<brave|images|duckduckgo>",
        history: "GET /api/v1/history?limit=<n>"
      },
      authentication: "X-API-Key header required",
      demo_key: "demo-key-12345",
      docs: "https://github.com/Usukhbayar418/mini-serpapi"
    }.to_json
    [200, { "Content-Type" => "application/json" }, [body]]
  }

  namespace :api do
    namespace :v1 do
      get "search", to: "search#index"
      get "history", to: "history#index"
    end
  end
end