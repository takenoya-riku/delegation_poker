module Authenticable
  extend ActiveSupport::Concern

  private

  def current_user
    @current_user ||= begin
      token = extract_token_from_header
      return nil unless token

      payload = JwtService.call(token: token)
      return nil unless payload

      User.find_by(id: payload['user_id'])
    end
  end

  def authenticate_user!
    return if current_user

    render json: { errors: [{ message: '認証が必要です' }] }, status: :unauthorized
  end

  def extract_token_from_header
    auth_header = request.headers['Authorization']
    return nil unless auth_header

    # Bearerトークンの形式を想定: "Bearer <token>"
    auth_header.split(' ').last if auth_header.start_with?('Bearer ')
  end
end
