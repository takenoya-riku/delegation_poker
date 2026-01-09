require 'rails_helper'

RSpec.describe Mutations::JoinRoom, type: :graphql do
  describe '#resolve' do
    let(:room) { create(:room) }

    it 'ルームに参加する' do
      result = execute_mutation(
        mutation: <<~GRAPHQL,
          mutation JoinRoom($code: String!, $name: String!) {
            joinRoom(code: $code, name: $name) {
              participant {
                id
                name
              }
              room {
                id
                code
              }
              errors
            }
          }
        GRAPHQL
        variables: { code: room.code, name: 'Test Participant' }
      )

      data = graphql_data(result)
      expect(data).to be_present
      expect(data['joinRoom']['participant']['name']).to eq('Test Participant')
      expect(data['joinRoom']['room']['code']).to eq(room.code)
      expect(data['joinRoom']['errors']).to eq([])
    end

    it '存在しないルームコードの場合エラーを返す' do
      result = execute_mutation(
        mutation: <<~GRAPHQL,
          mutation JoinRoom($code: String!, $name: String!) {
            joinRoom(code: $code, name: $name) {
              participant {
                id
              }
              errors
            }
          }
        GRAPHQL
        variables: { code: 'INVALID', name: 'Test Participant' }
      )

      data = graphql_data(result)
      expect(data['joinRoom']['errors']).to include('ルームが見つかりません')
    end
  end
end
