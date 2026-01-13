require "rails_helper"

RSpec.describe Mutations::UpdateTopic, type: :graphql do
  describe "#resolve" do
    let(:room) { create(:room) }
    let(:owner) { create(:participant, room: room) }
    let(:other_participant) { create(:participant, room: room) }

    it "対象出しの自分のトピックを編集できる" do
      topic = create(:topic, room: room, participant: owner, status: "draft")

      result = execute_mutation(
        mutation: <<~GRAPHQL,
          mutation UpdateTopic($topicId: ID!, $participantId: ID!, $title: String, $description: String) {
            updateTopic(topicId: $topicId, participantId: $participantId, title: $title, description: $description) {
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
          topicId: topic.id,
          participantId: owner.id,
          title: "更新後タイトル",
          description: "更新後の説明",
        },
      )

      data = graphql_data(result)
      expect(data["updateTopic"]["topic"]["title"]).to eq("更新後タイトル")
      expect(data["updateTopic"]["topic"]["description"]).to eq("更新後の説明")
      expect(data["updateTopic"]["errors"]).to eq([])
    end

    it "対象出しの他人のトピックは編集できない" do
      topic = create(:topic, room: room, participant: owner, status: "draft")

      result = execute_mutation(
        mutation: <<~GRAPHQL,
          mutation UpdateTopic($topicId: ID!, $participantId: ID!, $title: String) {
            updateTopic(topicId: $topicId, participantId: $participantId, title: $title) {
              topic {
                id
              }
              errors
            }
          }
        GRAPHQL
        variables: {
          topicId: topic.id,
          participantId: other_participant.id,
          title: "更新後タイトル",
        },
      )

      data = graphql_data(result)
      expect(data["updateTopic"]["errors"]).to include("自分の対象出しトピックのみ編集できます")
    end

    it "整理フェーズのトピックは参加者なら編集できる" do
      topic = create(:topic, room: room, participant: owner, status: "organizing")

      result = execute_mutation(
        mutation: <<~GRAPHQL,
          mutation UpdateTopic($topicId: ID!, $participantId: ID!, $title: String) {
            updateTopic(topicId: $topicId, participantId: $participantId, title: $title) {
              topic {
                id
                title
              }
              errors
            }
          }
        GRAPHQL
        variables: {
          topicId: topic.id,
          participantId: other_participant.id,
          title: "更新後タイトル",
        },
      )

      data = graphql_data(result)
      expect(data["updateTopic"]["topic"]["title"]).to eq("更新後タイトル")
      expect(data["updateTopic"]["errors"]).to eq([])
    end
  end
end
