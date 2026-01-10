require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'バリデーション' do
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:google_uid) }
    it { should validate_uniqueness_of(:email) }
    it { should validate_uniqueness_of(:google_uid) }
  end

  describe '属性' do
    it 'email、name、google_uidが必須である' do
      user = User.new
      expect(user).not_to be_valid
      expect(user.errors[:email]).to be_present
      expect(user.errors[:name]).to be_present
      expect(user.errors[:google_uid]).to be_present
    end

    it 'emailとgoogle_uidは一意である必要がある' do
      existing_user = create(:user)
      duplicate_user = User.new(
        email: existing_user.email,
        name: 'Another User',
        google_uid: existing_user.google_uid
      )
      expect(duplicate_user).not_to be_valid
    end
  end
end
