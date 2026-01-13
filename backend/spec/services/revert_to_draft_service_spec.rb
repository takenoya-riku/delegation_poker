require "rails_helper"

RSpec.describe RevertToDraftService, type: :service do
  describe "#call" do
    context "整理フェーズのトピックの場合" do
      it "対象出しに戻せる" do
        topic = create(:topic, status: "organizing")

        result = RevertToDraftService.call(topic_id: topic.id)

        expect(result[:success]).to be true
        expect(result[:topic].status).to eq("draft")
        expect(result[:errors]).to be_empty
      end
    end

    context "整理フェーズ以外のトピックの場合" do
      it "エラーメッセージを返す" do
        topic = create(:topic, status: "draft")

        result = RevertToDraftService.call(topic_id: topic.id)

        expect(result[:success]).to be false
        expect(result[:errors]).to include("整理フェーズのトピックのみ対象出しに戻せます")
      end
    end

    context "存在しないトピックIDの場合" do
      it "エラーメッセージを返す" do
        result = RevertToDraftService.call(topic_id: SecureRandom.uuid)

        expect(result[:success]).to be false
        expect(result[:topic]).to be_nil
        expect(result[:errors]).to include("トピックが見つかりません")
      end
    end
  end
end
