require "rails_helper"

RSpec.describe Mutations::RevealDesiredState, type: :graphql do
  describe "#resolve" do
    it "理想投票中のトピックを公開できる" do
      topic = create(:topic, status: "desired_voting")

      result = execute_mutation(
        mutation: <<~GRAPHQL,
          mutation RevealDesiredState($topicId: ID!) {
            revealDesiredState(topicId: $topicId) {
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
      expect(data["revealDesiredState"]["topic"]["status"]).to eq("DESIRED_REVEALED")
      expect(data["revealDesiredState"]["errors"]).to eq([])
    end

    it "理想投票中以外のトピックはエラーを返す" do
      topic = create(:topic, status: "current_revealed")

      result = execute_mutation(
        mutation: <<~GRAPHQL,
          mutation RevealDesiredState($topicId: ID!) {
            revealDesiredState(topicId: $topicId) {
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
      expect(data["revealDesiredState"]["errors"]).to include("理想投票中のトピックのみ公開できます")
    end
  end
end
