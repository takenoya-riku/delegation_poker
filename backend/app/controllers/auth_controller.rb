class AuthController < ApplicationController
  # OAuth認証エンドポイントは認証不要

  def google
    # OmniAuthのGoogle認証エンドポイントにリダイレクト
    # OmniAuthの設定でname: 'google'を指定しているため、/auth/googleが正しいエンドポイント
    redirect_to '/auth/google'
  end

  def google_callback
    auth_info = request.env['omniauth.auth']
    return handle_oauth_error('認証情報が取得できませんでした') unless auth_info

    user = find_or_create_user(auth_info)
    return handle_oauth_error('ユーザーの作成に失敗しました') unless user

    token = JwtService.call(user: user)
    return handle_oauth_error('トークンの発行に失敗しました') unless token

    frontend_url = ENV.fetch('FRONTEND_URL', 'http://localhost:8088')
    redirect_to "#{frontend_url}/auth/callback?token=#{token}", allow_other_host: true
  rescue StandardError => e
    logger.error "OAuth callback error: #{e.message}"
    logger.error e.backtrace.join("\n")
    handle_oauth_error('認証処理中にエラーが発生しました')
  end

  private

  def find_or_create_user(auth_info)
    google_uid = auth_info.uid
    email = auth_info.info.email
    name = auth_info.info.name
    avatar_url = auth_info.info.image

    user = User.find_by(google_uid: google_uid)
    if user
      # 既存ユーザーの情報を更新
      user.update(
        email: email,
        name: name,
        avatar_url: avatar_url
      )
      user
    else
      # 新規ユーザーを作成
      User.create(
        google_uid: google_uid,
        email: email,
        name: name,
        avatar_url: avatar_url
      )
    end
  end

  def handle_oauth_error(message)
    frontend_url = ENV.fetch('FRONTEND_URL', 'http://localhost:8088')
    redirect_to "#{frontend_url}/auth/error?message=#{CGI.escape(message)}", allow_other_host: true
  end
end
