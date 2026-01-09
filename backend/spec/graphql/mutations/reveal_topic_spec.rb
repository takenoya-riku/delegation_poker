require 'rails_helper'

RSpec.describe Mutations::RevealTopic, type: :graphql do
  describe '#resolve' do
    let(:room) { create(:room) }
    let(:topic) { create(:topic, room: room, status: 'voting') }

    it 'トピックの投票結果を公開する' do
      result = execute_mutation(
        mutation: <<~GRAPHQL,
          mutation RevealTopic($topicId: ID!) {
            revealTopic(topicId: $topicId) {
              topic {
                id
                status
              }
              errors
            }
          }
        GRAPHQL
        variables: { topicId: topic.id }
      )

      data = graphql_data(result)
      expect(data).to be_present
      expect(data['revealTopic']['topic']['status']).to eq('revealed')
      expect(data['revealTopic']['errors']).to eq([])
    end

    it '既に公開されているトピックの場合エラーを返す' do
      topic.update!(status: 'revealed')

      result = execute_mutation(
        mutation: <<~GRAPHQL,
          mutation RevealTopic($topicId: ID!) {
            revealTopic(topicId: $topicId) {
              topic {
                status
              }
              errors
            }
          }
        GRAPHQL
        variables: { topicId: topic.id }
      )

      data = graphql_data(result)
      expect(data['revealTopic']['errors']).to include('既に結果が公開されています')
    end

    it '存在しないトピックIDの場合エラーを返す' do
      result = execute_mutation(
        mutation: <<~GRAPHQL,
          mutation RevealTopic($topicId: ID!) {
            revealTopic(topicId: $topicId) {
              topic {
                id
              }
              errors
            }
          }
        GRAPHQL
        variables: { topicId: '00000000-0000-0000-0000-000000000000' }
      )

      data = graphql_data(result)
      expect(data['revealTopic']['errors']).to include('トピックが見つかりません')
    end
  end
end
