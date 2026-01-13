require "rails_helper"

RSpec.describe Mutations::MergeTopics, type: :graphql do
  describe "#resolve" do
    it "整理フェーズのトピックを統合できる" do
      room = create(:room)
      source_topic = create(:topic, room: room, status: "organizing", title: "元", description: "元説明")
      target_topic = create(:topic, room: room, status: "organizing", title: "先", description: "先説明")

      result = execute_mutation(
        mutation: <<~GRAPHQL,
          mutation MergeTopics($sourceTopicId: ID!, $targetTopicId: ID!) {
            mergeTopics(sourceTopicId: $sourceTopicId, targetTopicId: $targetTopicId) {
              topic {
                id
                title
                description
              }
              errors
            }
          }
        GRAPHQL
        variables: {
          sourceTopicId: source_topic.id,
          targetTopicId: target_topic.id,
        },
      )

      data = graphql_data(result)
      expect(data["mergeTopics"]["topic"]["title"]).to eq("先 / 元")
      expect(data["mergeTopics"]["errors"]).to eq([])
    end

    it "整理フェーズ以外のトピックはエラーを返す" do
      room = create(:room)
      source_topic = create(:topic, room: room, status: "draft")
      target_topic = create(:topic, room: room, status: "organizing")

      result = execute_mutation(
        mutation: <<~GRAPHQL,
          mutation MergeTopics($sourceTopicId: ID!, $targetTopicId: ID!) {
            mergeTopics(sourceTopicId: $sourceTopicId, targetTopicId: $targetTopicId) {
              topic {
                id
              }
              errors
            }
          }
        GRAPHQL
        variables: {
          sourceTopicId: source_topic.id,
          targetTopicId: target_topic.id,
        },
      )

      data = graphql_data(result)
      expect(data["mergeTopics"]["errors"]).to include("整理フェーズのトピックのみ統合できます")
    end
  end
end
