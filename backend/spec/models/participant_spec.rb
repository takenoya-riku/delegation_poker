require 'rails_helper'

RSpec.describe Participant, type: :model do
  describe 'バリデーション' do
    it { should validate_presence_of(:name) }
  end

  describe 'アソシエーション' do
    it { should belong_to(:room) }
    it { should have_many(:votes).dependent(:destroy) }
  end
end
