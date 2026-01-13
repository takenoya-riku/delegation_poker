require "rails_helper"

RSpec.describe OrganizeTopicService, type: :service do
  describe "#call" do
    context "対象出しフェーズのトピックの場合" do
      it "整理フェーズに移行できる" do
        topic = create(:topic, status: "draft")

        result = OrganizeTopicService.call(topic_id: topic.id)

        expect(result[:success]).to be true
        expect(result[:topic].status).to eq("organizing")
        expect(result[:errors]).to be_empty
      end
    end

    context "対象出しフェーズ以外のトピックの場合" do
      it "エラーメッセージを返す" do
        topic = create(:topic, status: "organizing")

        result = OrganizeTopicService.call(topic_id: topic.id)

        expect(result[:success]).to be false
        expect(result[:errors]).to include("対象出しフェーズのトピックのみ整理できます")
      end
    end

    context "存在しないトピックIDの場合" do
      it "エラーメッセージを返す" do
        result = OrganizeTopicService.call(topic_id: SecureRandom.uuid)

        expect(result[:success]).to be false
        expect(result[:topic]).to be_nil
        expect(result[:errors]).to include("トピックが見つかりません")
      end
    end
  end
end
