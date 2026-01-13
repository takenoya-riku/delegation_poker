require "rails_helper"

RSpec.describe Mutations::StartDesiredStateVoting, type: :graphql do
  describe "#resolve" do
    it "現状確認結果公開済みのトピックをありたい姿投票に進める" do
      topic = create(:topic, status: "current_revealed")

      result = execute_mutation(
        mutation: <<~GRAPHQL,
          mutation StartDesiredStateVoting($topicId: ID!) {
            startDesiredStateVoting(topicId: $topicId) {
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
      expect(data["startDesiredStateVoting"]["topic"]["status"]).to eq("DESIRED_VOTING")
      expect(data["startDesiredStateVoting"]["errors"]).to eq([])
    end

    it "現状確認結果公開済み以外のトピックはエラーを返す" do
      topic = create(:topic, status: "current_voting")

      result = execute_mutation(
        mutation: <<~GRAPHQL,
          mutation StartDesiredStateVoting($topicId: ID!) {
            startDesiredStateVoting(topicId: $topicId) {
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
      expect(data["startDesiredStateVoting"]["errors"]).to include("現状確認結果が公開済みのトピックのみ、ありたい姿投票を開始できます")
    end
  end
end
