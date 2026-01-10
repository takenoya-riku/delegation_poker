require 'rails_helper'

RSpec.describe JwtService, type: :service do
  let(:user) { create(:user) }
  let(:jwt_secret) { 'test_secret_key_for_jwt' }

  before do
    allow(ENV).to receive(:fetch).with('JWT_SECRET').and_return(jwt_secret)
  end

  describe '#encode' do
    it 'ユーザー情報からJWTトークンを発行する' do
      token = JwtService.call(user: user)

      expect(token).to be_present
      expect(token).to be_a(String)
    end

    it '発行されたトークンにはユーザーIDとemailが含まれる' do
      token = JwtService.call(user: user)
      payload = JwtService.call(token: token)

      expect(payload['user_id']).to eq(user.id)
      expect(payload['email']).to eq(user.email)
    end
  end

  describe '#decode' do
    context '有効なトークンが渡された場合' do
      it 'トークンからユーザー情報を取得する' do
        token = JwtService.call(user: user)
        payload = JwtService.call(token: token)

        expect(payload).to be_present
        expect(payload['user_id']).to eq(user.id)
        expect(payload['email']).to eq(user.email)
      end
    end

    context '無効なトークンが渡された場合' do
      it 'nilを返す' do
        invalid_token = 'invalid_token'
        payload = JwtService.call(token: invalid_token)

        expect(payload).to be_nil
      end
    end

    context '期限切れのトークンが渡された場合' do
      it 'nilを返す' do
        # 期限切れのトークンを生成
        expired_payload = {
          user_id: user.id,
          email: user.email,
          exp: 1.hour.ago.to_i
        }
        expired_token = JWT.encode(expired_payload, jwt_secret, 'HS256')

        payload = JwtService.call(token: expired_token)

        expect(payload).to be_nil
      end
    end
  end
end
