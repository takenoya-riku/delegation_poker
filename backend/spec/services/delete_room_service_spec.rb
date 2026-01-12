require "rails_helper"

RSpec.describe DeleteRoomService, type: :service do
  describe "#call" do
    let(:room) { create(:room) }
    let(:master) { create(:participant, room: room) }
    let(:member) { create(:participant, room: room) }

    before do
      room.update!(room_master_id: master.id)
    end

    context "ルームマスターが削除を実行した場合" do
      it "ルームを削除して成功レスポンスを返す" do
        result = DeleteRoomService.call(room_id: room.id, participant_id: master.id)

        expect(result[:success]).to be true
        expect(result[:errors]).to be_empty
        expect(Room.find_by(id: room.id)).to be_nil
      end
    end

    context "ルームマスター以外が削除を実行した場合" do
      it "エラーメッセージを含む失敗レスポンスを返す" do
        result = DeleteRoomService.call(room_id: room.id, participant_id: member.id)

        expect(result[:success]).to be false
        expect(result[:errors]).to include("ルームマスターのみ削除できます")
        expect(Room.find_by(id: room.id)).to be_present
      end
    end

    context "参加者がルームに属していない場合" do
      it "エラーメッセージを含む失敗レスポンスを返す" do
        other_room = create(:room)
        other_participant = create(:participant, room: other_room)

        result = DeleteRoomService.call(room_id: room.id, participant_id: other_participant.id)

        expect(result[:success]).to be false
        expect(result[:errors]).to include("参加者がこのルームに属していません")
      end
    end

    context "ルームが存在しない場合" do
      it "エラーメッセージを含む失敗レスポンスを返す" do
        result = DeleteRoomService.call(room_id: SecureRandom.uuid, participant_id: master.id)

        expect(result[:success]).to be false
        expect(result[:errors]).to include("ルームが見つかりません")
      end
    end

    context "参加者が存在しない場合" do
      it "エラーメッセージを含む失敗レスポンスを返す" do
        result = DeleteRoomService.call(room_id: room.id, participant_id: SecureRandom.uuid)

        expect(result[:success]).to be false
        expect(result[:errors]).to include("参加者が見つかりません")
      end
    end
  end
end
