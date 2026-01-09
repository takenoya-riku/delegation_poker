require 'rails_helper'

RSpec.describe Mutations::Vote, type: :graphql do
  describe '#resolve' do
    let(:room) { create(:room) }
    let(:participant) { create(:participant, room: room) }
    let(:topic) { create(:topic, room: room) }

    it '投票する' do
      result = execute_mutation(
        mutation: <<~GRAPHQL,
          mutation Vote($topicId: ID!, $participantId: ID!, $level: Int!) {
            vote(topicId: $topicId, participantId: $participantId, level: $level) {
              vote {
                id
                level
              }
              errors
            }
          }
        GRAPHQL
        variables: {
          topicId: topic.id,
          participantId: participant.id,
          level: 5
        }
      )

      data = graphql_data(result)
      expect(data).to be_present
      expect(data['vote']['vote']['level']).to eq(5)
      expect(data['vote']['errors']).to eq([])
    end

    it '同じトピックに再度投票すると更新される' do
      create(:vote, topic: topic, participant: participant, level: 3)

      result = execute_mutation(
        mutation: <<~GRAPHQL,
          mutation Vote($topicId: ID!, $participantId: ID!, $level: Int!) {
            vote(topicId: $topicId, participantId: $participantId, level: $level) {
              vote {
                level
              }
              errors
            }
          }
        GRAPHQL
        variables: {
          topicId: topic.id,
          participantId: participant.id,
          level: 7
        }
      )

      data = graphql_data(result)
      expect(data['vote']['vote']['level']).to eq(7)
    end

    it '無効な権限レベルの場合エラーを返す' do
      result = execute_mutation(
        mutation: <<~GRAPHQL,
          mutation Vote($topicId: ID!, $participantId: ID!, $level: Int!) {
            vote(topicId: $topicId, participantId: $participantId, level: $level) {
              vote {
                id
              }
              errors
            }
          }
        GRAPHQL
        variables: {
          topicId: topic.id,
          participantId: participant.id,
          level: 10
        }
      )

      data = graphql_data(result)
      expect(data['vote']['errors']).to be_present
    end
  end
end
