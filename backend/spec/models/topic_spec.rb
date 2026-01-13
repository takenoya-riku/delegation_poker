require "rails_helper"

RSpec.describe Topic, type: :model do
  subject(:topic) { build(:topic) }

  describe "バリデーション" do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:status) }

    it do
      expect(topic).to validate_inclusion_of(:status).in_array(%w[draft organizing current_voting current_revealed desired_voting desired_revealed completed])
    end
  end

  describe "アソシエーション" do
    it { is_expected.to belong_to(:room) }
    it { is_expected.to belong_to(:participant).optional }
    it { is_expected.to have_many(:votes).dependent(:destroy) }
  end

  describe "#reveal!" do
    it "ステータスをcurrent_revealedに変更する" do
      topic = create(:topic, status: "current_voting")
      topic.reveal!
      expect(topic.status).to eq("current_revealed")
    end
  end

  describe "#all_participants_voted?" do
    it "すべての参加者が投票した場合trueを返す" do
      room = create(:room)
      participant1 = create(:participant, room: room)
      participant2 = create(:participant, room: room)
      topic = create(:topic, room: room)
      create(:vote, topic: topic, participant: participant1)
      create(:vote, topic: topic, participant: participant2)

      expect(topic.all_participants_voted?).to be true
    end

    it "一部の参加者が投票していない場合falseを返す" do
      room = create(:room)
      participant1 = create(:participant, room: room)
      create(:participant, room: room)
      topic = create(:topic, room: room)
      create(:vote, topic: topic, participant: participant1)

      expect(topic.all_participants_voted?).to be false
    end
  end
end
