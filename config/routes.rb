Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      get "search", to: "search#index"
      get "history", to: "history#index"
    end
  end
end
