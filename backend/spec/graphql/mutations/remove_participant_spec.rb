require "rails_helper"

RSpec.describe Mutations::RemoveParticipant, type: :graphql do
  describe "#resolve" do
    let(:room) { create(:room) }
    let(:master) { create(:participant, room: room) }
    let(:member) { create(:participant, room: room) }

    before do
      room.update!(room_master_id: master.id)
    end

    it "ルームマスターが参加者を削除できる" do
      result = execute_mutation(
        mutation: <<~GRAPHQL,
          mutation RemoveParticipant($roomId: ID!, $participantId: ID!, $targetParticipantId: ID!) {
            removeParticipant(
              roomId: $roomId,
              participantId: $participantId,
              targetParticipantId: $targetParticipantId
            ) {
              success
              errors
            }
          }
        GRAPHQL
        variables: {
          roomId: room.id,
          participantId: master.id,
          targetParticipantId: member.id,
        },
      )

      data = graphql_data(result)
      expect(data["removeParticipant"]["success"]).to be true
      expect(data["removeParticipant"]["errors"]).to eq([])
    end

    it "ルームマスター以外は参加者を削除できない" do
      result = execute_mutation(
        mutation: <<~GRAPHQL,
          mutation RemoveParticipant($roomId: ID!, $participantId: ID!, $targetParticipantId: ID!) {
            removeParticipant(
              roomId: $roomId,
              participantId: $participantId,
              targetParticipantId: $targetParticipantId
            ) {
              success
              errors
            }
          }
        GRAPHQL
        variables: {
          roomId: room.id,
          participantId: member.id,
          targetParticipantId: master.id,
        },
      )

      data = graphql_data(result)
      expect(data["removeParticipant"]["success"]).to be false
      expect(data["removeParticipant"]["errors"]).to include("ルームマスターのみ削除できます")
    end
  end
end
