require 'rails_helper'

RSpec.describe User, type: :model do
  describe '#validations' do
    it 'should have a valid factory' do
      user = build :user
      expect(user).to be_valid
    end

    it 'should validate the presence of attributes' do
      user = User.create
      expect(user).not_to be_valid
      expect(user.errors.messages[:login]).to include("can't be blank")
      expect(user.errors.messages[:provider]).to include("can't be blank")
    end

    it 'should validate uniqueness og login' do
      user = create :user
      other_user = build :user, login: user.login
      expect(other_user).not_to be_valid
    end
  end
end
