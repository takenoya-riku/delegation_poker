require "rails_helper"

RSpec.describe Mutations::DeleteTopic, type: :graphql do
  describe "#resolve" do
    let(:room) { create(:room) }
    let(:owner) { create(:participant, room: room) }
    let(:other_participant) { create(:participant, room: room) }

    it "対象出しの自分のトピックを削除できる" do
      topic = create(:topic, room: room, participant: owner, status: "draft")

      result = execute_mutation(
        mutation: <<~GRAPHQL,
          mutation DeleteTopic($topicId: ID!, $participantId: ID!) {
            deleteTopic(topicId: $topicId, participantId: $participantId) {
              success
              errors
            }
          }
        GRAPHQL
        variables: {
          topicId: topic.id,
          participantId: owner.id,
        },
      )

      data = graphql_data(result)
      expect(data["deleteTopic"]["success"]).to be true
      expect(data["deleteTopic"]["errors"]).to eq([])
    end

    it "対象出しの他人のトピックは削除できない" do
      topic = create(:topic, room: room, participant: owner, status: "draft")

      result = execute_mutation(
        mutation: <<~GRAPHQL,
          mutation DeleteTopic($topicId: ID!, $participantId: ID!) {
            deleteTopic(topicId: $topicId, participantId: $participantId) {
              success
              errors
            }
          }
        GRAPHQL
        variables: {
          topicId: topic.id,
          participantId: other_participant.id,
        },
      )

      data = graphql_data(result)
      expect(data["deleteTopic"]["success"]).to be false
      expect(data["deleteTopic"]["errors"]).to include("自分の対象出しトピックのみ削除できます")
    end

    it "整理フェーズのトピックは参加者なら削除できる" do
      topic = create(:topic, room: room, participant: owner, status: "organizing")

      result = execute_mutation(
        mutation: <<~GRAPHQL,
          mutation DeleteTopic($topicId: ID!, $participantId: ID!) {
            deleteTopic(topicId: $topicId, participantId: $participantId) {
              success
              errors
            }
          }
        GRAPHQL
        variables: {
          topicId: topic.id,
          participantId: other_participant.id,
        },
      )

      data = graphql_data(result)
      expect(data["deleteTopic"]["success"]).to be true
      expect(data["deleteTopic"]["errors"]).to eq([])
    end
  end
end
