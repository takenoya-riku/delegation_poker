require 'rails_helper'

RSpec.describe 'Auth', type: :request do
  let(:frontend_url) { 'http://localhost:8088' }
  let(:jwt_secret) { 'test_secret_key_for_jwt' }

  before do
    allow(ENV).to receive(:fetch).with('FRONTEND_URL', 'http://localhost:8088').and_return(frontend_url)
    allow(ENV).to receive(:fetch).with('JWT_SECRET').and_return(jwt_secret)
    allow(ENV).to receive(:fetch).with('GOOGLE_CLIENT_ID').and_return('test_client_id')
    allow(ENV).to receive(:fetch).with('GOOGLE_CLIENT_SECRET').and_return('test_client_secret')
  end

  describe 'GET /auth/google' do
    it 'Google認証ページにリダイレクトする' do
      get '/auth/google'
      expect(response).to have_http_status(:redirect)
    end
  end

  describe 'GET /auth/google/callback' do
    let(:auth_info) do
      {
        'uid' => '123456789',
        'info' => {
          'email' => 'test@example.com',
          'name' => 'Test User',
          'image' => 'https://example.com/avatar.jpg'
        }
      }
    end

    before do
      # OmniAuthのモック設定
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:google] = OmniAuth::AuthHash.new(auth_info)
    end

    after do
      OmniAuth.config.test_mode = false
      OmniAuth.config.mock_auth[:google] = nil
    end

    context '新規ユーザーの場合' do
      it 'ユーザーを作成してJWTトークンを発行し、フロントエンドにリダイレクトする' do
        expect {
          get '/auth/google/callback', params: {}, env: { 'omniauth.auth' => OmniAuth.config.mock_auth[:google] }
        }.to change(User, :count).by(1)

        expect(response).to have_http_status(:redirect)
        expect(response.location).to start_with(frontend_url)
        expect(response.location).to include('token=')
      end

      it '作成されたユーザーの情報が正しい' do
        get '/auth/google/callback', params: {}, env: { 'omniauth.auth' => OmniAuth.config.mock_auth[:google] }

        user = User.last
        expect(user.email).to eq('test@example.com')
        expect(user.name).to eq('Test User')
        expect(user.google_uid).to eq('123456789')
        expect(user.avatar_url).to eq('https://example.com/avatar.jpg')
      end
    end

    context '既存ユーザーの場合' do
      let!(:existing_user) do
        create(:user, google_uid: '123456789', email: 'old@example.com', name: 'Old Name')
      end

      it 'ユーザーを更新してJWTトークンを発行し、フロントエンドにリダイレクトする' do
        expect {
          get '/auth/google/callback', params: {}, env: { 'omniauth.auth' => OmniAuth.config.mock_auth[:google] }
        }.not_to change(User, :count)

        expect(response).to have_http_status(:redirect)
        expect(response.location).to start_with(frontend_url)
        expect(response.location).to include('token=')

        existing_user.reload
        expect(existing_user.email).to eq('test@example.com')
        expect(existing_user.name).to eq('Test User')
      end
    end

    context '認証情報が取得できない場合' do
      it 'エラーページにリダイレクトする' do
        get '/auth/google/callback', params: {}, env: {}

        expect(response).to have_http_status(:redirect)
        expect(response.location).to start_with(frontend_url)
        expect(response.location).to include('auth/error')
        expect(response.location).to include('message=')
      end
    end

    context 'ユーザー作成に失敗した場合' do
      before do
        allow_any_instance_of(AuthController).to receive(:find_or_create_user).and_return(nil)
      end

      it 'エラーページにリダイレクトする' do
        get '/auth/google/callback', params: {}, env: { 'omniauth.auth' => OmniAuth.config.mock_auth[:google] }

        expect(response).to have_http_status(:redirect)
        expect(response.location).to start_with(frontend_url)
        expect(response.location).to include('auth/error')
      end
    end
  end
end
