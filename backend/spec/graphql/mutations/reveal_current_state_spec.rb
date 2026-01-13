require "rails_helper"

RSpec.describe Mutations::RevealCurrentState, type: :graphql do
  describe "#resolve" do
    it "現状確認投票中のトピックを公開できる" do
      topic = create(:topic, status: "current_voting")

      result = execute_mutation(
        mutation: <<~GRAPHQL,
          mutation RevealCurrentState($topicId: ID!) {
            revealCurrentState(topicId: $topicId) {
              topic {
                id
                status
              }
              errors
            }
          }
        GRAPHQL
        variables: { topicId: topic.id },
      )

      data = graphql_data(result)
      expect(data["revealCurrentState"]["topic"]["status"]).to eq("CURRENT_REVEALED")
      expect(data["revealCurrentState"]["errors"]).to eq([])
    end

    it "現状確認投票中以外のトピックはエラーを返す" do
      topic = create(:topic, status: "organizing")

      result = execute_mutation(
        mutation: <<~GRAPHQL,
          mutation RevealCurrentState($topicId: ID!) {
            revealCurrentState(topicId: $topicId) {
              topic {
                id
              }
              errors
            }
          }
        GRAPHQL
        variables: { topicId: topic.id },
      )

      data = graphql_data(result)
      expect(data["revealCurrentState"]["errors"]).to include("現状確認投票中のトピックのみ公開できます")
    end
  end
end
