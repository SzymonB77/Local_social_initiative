require 'rails_helper'

RSpec.describe Tag, type: :model do
  let!(:tag) { create(:tag) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:event_tags).dependent(:destroy) }
    it { is_expected.to have_many(:events).through(:event_tags) }
  end
end
