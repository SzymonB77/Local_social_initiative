require 'rails_helper'

RSpec.describe Attendee, type: :model do
  describe 'validations' do
    let(:event) { create(:event) }
    let(:user) { create(:user) }
    let(:host_attendee) { create(:attendee, :host, user: user, event: event) }
    let(:attendee) { create(:attendee, user: user, event: event) }

    it 'is valid with valid attributes' do
      expect(host_attendee).to be_valid
    end

    it 'is not valid without a role' do
      host_attendee.role = nil
      expect(host_attendee).not_to be_valid
    end

    it 'is not valid with an invalid role' do
      host_attendee.role = 'invalid'
      expect(host_attendee).not_to be_valid
    end

    it 'is not valid without a user' do
      host_attendee.user = nil
      expect(host_attendee).not_to be_valid
    end

    it 'is not valid without an event' do
      host_attendee.event = nil
      expect(host_attendee).not_to be_valid
    end

    it 'is not valid with a duplicate user and event' do
      attendee
      duplicate_attendee = build(:attendee, :host, user: user, event: event)
      expect(duplicate_attendee).not_to be_valid
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:event) }
  end
end
