require 'rails_helper'

RSpec.describe Room, type: :model do
  describe 'バリデーション' do
    it { should validate_presence_of(:name) }
    it { should validate_length_of(:code).is_equal_to(6) }
  end

  describe 'アソシエーション' do
    it { should have_many(:participants).dependent(:destroy) }
    it { should have_many(:topics).dependent(:destroy) }
  end

  describe '#generate_code' do
    it 'ルーム作成時に6桁のコードを自動生成する' do
      room = Room.new(name: 'Test Room')
      room.valid?
      expect(room.code).to be_present
      expect(room.code.length).to eq(6)
    end

    it '生成されたコードは大文字の英数字である' do
      room = Room.new(name: 'Test Room')
      room.valid?
      expect(room.code).to match(/\A[A-Z0-9]{6}\z/)
    end

    it '既存のコードと重複しない' do
      existing_room = create(:room)
      room = Room.new(name: 'Another Room', code: existing_room.code)
      expect(room).not_to be_valid
    end
  end
end
