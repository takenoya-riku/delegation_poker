require "rails_helper"

RSpec.describe AddTopicService, type: :service do
  describe "#call" do
    context "存在するルームIDと有効なタイトルが渡された場合" do
      it "トピックを作成して成功レスポンスを返す" do
        room = create(:room)
        participant = create(:participant, room: room)
        result = AddTopicService.call(room_id: room.id, participant_id: participant.id, title: "Test Topic")

        expect(result[:success]).to be true
        expect(result[:topic]).to be_present
        expect(result[:topic].title).to eq("Test Topic")
        expect(result[:topic].room_id).to eq(room.id)
        expect(result[:topic].participant_id).to eq(participant.id)
        expect(result[:topic].status).to eq("draft")
        expect(result[:errors]).to be_empty
      end

      it "説明が渡された場合は説明も保存する" do
        room = create(:room)
        participant = create(:participant, room: room)
        result = AddTopicService.call(
          room_id: room.id,
          participant_id: participant.id,
          title: "Test Topic",
          description: "Test Description",
        )

        expect(result[:success]).to be true
        expect(result[:topic].description).to eq("Test Description")
      end

      it "説明が渡されない場合はnilが保存される" do
        room = create(:room)
        participant = create(:participant, room: room)
        result = AddTopicService.call(room_id: room.id, participant_id: participant.id, title: "Test Topic")

        expect(result[:success]).to be true
        expect(result[:topic].description).to be_nil
      end
    end

    context "存在しないルームIDが渡された場合" do
      it "エラーメッセージを含む失敗レスポンスを返す" do
        result = AddTopicService.call(
          room_id: SecureRandom.uuid,
          participant_id: SecureRandom.uuid,
          title: "Test Topic",
        )

        expect(result[:success]).to be false
        expect(result[:topic]).to be_nil
        expect(result[:errors]).to include("ルームが見つかりません")
      end
    end

    context "存在しない参加者IDが渡された場合" do
      it "エラーメッセージを含む失敗レスポンスを返す" do
        room = create(:room)
        result = AddTopicService.call(
          room_id: room.id,
          participant_id: SecureRandom.uuid,
          title: "Test Topic",
        )

        expect(result[:success]).to be false
        expect(result[:topic]).to be_nil
        expect(result[:errors]).to include("参加者が見つかりません")
      end
    end

    context "無効なタイトルが渡された場合" do
      it "エラーメッセージを含む失敗レスポンスを返す" do
        room = create(:room)
        participant = create(:participant, room: room)
        result = AddTopicService.call(room_id: room.id, participant_id: participant.id, title: "")

        expect(result[:success]).to be false
        expect(result[:topic]).to be_present
        expect(result[:errors]).not_to be_empty
      end
    end
  end
end
