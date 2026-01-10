Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by uptime monitors and load balancers.
  get "up" => "rails/health#show", as: :rails_health_check

  # OAuth認証
  get "/auth/google", to: "auth#google"
  get "/auth/google/callback", to: "auth#google_callback"

  # GraphQL endpoint
  post "/graphql", to: "graphql#execute"
  # GETリクエストも許可（開発環境のみ、GraphiQLなどで使用）
  get "/graphql", to: "graphql#execute" if Rails.env.development?

  # GraphiQL IDE (development only)
  if Rails.env.development?
    mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql"
  end

  # API routes will be defined here
  # namespace :api do
  #   namespace :v1 do
  #     resources :resources
  #   end
  # end
end
