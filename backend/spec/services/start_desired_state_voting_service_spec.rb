require "rails_helper"

RSpec.describe StartDesiredStateVotingService, type: :service do
  describe "#call" do
    context "現状確認結果公開済みのトピックの場合" do
      it "理想投票に進める" do
        topic = create(:topic, status: "current_revealed")

        result = StartDesiredStateVotingService.call(topic_id: topic.id)

        expect(result[:success]).to be true
        expect(result[:topic].status).to eq("desired_voting")
        expect(result[:errors]).to be_empty
      end
    end

    context "現状確認結果公開済み以外のトピックの場合" do
      it "エラーメッセージを返す" do
        topic = create(:topic, status: "current_voting")

        result = StartDesiredStateVotingService.call(topic_id: topic.id)

        expect(result[:success]).to be false
        expect(result[:errors]).to include("現状確認結果が公開済みのトピックのみ、理想投票を開始できます")
      end
    end

    context "存在しないトピックIDの場合" do
      it "エラーメッセージを返す" do
        result = StartDesiredStateVotingService.call(topic_id: SecureRandom.uuid)

        expect(result[:success]).to be false
        expect(result[:topic]).to be_nil
        expect(result[:errors]).to include("トピックが見つかりません")
      end
    end
  end
end
