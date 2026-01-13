require "rails_helper"

RSpec.describe Mutations::StartOrganizing, type: :graphql do
  describe "#resolve" do
    it "対象出しフェーズのトピックを整理フェーズに移行する" do
      topic = create(:topic, status: "draft")

      result = execute_mutation(
        mutation: <<~GRAPHQL,
          mutation StartOrganizing($topicId: ID!) {
            startOrganizing(topicId: $topicId) {
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
      expect(data["startOrganizing"]["topic"]["status"]).to eq("ORGANIZING")
      expect(data["startOrganizing"]["errors"]).to eq([])
    end

    it "対象出しフェーズ以外のトピックはエラーを返す" do
      topic = create(:topic, status: "organizing")

      result = execute_mutation(
        mutation: <<~GRAPHQL,
          mutation StartOrganizing($topicId: ID!) {
            startOrganizing(topicId: $topicId) {
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
      expect(data["startOrganizing"]["errors"]).to include("対象出しフェーズのトピックのみ整理できます")
    end
  end
end
