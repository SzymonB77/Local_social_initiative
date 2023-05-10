require 'rails_helper'

RSpec.describe EventTag, type: :model do
  let(:event) { create(:event) }
  let(:tag) { create(:tag) }
  let(:event_tag) { create(:event_tag, event: event, tag: tag) }

  describe 'associations' do
    it { is_expected.to belong_to(:event) }
    it { is_expected.to belong_to(:tag) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:event) }
    it { is_expected.to validate_presence_of(:tag) }

    it 'is not valid with a duplicate tag and event' do
      event_tag
      duplicate_event_tag = build(:event_tag, tag: tag, event: event)
      expect(duplicate_event_tag).not_to be_valid
    end
  end
end
