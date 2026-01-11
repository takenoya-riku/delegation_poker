require "rails_helper"

RSpec.describe Vote, type: :model do
  describe "バリデーション" do
    it { is_expected.to validate_presence_of(:level) }
    it { is_expected.to validate_inclusion_of(:level).in_array([1, 2, 3, 4, 5, 6, 7]) }
  end

  describe "アソシエーション" do
    it { is_expected.to belong_to(:topic) }
    it { is_expected.to belong_to(:participant) }
  end

  describe "ユニーク制約" do
    it "同じトピックと参加者の組み合わせは1つまで" do
      topic = create(:topic)
      participant = create(:participant, room: topic.room)
      create(:vote, topic: topic, participant: participant)

      duplicate_vote = build(:vote, topic: topic, participant: participant)
      expect(duplicate_vote).not_to be_valid
    end
  end

  describe "バリデーション: topic_must_be_voting" do
    it "投票中のトピックにのみ投票できる" do
      topic = create(:topic, status: "current_revealed")
      participant = create(:participant, room: topic.room)
      vote = build(:vote, topic: topic, participant: participant)

      expect(vote).not_to be_valid
      expect(vote.errors[:topic]).to be_present
    end
  end
end
