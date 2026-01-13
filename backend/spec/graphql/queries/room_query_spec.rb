require "rails_helper"

RSpec.describe "Room Query", type: :graphql do
  describe "room" do
    it "ルームコードでルーム情報を取得する" do
      room = create(:room)
      participant = create(:participant, room: room)
      create(:topic, room: room, participant: participant)

      result = execute_graphql(
        query: <<~GRAPHQL,
          query Room($code: String!) {
            room(code: $code) {
              id
              name
              code
              participants {
                id
                name
              }
              topics {
                id
                title
                status
              }
            }
          }
        GRAPHQL
        variables: { code: room.code },
      )

      data = graphql_data(result)
      expect(data).to be_present
      expect(data["room"]["code"]).to eq(room.code)
      expect(data["room"]["name"]).to eq(room.name)
      expect(data["room"]["participants"].length).to eq(1)
      expect(data["room"]["topics"].length).to eq(1)
    end

    it "存在しないルームコードの場合nullを返す" do
      result = execute_graphql(
        query: <<~GRAPHQL,
          query Room($code: String!) {
            room(code: $code) {
              id
            }
          }
        GRAPHQL
        variables: { code: "INVALID" },
      )

      data = graphql_data(result)
      expect(data["room"]).to be_nil
    end

    it "大文字小文字を区別せずにルームコードを検索する" do
      create(:room, code: "ABC123")

      result = execute_graphql(
        query: <<~GRAPHQL,
          query Room($code: String!) {
            room(code: $code) {
              id
              code
            }
          }
        GRAPHQL
        variables: { code: "abc123" },
      )

      data = graphql_data(result)
      expect(data["room"]["code"]).to eq("ABC123")
    end
  end
end
