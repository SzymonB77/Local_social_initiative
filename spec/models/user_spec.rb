require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { FactoryBot.create(:user) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:nickname) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email) }
    it { is_expected.to validate_presence_of(:password).on(:create) }
    it { is_expected.to validate_presence_of(:role) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:attendees).dependent(:destroy) }
    it { is_expected.to have_many(:events).through(:attendees) }
    it { is_expected.to have_many(:members).dependent(:destroy) }
    it { is_expected.to have_many(:groups).through(:members) }
    it { is_expected.to have_many(:photos) }
  end
end
