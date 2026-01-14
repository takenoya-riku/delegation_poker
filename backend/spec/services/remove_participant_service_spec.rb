require "rails_helper"

RSpec.describe RemoveParticipantService, type: :service do
  describe "#call" do
    let(:room) { create(:room) }
    let(:master) { create(:participant, room: room) }
    let(:member) { create(:participant, room: room) }

    before do
      room.update!(room_master_id: master.id)
    end

    context "ルームマスターが参加者を削除した場合" do
      it "参加者を削除して成功レスポンスを返す" do
        result = RemoveParticipantService.call(
          room_id: room.id,
          participant_id: master.id,
          target_participant_id: member.id,
        )

        expect(result[:success]).to be true
        expect(result[:errors]).to be_empty
        expect(Participant.find_by(id: member.id)).to be_nil
      end
    end

    context "ルームマスター以外が削除を実行した場合" do
      it "エラーメッセージを含む失敗レスポンスを返す" do
        result = RemoveParticipantService.call(
          room_id: room.id,
          participant_id: member.id,
          target_participant_id: master.id,
        )

        expect(result[:success]).to be false
        expect(result[:errors]).to include("ルームマスターのみ削除できます")
      end
    end

    context "ルームマスターを削除しようとした場合" do
      it "エラーメッセージを含む失敗レスポンスを返す" do
        result = RemoveParticipantService.call(
          room_id: room.id,
          participant_id: master.id,
          target_participant_id: master.id,
        )

        expect(result[:success]).to be false
        expect(result[:errors]).to include("ルームマスターは削除できません")
      end
    end

    context "削除対象がルームに属していない場合" do
      it "エラーメッセージを含む失敗レスポンスを返す" do
        other_room = create(:room)
        other_participant = create(:participant, room: other_room)

        result = RemoveParticipantService.call(
          room_id: room.id,
          participant_id: master.id,
          target_participant_id: other_participant.id,
        )

        expect(result[:success]).to be false
        expect(result[:errors]).to include("削除対象の参加者がこのルームに属していません")
      end
    end
  end
end
