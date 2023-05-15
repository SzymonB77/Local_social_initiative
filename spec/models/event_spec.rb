require 'rails_helper'

RSpec.describe Event, type: :model do
  describe 'validations' do
    let(:event) { FactoryBot.create(:event) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:start_date) }

    context 'when start_date is in the past' do
      let(:event) { build(:event, start_date: 1.day.ago) }

      it 'is invalid' do
        expect(event).not_to be_valid
        expect(event.errors[:start_date]).to include("can't be in the past")
      end
    end

    context 'when end_date is before start_date' do
      let(:event) { build(:event, start_date: Time.current, end_date: 1.hour.ago) }

      it 'is invalid' do
        expect(event).not_to be_valid
        expect(event.errors[:end_date]).to include("can't be before start date")
      end
    end
  end

  describe 'associations' do
    it { is_expected.to have_many(:attendees).dependent(:destroy) }
    it { is_expected.to have_many(:users).through(:attendees) }
    it { is_expected.to belong_to(:group).optional }
    it { is_expected.to have_many(:event_tags).dependent(:destroy) }
    it { is_expected.to have_many(:tags).through(:event_tags) }
    it { is_expected.to have_many(:photos).dependent(:destroy) }
  end
end
