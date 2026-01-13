require "rails_helper"

RSpec.describe Participant, type: :model do
  describe "バリデーション" do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe "アソシエーション" do
    it { is_expected.to belong_to(:room) }
    it { is_expected.to have_many(:votes).dependent(:destroy) }
    it { is_expected.to have_many(:topics).dependent(:nullify) }
  end
end
