require 'rails_helper'

RSpec.describe Group, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
  end

  describe 'associations' do
    it { should have_many(:events) }
    it { should have_many(:members).dependent(:destroy) }
    it { should have_many(:users).through(:members) }
  end

  describe 'callbacks' do
    context 'when a new member is added' do
      let(:group) { FactoryBot.create(:group) }
      let(:user) { FactoryBot.create(:user) }

      it 'increments members_count' do
        expect do
          Member.create(user: user, group: group)
          group.reload
        end.to change { group.members_count }.by(1)
      end
    end
  end

  describe 'attributes' do
    it 'has name, description and avatar attributes' do
      expect(subject.attributes).to include('name', 'description', 'avatar')
    end
  end
end
