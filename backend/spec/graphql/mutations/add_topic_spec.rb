require "rails_helper"

RSpec.describe Mutations::AddTopic, type: :graphql do
  describe "#resolve" do
    let(:room) { create(:room) }

    it "トピックを追加する" do
      result = execute_mutation(
        mutation: <<~GRAPHQL,
          mutation AddTopic($roomId: ID!, $title: String!, $description: String) {
            addTopic(roomId: $roomId, title: $title, description: $description) {
              topic {
                id
                title
                description
                status
              }
              errors
            }
          }
        GRAPHQL
        variables: {
          roomId: room.id,
          title: "Test Topic",
          description: "Test Description",
        },
      )

      data = graphql_data(result)
      expect(data).to be_present
      expect(data["addTopic"]["topic"]["title"]).to eq("Test Topic")
      expect(data["addTopic"]["topic"]["description"]).to eq("Test Description")
      expect(data["addTopic"]["topic"]["status"]).to eq("DRAFT")
      expect(data["addTopic"]["errors"]).to eq([])
    end

    it "説明なしでトピックを追加できる" do
      result = execute_mutation(
        mutation: <<~GRAPHQL,
          mutation AddTopic($roomId: ID!, $title: String!) {
            addTopic(roomId: $roomId, title: $title) {
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
          roomId: room.id,
          title: "Test Topic",
        },
      )

      data = graphql_data(result)
      expect(data["addTopic"]["topic"]["title"]).to eq("Test Topic")
      expect(data["addTopic"]["errors"]).to eq([])
    end

    it "存在しないルームIDの場合エラーを返す" do
      result = execute_mutation(
        mutation: <<~GRAPHQL,
          mutation AddTopic($roomId: ID!, $title: String!) {
            addTopic(roomId: $roomId, title: $title) {
              topic {
                id
              }
              errors
            }
          }
        GRAPHQL
        variables: {
          roomId: "00000000-0000-0000-0000-000000000000",
          title: "Test Topic",
        },
      )

      data = graphql_data(result)
      expect(data["addTopic"]["errors"]).to include("ルームが見つかりません")
    end

    it "タイトルが空の場合エラーを返す" do
      result = execute_mutation(
        mutation: <<~GRAPHQL,
          mutation AddTopic($roomId: ID!, $title: String!) {
            addTopic(roomId: $roomId, title: $title) {
              topic {
                id
              }
              errors
            }
          }
        GRAPHQL
        variables: {
          roomId: room.id,
          title: "",
        },
      )

      data = graphql_data(result)
      expect(data["addTopic"]["errors"]).to be_present
    end
  end
end
