require 'rails_helper'
include JwtToken

RSpec.describe MembersController, type: :controller do
  let(:group) { create(:group) }
  let(:admin) { create(:user, role: 'admin') }
  let(:organizer) { create(:user) }
  let(:co_organizer) { create(:user) }
  let(:my_user) { create(:user) }
  let(:group) { create(:group) }
  let(:organizer_member) { create(:member, user: organizer, group: group, role: 'organizer') }
  let(:co_organizer_member) { create(:member, user: co_organizer, group: group, role: 'co-organizer') }
  let(:simple_member) { create(:member, user: my_user, group: group) }
  let(:admin_token) { jwt_encode(admin.id, 'admin') }
  let(:organizer_token) { jwt_encode(organizer.id, 'user') }
  let(:co_organizer_token) { jwt_encode(co_organizer.id, 'user') }
  let(:user_token) { jwt_encode(my_user.id, 'user') }

  describe 'GET #index' do
    let(:members) { create_list(:member, 3, group: group) }
    context 'when the group has members' do    
      before do
        members
        get :index, params: { group_id: group.id }
      end
      it { is_expected.to respond_with 200 }

      it 'returns all members for the specified group' do
        expect(JSON.parse(response.body).size).to eq(3)
      end
    end

    context 'when the group does not have any members' do
      it 'returns an empty array' do
        get :index, params: { group_id: group.id }
        expect(JSON.parse(response.body).size).to eq(0)
      end
    end
  end

  describe 'POST #create' do
    let(:user) { create(:user) }
    let(:member_params) { attributes_for(:member, group_id: group.id) }
    let(:create_params) { { group_id: group.id, member: member_params } }
    let(:user_token) { jwt_encode(user.id, 'user') }

    context 'when user is authenticated' do
      before { request.headers.merge! 'Authorization' => "Bearer #{user_token}" }

      context 'with valid params' do
        it 'creates a new member' do
          expect do
            post :create, params: create_params
          end.to change(Member, :count).by(1)
        end

        it 'returns a success response' do
          post :create, params: create_params
          expect(response).to have_http_status(:ok)
        end

        it 'returns a JSON response with the new member' do
          post :create, params: create_params
          response_body = JSON.parse(response.body)
          expect(response_body['user_id']).to eq(user.id)
          expect(response_body['group_id']).to eq(group.id)
        end
      end
    end

    context 'when user is not authenticated' do
      it 'returns unauthorized status' do
        post :create, params: create_params
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'PUT #update' do

    before { organizer_member && co_organizer_member && simple_member }

    context 'when user is authenticated' do
      context 'when user is the organizer' do
        before { request.headers.merge! 'Authorization' => "Bearer #{organizer_token}" }

        context 'with valid params' do
          before { put :update, params: { group_id: group.id, id: simple_member.id, member: { role: 'co-organizer' } }        }
          it 'updates the member role' do
            expect(simple_member.reload.role).to eq('co-organizer')
          end
          it 'returns a success response' do
            expect(response).to have_http_status(:ok)
          end
        end

        context 'with invalid params' do
          before { put :update, params: { group_id: group.id, id: simple_member.id, member: { role: nil } }        }

          it 'does not update the member role' do
            expect(group.reload.updated_at).to eq(group.updated_at)
          end
          it 'returns an unprocessable_entity response' do
            expect(response).to have_http_status(:unprocessable_entity)
          end
        end
      end

      context 'when user is the co-organizer' do
        before { request.headers.merge! 'Authorization' => "Bearer #{co_organizer_token}" }

        context 'with valid params' do
          before { put :update, params: { group_id: group.id, id: simple_member.id, member: { role: 'co-organizer' } }        }
          it 'updates the member role' do
            expect(simple_member.reload.role).to eq('co-organizer')
          end

          it 'returns a success response' do
            expect(response).to have_http_status(:ok)
          end
        end

        context 'with invalid params' do
          it 'does not update the member role' do
            put :update, params: { group_id: group.id, id: simple_member.id, member: { role: nil } }

            expect(group.reload.updated_at).to eq(group.updated_at)
          end

          it 'can not change to organizer role' do
            put :update, params: { group_id: group.id, id: simple_member.id, member: { role: 'organizer' } }

            expect(group.reload.updated_at).to eq(group.updated_at)
          end

          it 'returns an unprocessable_entity response' do
            put :update, params: { group_id: group.id, id: simple_member.id, member: { role: nil } }

            expect(response).to have_http_status(:unprocessable_entity)
          end
        end
      end

      context 'when user is the member' do
        before do 
          request.headers.merge! 'Authorization' => "Bearer #{user_token}" 
          put :update, params: { group_id: group.id, id: simple_member.id, member: { role: 'co-organizer' } }
        end

        it 'does not update the member role' do
          expect(group.reload.updated_at).to eq(group.updated_at)
        end
        it 'returns an unprocessable_entity response' do
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context 'when admin is authenticated' do
      before do 
        request.headers.merge! 'Authorization' => "Bearer #{admin_token}" 
        put :update, params: { group_id: group.id, id: simple_member.id, member: { role: 'co-organizer' } }
      end

      it 'updates the member role' do
        expect(simple_member.reload.role).to eq('co-organizer')
      end

      it 'returns a success response' do
        put :update, params: { group_id: group.id, id: simple_member.id, member: { role: 'co-organizer' } }
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when user is not authenticated' do
      before { put :update, params: { group_id: group.id, id: simple_member.id, member: { role: 'co-organizer' } }    }
      it 'does not update the member role' do
        expect(group.reload.updated_at).to eq(group.updated_at)
      end
      it 'returns an unprocessable_entity response' do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE #destroy' do
    
    before { organizer_member && co_organizer_member && simple_member }

    context 'when user is authenticated' do
      context 'when user is the organizer' do
        before { request.headers.merge! 'Authorization' => "Bearer #{organizer_token}" }

        it 'deletes the member' do
          expect do
            delete :destroy, params: { id: simple_member.id, group_id: group.id }
          end.to change(Member, :count).by(-1)
        end
        it 'returns a success response' do
          delete :destroy, params: { id: simple_member.id, group_id: group.id }

          expect(response).to have_http_status(:ok)
        end
      end

      context 'when user is the member' do
        before { request.headers.merge! 'Authorization' => "Bearer #{user_token}" }

        context 'and he is trying to remove himself from the group ' do
          it 'deletes the member' do
            expect do
              delete :destroy, params: { id: simple_member.id, group_id: group.id }
            end.to change(Member, :count).by(-1)
          end

          it 'returns a success response' do
            delete :destroy, params: { id: simple_member.id, group_id: group.id }

            expect(response).to have_http_status(:ok)
          end
        end

        context 'and he is trying to remove someone else from the group ' do
          it 'does not delete the member' do
            expect do
              delete :destroy, params: { id: organizer_member.id, group_id: group.id }
            end.not_to change(Member, :count)
          end
        end
      end

      context 'when admin is authenticated' do
        before { request.headers.merge! 'Authorization' => "Bearer #{admin_token}" }
        it 'deletes the member' do
          expect do
            delete :destroy, params: { id: simple_member.id, group_id: group.id }
          end.to change(Member, :count).by(-1)
        end

        it 'returns a success response' do
          delete :destroy, params: { id: simple_member.id, group_id: group.id }

          expect(response).to have_http_status(:ok)
        end
      end

      context 'when user is not authenticated' do
        it 'returns unauthorized status' do
          delete :destroy, params: { id: simple_member.id, group_id: group.id }
          expect(response).to have_http_status(:unauthorized)
        end

        it 'does not delete the member' do
          expect do
            delete :destroy, params: { id: simple_member.id, group_id: group.id }
          end.not_to change(Member, :count)
        end
      end
    end
  end
end
