require 'rails_helper'

RSpec.describe Member, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:group).counter_cache(:members_count) }
  end

  describe 'validations' do
    let(:group) { create(:group) }
    let(:user) { create(:user) }
    let(:member) { create(:member, user: user, group: group) }
    it { should validate_inclusion_of(:role).in_array(Member::MEMBER_ROLES) }

    it 'is not valid with a duplicate user and group' do
      member
      duplicate_member = build(:member, user: user, group: group)
      expect(duplicate_member).not_to be_valid
    end
  end
end
