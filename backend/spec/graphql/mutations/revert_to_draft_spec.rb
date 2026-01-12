require "rails_helper"

RSpec.describe Mutations::RevertToDraft, type: :graphql do
  describe "#resolve" do
    it "整理フェーズのトピックを対象出しに戻す" do
      topic = create(:topic, status: "organizing")

      result = execute_mutation(
        mutation: <<~GRAPHQL,
          mutation RevertToDraft($topicId: ID!) {
            revertToDraft(topicId: $topicId) {
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
      expect(data["revertToDraft"]["topic"]["id"]).to eq(topic.id)
      expect(data["revertToDraft"]["topic"]["status"]).to eq("DRAFT")
      expect(data["revertToDraft"]["errors"]).to eq([])
    end

    it "整理フェーズ以外のトピックは戻せない" do
      topic = create(:topic, status: "current_voting")

      result = execute_mutation(
        mutation: <<~GRAPHQL,
          mutation RevertToDraft($topicId: ID!) {
            revertToDraft(topicId: $topicId) {
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
      expect(data["revertToDraft"]["errors"]).to include("整理フェーズのトピックのみ対象出しに戻せます")
    end
  end
end
