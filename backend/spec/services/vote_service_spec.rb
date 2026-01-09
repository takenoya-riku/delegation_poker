require 'rails_helper'

RSpec.describe VoteService, type: :service do
  describe '#call' do
    let(:room) { create(:room) }
    let(:participant) { create(:participant, room: room) }
    let(:topic) { create(:topic, room: room) }

    context '有効なパラメータが渡された場合' do
      it '投票を作成して成功レスポンスを返す' do
        result = VoteService.call(
          topic_id: topic.id,
          participant_id: participant.id,
          level: 5
        )

        expect(result.success).to be true
        expect(result.vote).to be_present
        expect(result.vote.level).to eq(5)
        expect(result.vote.topic_id).to eq(topic.id)
        expect(result.vote.participant_id).to eq(participant.id)
        expect(result.errors).to be_empty
      end

      it '既存の投票がある場合は更新する' do
        existing_vote = create(:vote, topic: topic, participant: participant, level: 3)

        result = VoteService.call(
          topic_id: topic.id,
          participant_id: participant.id,
          level: 7
        )

        expect(result.success).to be true
        expect(result.vote.id).to eq(existing_vote.id)
        expect(result.vote.level).to eq(7)
      end
    end

    context '存在しないトピックIDが渡された場合' do
      it 'エラーメッセージを含む失敗レスポンスを返す' do
        result = VoteService.call(
          topic_id: SecureRandom.uuid,
          participant_id: participant.id,
          level: 5
        )

        expect(result.success).to be false
        expect(result.vote).to be_nil
        expect(result.errors).to include('トピックが見つかりません')
      end
    end

    context '存在しない参加者IDが渡された場合' do
      it 'エラーメッセージを含む失敗レスポンスを返す' do
        result = VoteService.call(
          topic_id: topic.id,
          participant_id: SecureRandom.uuid,
          level: 5
        )

        expect(result.success).to be false
        expect(result.vote).to be_nil
        expect(result.errors).to include('参加者が見つかりません')
      end
    end

    context 'トピックと参加者が異なるルームに属している場合' do
      it 'エラーメッセージを含む失敗レスポンスを返す' do
        other_room = create(:room)
        other_participant = create(:participant, room: other_room)

        result = VoteService.call(
          topic_id: topic.id,
          participant_id: other_participant.id,
          level: 5
        )

        expect(result.success).to be false
        expect(result.vote).to be_nil
        expect(result.errors).to include('トピックと参加者が同じルームに属していません')
      end
    end

    context '無効な投票レベルが渡された場合' do
      it 'エラーメッセージを含む失敗レスポンスを返す' do
        result = VoteService.call(
          topic_id: topic.id,
          participant_id: participant.id,
          level: 0
        )

        expect(result.success).to be false
        expect(result.vote).to be_present
        expect(result.errors).not_to be_empty
      end
    end
  end
end
