require 'rails_helper'

RSpec.describe CreateRoomService, type: :service do
  describe '#call' do
    context '有効なルーム名が渡された場合' do
      it 'ルームを作成して成功レスポンスを返す' do
        result = CreateRoomService.call(name: 'Test Room')

        expect(result.success).to be true
        expect(result.room).to be_present
        expect(result.room.name).to eq('Test Room')
        expect(result.room.code).to be_present
        expect(result.room.code.length).to eq(6)
        expect(result.errors).to be_empty
      end
    end

    context '無効なルーム名が渡された場合' do
      it 'エラーメッセージを含む失敗レスポンスを返す' do
        result = CreateRoomService.call(name: '')

        expect(result.success).to be false
        expect(result.room).to be_present
        expect(result.errors).not_to be_empty
      end
    end
  end
end
