require 'rails_helper'

RSpec.describe Topic, type: :model do
  describe 'バリデーション' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:status) }
    it { should validate_inclusion_of(:status).in_array(%w[voting revealed]) }
  end

  describe 'アソシエーション' do
    it { should belong_to(:room) }
    it { should have_many(:votes).dependent(:destroy) }
  end

  describe '#reveal!' do
    it 'ステータスをrevealedに変更する' do
      topic = create(:topic, status: 'voting')
      topic.reveal!
      expect(topic.status).to eq('revealed')
    end
  end

  describe '#all_participants_voted?' do
    it 'すべての参加者が投票した場合trueを返す' do
      room = create(:room)
      participant1 = create(:participant, room: room)
      participant2 = create(:participant, room: room)
      topic = create(:topic, room: room)
      create(:vote, topic: topic, participant: participant1)
      create(:vote, topic: topic, participant: participant2)

      expect(topic.all_participants_voted?).to be true
    end

    it '一部の参加者が投票していない場合falseを返す' do
      room = create(:room)
      participant1 = create(:participant, room: room)
      create(:participant, room: room)
      topic = create(:topic, room: room)
      create(:vote, topic: topic, participant: participant1)

      expect(topic.all_participants_voted?).to be false
    end
  end
end
