require "rails_helper"

RSpec.describe RevertToOrganizingService, type: :service do
  describe "#call" do
    context "投票フェーズのトピックの場合" do
      it "整理フェーズに戻して投票を削除する" do
        room = create(:room)
        participant = create(:participant, room: room)
        topic = create(:topic, room: room, participant: participant, status: "current_voting")
        create(:vote, topic: topic, participant: participant, vote_type: "current_state")

        result = RevertToOrganizingService.call(topic_id: topic.id)

        expect(result[:success]).to be true
        expect(result[:topic].status).to eq("organizing")
        expect(result[:topic].votes.count).to eq(0)
        expect(result[:errors]).to be_empty
      end
    end

    context "投票フェーズ以外のトピックの場合" do
      it "エラーメッセージを返す" do
        topic = create(:topic, status: "draft")

        result = RevertToOrganizingService.call(topic_id: topic.id)

        expect(result[:success]).to be false
        expect(result[:errors]).to include("投票フェーズのトピックのみ整理フェーズに戻せます")
      end
    end

    context "存在しないトピックIDが渡された場合" do
      it "エラーメッセージを返す" do
        result = RevertToOrganizingService.call(topic_id: SecureRandom.uuid)

        expect(result[:success]).to be false
        expect(result[:topic]).to be_nil
        expect(result[:errors]).to include("トピックが見つかりません")
      end
    end
  end
end
