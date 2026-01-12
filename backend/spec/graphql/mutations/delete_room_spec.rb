require "rails_helper"

RSpec.describe Mutations::DeleteRoom, type: :graphql do
  describe "#resolve" do
    let(:room) { create(:room) }
    let(:master) { create(:participant, room: room) }
    let(:member) { create(:participant, room: room) }

    before do
      room.update!(room_master_id: master.id)
    end

    it "ルームマスターが削除した場合成功を返す" do
      result = execute_mutation(
        mutation: <<~GRAPHQL,
          mutation DeleteRoom($roomId: ID!, $participantId: ID!) {
            deleteRoom(roomId: $roomId, participantId: $participantId) {
              success
              errors
            }
          }
        GRAPHQL
        variables: {
          roomId: room.id,
          participantId: master.id,
        },
      )

      data = graphql_data(result)
      expect(data["deleteRoom"]["success"]).to be true
      expect(data["deleteRoom"]["errors"]).to eq([])
      expect(Room.find_by(id: room.id)).to be_nil
    end

    it "ルームマスター以外が削除した場合エラーを返す" do
      result = execute_mutation(
        mutation: <<~GRAPHQL,
          mutation DeleteRoom($roomId: ID!, $participantId: ID!) {
            deleteRoom(roomId: $roomId, participantId: $participantId) {
              success
              errors
            }
          }
        GRAPHQL
        variables: {
          roomId: room.id,
          participantId: member.id,
        },
      )

      data = graphql_data(result)
      expect(data["deleteRoom"]["success"]).to be false
      expect(data["deleteRoom"]["errors"]).to include("ルームマスターのみ削除できます")
    end

    it "存在しないルームIDの場合エラーを返す" do
      result = execute_mutation(
        mutation: <<~GRAPHQL,
          mutation DeleteRoom($roomId: ID!, $participantId: ID!) {
            deleteRoom(roomId: $roomId, participantId: $participantId) {
              success
              errors
            }
          }
        GRAPHQL
        variables: {
          roomId: "00000000-0000-0000-0000-000000000000",
          participantId: master.id,
        },
      )

      data = graphql_data(result)
      expect(data["deleteRoom"]["success"]).to be false
      expect(data["deleteRoom"]["errors"]).to include("ルームが見つかりません")
    end
  end
end
