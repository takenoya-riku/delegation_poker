require "rails_helper"

RSpec.describe Mutations::RevertToOrganizing, type: :graphql do
  describe "#resolve" do
    let(:room) { create(:room) }
    let(:participant) { create(:participant, room: room) }

    it "投票フェーズのトピックを整理フェーズに戻す" do
      topic = create(:topic, room: room, participant: participant, status: "current_voting")
      create(:vote, topic: topic, participant: participant, vote_type: "current_state")

      result = execute_mutation(
        mutation: <<~GRAPHQL,
          mutation RevertToOrganizing($topicId: ID!) {
            revertToOrganizing(topicId: $topicId) {
              topic {
                id
                status
              }
              errors
            }
          }
        GRAPHQL
        variables: {
          topicId: topic.id,
        },
      )

      data = graphql_data(result)
      expect(data["revertToOrganizing"]["topic"]["status"]).to eq("ORGANIZING")
      expect(data["revertToOrganizing"]["errors"]).to eq([])
    end

    it "投票フェーズ以外のトピックはエラーを返す" do
      topic = create(:topic, room: room, participant: participant, status: "draft")

      result = execute_mutation(
        mutation: <<~GRAPHQL,
          mutation RevertToOrganizing($topicId: ID!) {
            revertToOrganizing(topicId: $topicId) {
              topic {
                id
              }
              errors
            }
          }
        GRAPHQL
        variables: {
          topicId: topic.id,
        },
      )

      data = graphql_data(result)
      expect(data["revertToOrganizing"]["errors"]).to include("投票フェーズのトピックのみ整理フェーズに戻せます")
    end
  end
end
