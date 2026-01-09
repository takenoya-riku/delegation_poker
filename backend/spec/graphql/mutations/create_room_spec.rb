require 'rails_helper'

RSpec.describe Mutations::CreateRoom, type: :graphql do
  describe '#resolve' do
    it 'ルームを作成する' do
      result = execute_mutation(
        mutation: <<~GRAPHQL,
          mutation CreateRoom($name: String!) {
            createRoom(name: $name) {
              room {
                id
                name
                code
              }
              errors
            }
          }
        GRAPHQL
        variables: { name: 'Test Room' }
      )

      data = graphql_data(result)
      expect(data).to be_present
      expect(data['createRoom']['room']['name']).to eq('Test Room')
      expect(data['createRoom']['room']['code']).to be_present
      expect(data['createRoom']['room']['code'].length).to eq(6)
      expect(data['createRoom']['errors']).to eq([])
    end

    it 'ルーム名が空の場合エラーを返す' do
      result = execute_mutation(
        mutation: <<~GRAPHQL,
          mutation CreateRoom($name: String!) {
            createRoom(name: $name) {
              room {
                id
              }
              errors
            }
          }
        GRAPHQL
        variables: { name: '' }
      )

      data = graphql_data(result)
      if data
        expect(data['createRoom']['errors']).to be_present
      else
        # GraphQLバリデーションエラーの場合
        errors = graphql_errors(result)
        expect(errors).to be_present
      end
    end
  end
end
