require "rails_helper"

RSpec.describe JoinRoomService, type: :service do
  describe "#call" do
    context "存在するルームコードと参加者名が渡された場合" do
      it "参加者を作成して成功レスポンスを返す" do
        room = create(:room)
        result = JoinRoomService.call(code: room.code, name: "Test Participant")

        expect(result[:success]).to be true
        expect(result[:participant]).to be_present
        expect(result[:participant].name).to eq("Test Participant")
        expect(result[:participant].room_id).to eq(room.id)
        expect(result[:room]).to eq(room)
        expect(result[:errors]).to be_empty
      end

      it "ルームコードは大文字小文字を区別しない" do
        room = create(:room, code: "ABC123")
        result = JoinRoomService.call(code: "abc123", name: "Test Participant")

        expect(result[:success]).to be true
        expect(result[:participant].room_id).to eq(room.id)
      end
    end

    context "存在しないルームコードが渡された場合" do
      it "エラーメッセージを含む失敗レスポンスを返す" do
        result = JoinRoomService.call(code: "INVALID", name: "Test Participant")

        expect(result[:success]).to be false
        expect(result[:participant]).to be_nil
        expect(result[:room]).to be_nil
        expect(result[:errors]).to include("ルームが見つかりません")
      end
    end

    context "無効な参加者名が渡された場合" do
      it "エラーメッセージを含む失敗レスポンスを返す" do
        room = create(:room)
        result = JoinRoomService.call(code: room.code, name: "")

        expect(result[:success]).to be false
        expect(result[:participant]).to be_present
        expect(result[:room]).to eq(room)
        expect(result[:errors]).not_to be_empty
      end
    end
  end
end
