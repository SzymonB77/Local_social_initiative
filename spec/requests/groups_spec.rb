require 'rails_helper'
include JwtToken

RSpec.describe GroupsController, type: :controller do
  let(:group) { create(:group) }
  let(:user_headers) { { 'Authorization': "Bearer #{jwt_encode(user.id, 'user')}" } }  
  let(:user) { create(:user) }
  let(:member) { create(:user) }
  let(:organizer) { create(:user) }
  let(:co_organizer) { create(:user) }
  let(:admin) { create(:user, role: 'admin') }
  let(:organizer_member) { create(:member, group: group, user: organizer, role: 'organizer') }
  let(:co_organizer_member) { create(:member, group: group, user: co_organizer, role: 'co-organizer') }
  let(:simple_member) { create(:member, group: group, user: member) }
  let(:admin_member) { create(:member, group: group, user: admin, role: 'member') }
  let(:organizer_headers) { { 'Authorization': "Bearer #{jwt_encode(organizer.id, 'user')}" } }
  let(:co_organizer_headers) { { 'Authorization': "Bearer #{jwt_encode(co_organizer.id, 'user')}" } }
  let(:member_headers)  { { 'Authorization': "Bearer #{jwt_encode(member.id, 'user')}" } }
  let(:admin_headers) { { 'Authorization': "Bearer #{jwt_encode(admin.id, 'admin')}" } }

  
  describe 'GET #index' do
    let(:groups) { create_list(:group, 3) }
    before do
      groups
      get :index
    end

    it { is_expected.to respond_with 200 }

    it 'returns all groups' do
      expect(JSON.parse(response.body).size).to eq(3)
    end
  end

  describe 'GET #show' do
    let(:members) { create_list(:member, 4, group: group) }

    before { members }
    
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

    context 'when group does not exist' do
      before { get :show, params: { id: 0 } }

      it { is_expected.to respond_with 404 }

      it 'returns error message' do
        expect(response.body).to eq({ error: 'Group not found' }.to_json)
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


      before { request.headers.merge! user_headers }

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


      before { request.headers.merge! admin_headers }

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
    let(:new_group_name) { 'New Group Name' }
    let(:valid_params) { { id: group.id, group: { name: new_group_name } } }

    before { organizer_member && co_organizer_member && admin_member && simple_member && group }
    
    context 'when user is not authenticated' do
      before { put :update, params: valid_params }

      it 'returns unauthorized status' do
        expect(response).to have_http_status(:unauthorized)
      end

      it 'does not update the group' do
        expect(group.reload.updated_at).to eq(group.updated_at)
      end
    end

    context 'when user is authenticated' do
      context 'and is not a member of the group' do
        before do 
          request.headers.merge! user_headers 
          put :update, params: valid_params
        end

        it 'returns unauthorized status' do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'does not update the group' do
          expect(group.reload.updated_at).to eq(group.updated_at)
        end
      end

      context 'and is a member of the group' do
        context 'as a non-organizer' do
          before do
            request.headers.merge! member_headers
            put :update, params: valid_params
          end
          it 'returns unauthorized status' do
            expect(response).to have_http_status(:unprocessable_entity)
          end

          it 'does not update the group' do
            expect(group.reload.updated_at).to eq(group.updated_at)
          end
        end

        context 'as an organizer' do
          before do
            request.headers.merge! organizer_headers
            put :update, params: valid_params
          end

          context 'with valid params' do
            it 'returns success status' do
              expect(response).to have_http_status(:ok)
            end

            it 'updates the group' do
              expect(group.reload.name).to eq(new_group_name)
            end
          end

          context 'with invalid params' do
            let(:invalid_name) { nil }

            before do
              request.headers.merge! organizer_headers
               put :update, params: { id: group.id, group: { name: invalid_name } }
            end
            it 'returns unprocessable_entity status' do
              expect(response).to have_http_status(:unprocessable_entity)
            end

            it 'does not update the group' do
              expect(group.reload.updated_at).to eq(group.updated_at)
            end
          end
        end
      end
    end

    context 'when admin is authenticated' do

      before { request.headers.merge! admin_headers }

      context 'when admin is not a member of the group' do
 
        it 'returns a success response' do
          put :update, params: valid_params
          expect(response).to have_http_status(:ok)
        end

        it 'updates the group' do
          put :update, params: valid_params
          expect(group.reload.name).to eq(new_group_name)
        end
      end
    end
  end

  describe 'DELETE #destroy' do

    before { organizer_member && co_organizer_member && admin_member && simple_member }

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
        before { request.headers.merge! member_headers }

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
        before { request.headers.merge! organizer_headers }

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
        before { request.headers.merge! co_organizer_headers }
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
