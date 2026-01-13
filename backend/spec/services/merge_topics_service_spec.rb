require "rails_helper"

RSpec.describe MergeTopicsService, type: :service do
  describe "#call" do
    context "整理フェーズのトピックが同じルーム内にある場合" do
      it "トピックを統合して統合元を削除する" do
        room = create(:room)
        source_topic = create(:topic, room: room, status: "organizing", title: "元", description: "元説明")
        target_topic = create(:topic, room: room, status: "organizing", title: "先", description: "先説明")

        result = MergeTopicsService.call(source_topic_id: source_topic.id, target_topic_id: target_topic.id)

        expect(result[:success]).to be true
        expect(result[:topic].title).to eq("先 / 元")
        expect(result[:topic].description).to eq("先説明\n\n元説明")
        expect(result[:errors]).to be_empty
        expect(Topic.find_by(id: source_topic.id)).to be_nil
      end
    end

    context "統合元のトピックが存在しない場合" do
      it "エラーメッセージを返す" do
        room = create(:room)
        target_topic = create(:topic, room: room, status: "organizing")

        result = MergeTopicsService.call(source_topic_id: SecureRandom.uuid, target_topic_id: target_topic.id)

        expect(result[:success]).to be false
        expect(result[:topic]).to be_nil
        expect(result[:errors]).to include("統合元のトピックが見つかりません")
      end
    end

    context "統合先のトピックが存在しない場合" do
      it "エラーメッセージを返す" do
        room = create(:room)
        source_topic = create(:topic, room: room, status: "organizing")

        result = MergeTopicsService.call(source_topic_id: source_topic.id, target_topic_id: SecureRandom.uuid)

        expect(result[:success]).to be false
        expect(result[:topic]).to be_nil
        expect(result[:errors]).to include("統合先のトピックが見つかりません")
      end
    end

    context "整理フェーズ以外のトピックが含まれる場合" do
      it "エラーメッセージを返す" do
        room = create(:room)
        source_topic = create(:topic, room: room, status: "draft")
        target_topic = create(:topic, room: room, status: "organizing")

        result = MergeTopicsService.call(source_topic_id: source_topic.id, target_topic_id: target_topic.id)

        expect(result[:success]).to be false
        expect(result[:errors]).to include("整理フェーズのトピックのみ統合できます")
      end
    end

    context "異なるルームのトピックの場合" do
      it "エラーメッセージを返す" do
        source_room = create(:room)
        target_room = create(:room)
        source_topic = create(:topic, room: source_room, status: "organizing")
        target_topic = create(:topic, room: target_room, status: "organizing")

        result = MergeTopicsService.call(source_topic_id: source_topic.id, target_topic_id: target_topic.id)

        expect(result[:success]).to be false
        expect(result[:errors]).to include("同じルームのトピックのみ統合できます")
      end
    end
  end
end
