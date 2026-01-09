# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin Ajax requests.

# Read more: https://github.com/cyu/rack-cors

# CORS設定
# すべての環境でCORSを有効化
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # 開発環境では複数のオリジンを許可
    frontend_url = ENV.fetch("FRONTEND_URL", "http://localhost:8088")
    origins frontend_url, "http://localhost:8088", "http://127.0.0.1:8088"

    resource "*",
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: true
  end
end
