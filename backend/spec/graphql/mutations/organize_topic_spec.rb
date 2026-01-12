require "rails_helper"

RSpec.describe Mutations::OrganizeTopic, type: :graphql do
  describe "#resolve" do
    it "整理フェーズのトピックを現状確認投票に進める" do
      topic = create(:topic, status: "organizing")

      result = execute_mutation(
        mutation: <<~GRAPHQL,
          mutation OrganizeTopic($topicId: ID!) {
            organizeTopic(topicId: $topicId) {
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
      expect(data).to be_present
      expect(data["organizeTopic"]["topic"]["id"]).to eq(topic.id)
      expect(data["organizeTopic"]["topic"]["status"]).to eq("CURRENT_VOTING")
      expect(data["organizeTopic"]["errors"]).to eq([])
    end

    it "整理フェーズ以外のトピックは現状確認投票に進めない" do
      topic = create(:topic, status: "draft")

      result = execute_mutation(
        mutation: <<~GRAPHQL,
          mutation OrganizeTopic($topicId: ID!) {
            organizeTopic(topicId: $topicId) {
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
      expect(data["organizeTopic"]["errors"]).to include("整理フェーズのトピックのみ現状確認投票に進めます")
    end
  end
end
