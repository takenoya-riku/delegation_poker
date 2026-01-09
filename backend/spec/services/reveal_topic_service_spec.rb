require 'rails_helper'

RSpec.describe RevealTopicService, type: :service do
  describe '#call' do
    context '投票中のトピックIDが渡された場合' do
      it 'トピックのステータスを公開済みに変更して成功レスポンスを返す' do
        topic = create(:topic, status: 'voting')

        result = RevealTopicService.call(topic_id: topic.id)

        expect(result.success).to be true
        expect(result.topic).to be_present
        expect(result.topic.status).to eq('revealed')
        expect(result.errors).to be_empty
      end
    end

    context '既に公開済みのトピックIDが渡された場合' do
      it 'エラーメッセージを含む失敗レスポンスを返す' do
        topic = create(:topic, status: 'revealed')

        result = RevealTopicService.call(topic_id: topic.id)

        expect(result.success).to be false
        expect(result.topic).to eq(topic)
        expect(result.errors).to include('既に結果が公開されています')
      end
    end

    context '存在しないトピックIDが渡された場合' do
      it 'エラーメッセージを含む失敗レスポンスを返す' do
        result = RevealTopicService.call(topic_id: SecureRandom.uuid)

        expect(result.success).to be false
        expect(result.topic).to be_nil
        expect(result.errors).to include('トピックが見つかりません')
      end
    end
  end
end
