require 'rails_helper'
include JwtToken

RSpec.describe GroupsController, type: :controller do
  describe 'GET #index' do
    let!(:groups) { create_list(:group, 3) }

    it 'returns a success response' do
      get :index
      expect(response).to have_http_status(:ok)
    end

    it 'returns all groups' do
      get :index
      expect(JSON.parse(response.body).size).to eq(3)
    end
  end

  describe 'GET #show' do
    let(:group) { create(:group) }
    let!(:members) { create_list(:member, 4, group: group) }

    context 'when user is not authenticated' do
      it 'returns a success response' do
        get :show, params: { id: group.id }
        expect(response).to have_http_status(:ok)
      end

      it 'returns the group details' do
        get :show, params: { id: group.id }
        response_body = JSON.parse(response.body)
        expect(response_body['id']).to eq(group.id)
        expect(response_body['name']).to eq(group.name)
        expect(response_body['description']).to eq(group.description)
      end

      it 'returns all associated events' do
        3.times { create(:event, group: group) }
        get :show, params: { id: group.id }
        response_body = JSON.parse(response.body)
        expect(response_body['events_planned'].size).to eq(3)
      end

      it 'returns all associated members' do
        get :show, params: { id: group.id }
        response_body = JSON.parse(response.body)
        expect(response_body['members'].size).to eq(4)
      end
    end
  end

  describe 'POST #create' do
    context 'when user is not authenticated' do
      it 'returns unauthorized status' do
        post :create, params: { group: attributes_for(:group) }
        expect(response).to have_http_status(:unauthorized)
      end

      it 'does not create a new group' do
        expect do
          post :create, params: { group: attributes_for(:group) }
        end.not_to change(Group, :count)
      end
    end

    context 'when user is authenticated' do
      let(:user) { create(:user) }
      let(:user_token) { jwt_encode(user.id, 'user') }

      before { request.headers.merge! 'Authorization' => "Bearer #{user_token}" }

      it 'creates a new group' do
        expect do
          post :create, params: { group: attributes_for(:group) }
        end.to change(Group, :count).by(1)
      end

      it 'adds the current user as an organizer to the new group' do
        post :create, params: { group: attributes_for(:group) }
        group = Group.last
        expect(group.members.last.user).to eq(user)
        expect(group.members.last.role).to eq('organizer')
      end

      it 'returns a success response' do
        post :create, params: { group: attributes_for(:group) }
        expect(response).to have_http_status(:ok)
      end

      it 'returns the new group' do
        post :create, params: { group: attributes_for(:group) }
        group = Group.last
        expect(response.body).to eq(GroupSerializer.new(group).to_json)
      end
    end

    context 'when admin is authenticated' do
      let(:admin) { create(:user, role: 'admin') }
      let(:admin_token) { jwt_encode(admin.id, 'admin')  }

      before { request.headers.merge! 'Authorization' => "Bearer #{admin_token}" }

      it 'creates a new group' do
        expect do
          post :create, params: { group: attributes_for(:group) }
        end.to change(Group, :count).by(1)
      end

      it 'adds the current user as an organizer to the new group' do
        post :create, params: { group: attributes_for(:group) }
        group = Group.last
        expect(group.members.last.user).to eq(admin)
        expect(group.members.last.role).to eq('organizer')
      end

      it 'returns a success response' do
        post :create, params: { group: attributes_for(:group) }
        expect(response).to have_http_status(:ok)
      end

      it 'returns the new group' do
        post :create, params: { group: attributes_for(:group) }
        group = Group.last
        expect(response.body).to eq(GroupSerializer.new(group).to_json)
      end
    end
  end

  describe 'PUT #update' do
    let!(:admin) { create(:user, role: 'admin') }
    let!(:user) { create(:user) }
    let!(:group) { create(:group) }
    let(:new_group_name) { 'New Group Name' }
    let(:valid_params) { { id: group.id, group: { name: new_group_name } } }
    let(:admin_headers) { { 'Authorization': "Bearer #{jwt_encode(admin.id, 'admin')}" } }
    let(:user_headers) { { 'Authorization': "Bearer #{jwt_encode(user.id, 'user')}" } }

    context 'when user is not authenticated' do
      it 'returns unauthorized status' do
        put :update, params: valid_params
        expect(response).to have_http_status(:unauthorized)
      end

      it 'does not update the group' do
        put :update, params: valid_params
        expect(group.reload.updated_at).to eq(group.updated_at)
      end
    end

    context 'when user is authenticated' do
      context 'and is not a member of the group' do
        before { request.headers.merge! user_headers }

        it 'returns unauthorized status' do
          put :update, params: valid_params
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'does not update the group' do
          put :update, params: valid_params
          expect(group.reload.updated_at).to eq(group.updated_at)
        end
      end

      context 'and is a member of the group' do
        context 'as a non-organizer' do
          before do
            group.members.create(user_id: user.id, role: 'member')
            request.headers.merge! user_headers
          end
          it 'returns unauthorized status' do
            put :update, params: valid_params
            expect(response).to have_http_status(:unprocessable_entity)
          end

          it 'does not update the group' do
            put :update, params: valid_params
            expect(group.reload.updated_at).to eq(group.updated_at)
          end
        end

        context 'as an organizer' do
          before do
            group.members.create(user_id: user.id, role: 'organizer')
            request.headers.merge! user_headers
          end

          context 'with valid params' do
            it 'returns success status' do
              put :update, params: valid_params
              expect(response).to have_http_status(:ok)
            end

            it 'updates the group' do
              put :update, params: valid_params
              expect(group.reload.name).to eq(new_group_name)
            end
          end

          context 'with invalid params' do
            let(:invalid_name) { nil }

            it 'returns unprocessable_entity status' do
              put :update, params: { id: group.id, group: { name: invalid_name } }
              expect(response).to have_http_status(:unprocessable_entity)
            end

            it 'does not update the group' do
              put :update, params: { id: group.id, group: { name: invalid_name } }
              expect(group.reload.updated_at).to eq(group.updated_at)
            end
          end
        end
      end
    end

    context 'when admin is authenticated' do
      let(:admin_token) { jwt_encode(admin.id, 'admin') }

      before { request.headers.merge! 'Authorization' => "Bearer #{admin_token}" }

      context 'when admin is not a member of the group' do
        let!(:group) { create(:group) }

        it 'returns a success response' do
          put :update, params: valid_params
          expect(response).to have_http_status(:ok)
        end

        it 'updates the group' do
          put :update, params: valid_params
          expect(group.reload.name).to eq(new_group_name)
        end
      end

      context 'when admin is an organizer of the group' do
        it 'updates the group' do
          put :update, params: valid_params
          expect(group.reload.name).to eq(new_group_name)
        end

        it 'returns a success response' do
          put :update, params: valid_params
          expect(response).to have_http_status(:ok)
        end

        it 'returns the updated group' do
          put :update, params: valid_params
          expect(JSON.parse(response.body)['name']).to eq(new_group_name)
        end
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }
    let(:admin) { create(:user, role: 'admin') }
    let(:group) { create(:group) }
    let(:organizer) { create(:member, group: group, user: user1, role: 'organizer') }
    let(:co_organizer) { create(:member, group: group, user: user2, role: 'co-organizer') }
    let(:admin_member) { create(:member, group: group, user: admin, role: 'member') }
    let(:user1_headers) { { 'Authorization': "Bearer #{jwt_encode(user1.id, 'user')}" } }
    let(:user2_headers) { { 'Authorization': "Bearer #{jwt_encode(user2.id, 'user')}" } }
    let(:admin_headers) { { 'Authorization': "Bearer #{jwt_encode(admin.id, 'admin')}" } }

    before do
      organizer
      co_organizer
      admin_member
    end

    context 'when user is not authenticated' do
      it 'returns unauthorized status' do
        delete :destroy, params: { id: group.id }
        expect(response).to have_http_status(:unauthorized)
      end

      it 'does not delete the group' do
        expect do
          delete :destroy, params: { id: group.id }
        end.not_to change(Group, :count)
      end
    end

    context 'when user is authenticated' do
      context 'when the user is not a member of the group' do
        before { request.headers.merge! user1_headers }
        before { request.headers.merge! user2_headers }
        it 'returns forbidden status' do
          delete :destroy, params: { id: group.id }
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'does not delete the group' do
          expect do
            delete :destroy, params: { id: group.id }
          end.not_to change(Group, :count)
        end
      end

      context 'when the user is an organizer of the group' do
        before do
          organizer
          request.headers.merge! user1_headers
        end

        it 'deletes the group' do
          expect do
            delete :destroy, params: { id: group.id }
          end.to change(Group, :count).by(-1)
        end

        it 'returns a success response' do
          delete :destroy, params: { id: group.id }
          expect(response).to have_http_status(:ok)
        end
      end

      context 'when the user is a co-organizer of the group' do
        before do
          co_organizer
          request.headers.merge! user2_headers
        end

        it 'returns forbidden status' do
          delete :destroy, params: { id: group.id }
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'does not delete the group' do
          expect do
            delete :destroy, params: { id: group.id }
          end.not_to change(Group, :count)
        end
      end
    end

    context 'when admin is authenticated' do
      before { request.headers.merge! admin_headers }

      it 'deletes the group' do
        expect do
          delete :destroy, params: { id: group.id }
        end.to change(Group, :count).by(-1)
      end
    end
  end
end
