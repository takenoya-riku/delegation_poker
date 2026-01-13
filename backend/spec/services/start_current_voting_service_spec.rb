require "rails_helper"

RSpec.describe StartCurrentVotingService, type: :service do
  describe "#call" do
    context "整理フェーズのトピックの場合" do
      it "現状確認投票に進める" do
        topic = create(:topic, status: "organizing")

        result = StartCurrentVotingService.call(topic_id: topic.id)

        expect(result[:success]).to be true
        expect(result[:topic].status).to eq("current_voting")
        expect(result[:errors]).to be_empty
      end
    end

    context "整理フェーズ以外のトピックの場合" do
      it "エラーメッセージを返す" do
        topic = create(:topic, status: "draft")

        result = StartCurrentVotingService.call(topic_id: topic.id)

        expect(result[:success]).to be false
        expect(result[:errors]).to include("整理フェーズのトピックのみ現状確認投票に進めます")
      end
    end

    context "存在しないトピックIDの場合" do
      it "エラーメッセージを返す" do
        result = StartCurrentVotingService.call(topic_id: SecureRandom.uuid)

        expect(result[:success]).to be false
        expect(result[:topic]).to be_nil
        expect(result[:errors]).to include("トピックが見つかりません")
      end
    end
  end
end
