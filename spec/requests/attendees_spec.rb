require 'rails_helper'
include JwtToken

RSpec.describe AttendeesController, type: :controller do
  let(:admin) { create(:user, role: 'admin') }
  let(:host) { create(:user) }
  let(:co_host) { create(:user) }
  let(:my_user) { create(:user) }
  let(:event) { create(:event) }
  let(:host_attendee) { create(:attendee, user: host, event: event, role: 'host') }
  let(:co_host_attendee) { create(:attendee, user: co_host, event: event, role: 'co-host') }
  let(:simple_attendee) { create(:attendee, user: my_user, event: event) }
  let(:host_headers) { { 'Authorization': "Bearer #{jwt_encode(host.id, 'user')}" } }
  let(:co_host_headers) { { 'Authorization': "Bearer #{jwt_encode(co_host.id, 'user')}" } }
  let(:attendee_headers) { { 'Authorization': "Bearer #{jwt_encode(my_user.id, 'user')}" } }
  let(:admin_headers) { { 'Authorization': "Bearer #{jwt_encode(admin.id, 'admin')}" } }

  describe 'GET #index' do
    let(:attendees) { create_list(:attendee, 3, event: event) }
    context 'when the event has attendees' do
      before do
        attendees
        get :index, params: { event_id: event.id }
      end
      it 'returns a success response' do
        get :index, params: { event_id: event.id }
        expect(response).to have_http_status(:ok)
      end

      it 'returns all attendees for the specified event' do
        get :index, params: { event_id: event.id }
        expect(JSON.parse(response.body).size).to eq(3)
      end
    end

    context 'when the group does not have any members' do
      it 'returns an empty array' do
        get :index, params: { event_id: event.id }
        expect(JSON.parse(response.body).size).to eq(0)
      end
    end
  end

  describe 'POST #create' do
    let(:user) { create(:user) }
    let(:attendee_params) { attributes_for(:attendee, event_id: event.id) }
    let(:create_params) { { event_id: event.id, attendee: attendee_params } }
    let(:user_headers) { { 'Authorization': "Bearer #{jwt_encode(user.id, 'user')}" } }

    context 'when user is authenticated' do
      before { request.headers.merge!(user_headers) }

      context 'with valid params' do
        it 'creates a new attendee' do
          expect do
            post :create, params: create_params
          end.to change(Attendee, :count).by(1)
        end

        it 'returns a success response' do
          post :create, params: create_params
          expect(response).to have_http_status(:ok)
        end

        it 'returns a JSON response with the new attendee' do
          post :create, params: create_params
          response_body = JSON.parse(response.body)
          expect(response_body['user_id']).to eq(user.id)
          expect(response_body['event_id']).to eq(event.id)
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
    before { host_attendee && co_host_attendee && simple_attendee }

    context 'when user is authenticated' do
      context 'when user is the host' do
        before { request.headers.merge! host_headers }

        context 'with valid params' do
          it 'updates the attendee role' do
            put :update, params: { event_id: event.id, id: simple_attendee.id, attendee: { role: 'co-host' } }
            expect(simple_attendee.reload.role).to eq('co-host')
          end

          it 'returns a success response' do
            put :update, params: { event_id: event.id, id: simple_attendee.id, attendee: { role: 'co-host' } }
            expect(response).to have_http_status(:ok)
          end
        end

        context 'with invalid params' do
          it 'does not update the attendee role' do
            put :update, params: { event_id: event.id, id: simple_attendee.id, attendee: { role: nil } }

            expect(event.reload.updated_at).to eq(event.updated_at)
          end
          it 'returns an unprocessable_entity response' do
            put :update, params: { event_id: event.id, id: simple_attendee.id, attendee: { role: nil } }

            expect(response).to have_http_status(:unprocessable_entity)
          end
        end
      end

      context 'when user is the co-host' do
        before { request.headers.merge! co_host_headers }

        context 'with valid params' do
          it 'updates the attendee role' do
            put :update, params: { event_id: event.id, id: simple_attendee.id, attendee: { role: 'co-host' } }
            expect(simple_attendee.reload.role).to eq('co-host')
          end

          it 'returns a success response' do
            put :update, params: { event_id: event.id, id: simple_attendee.id, attendee: { role: 'co-host' } }
            expect(response).to have_http_status(:ok)
          end
        end

        context 'with invalid params' do
          it 'does not update the attendee role' do
            put :update, params: { event_id: event.id, id: simple_attendee.id, attendee: { role: nil } }

            expect(event.reload.updated_at).to eq(event.updated_at)
          end

          it 'can not change to host role' do
            put :update, params: { event_id: event.id, id: simple_attendee.id, attendee: { role: 'host' } }

            expect(event.reload.updated_at).to eq(event.updated_at)
          end

          it 'returns an unprocessable_entity response' do
            put :update, params: { event_id: event.id, id: simple_attendee.id, attendee: { role: nil } }

            expect(response).to have_http_status(:unprocessable_entity)
          end
        end
      end

      context 'when user is the attendee' do
        before { request.headers.merge! attendee_headers }
        it 'does not update the attendee role' do
          put :update, params: { event_id: event.id, id: simple_attendee.id, attendee: { role: 'co-host' } }

          expect(event.reload.updated_at).to eq(event.updated_at)
        end
        it 'returns an unprocessable_entity response' do
          put :update, params: { event_id: event.id, id: simple_attendee.id, attendee: { role: 'co-host' } }

          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context 'when admin is authenticated' do
      before { request.headers.merge! admin_headers }
      it 'updates the attendee role' do
        put :update, params: { event_id: event.id, id: simple_attendee.id, attendee: { role: 'co-host' } }
        expect(simple_attendee.reload.role).to eq('co-host')
      end

      it 'returns a success response' do
        put :update, params: { event_id: event.id, id: simple_attendee.id, attendee: { role: 'co-host' } }
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when user is not authenticated' do
      it 'does not update the attendee role' do
        put :update, params: { event_id: event.id, id: simple_attendee.id, attendee: { role: 'co-host' } }

        expect(event.reload.updated_at).to eq(event.updated_at)
      end
      it 'returns an unprocessable_entity response' do
        put :update, params: { event_id: event.id, id: simple_attendee.id, attendee: { role: 'co-host' } }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE #destroy' do
    before { host_attendee && co_host_attendee && simple_attendee }

    context 'when user is authenticated' do
      context 'when user is the host' do
        before { request.headers.merge! host_headers }

        it 'deletes the attendee' do
          expect do
            delete :destroy, params: { id: simple_attendee.id, event_id: event.id }
          end.to change(Attendee, :count).by(-1)
        end
        it 'returns a success response' do
          delete :destroy, params: { id: simple_attendee.id, event_id: event.id }

          expect(response).to have_http_status(:ok)
        end
      end

      context 'when user is the attendee' do
        before { request.headers.merge! attendee_headers }

        context 'and he is trying to remove himself from the event ' do
          it 'deletes the attendee' do
            expect do
              delete :destroy, params: { id: simple_attendee.id, event_id: event.id }
            end.to change(Attendee, :count).by(-1)
          end

          it 'returns a success response' do
            delete :destroy, params: { id: simple_attendee.id, event_id: event.id }

            expect(response).to have_http_status(:ok)
          end
        end

        context 'and he is trying to remove someone else from the event ' do
          it 'does not delete the attendee' do
            expect do
              delete :destroy, params: { id: host_attendee.id, event_id: event.id }
            end.not_to change(Attendee, :count)
          end
        end
      end

      context 'when admin is authenticated' do
        before { request.headers.merge! admin_headers }
        it 'deletes the attendee' do
          expect do
            delete :destroy, params: { id: simple_attendee.id, event_id: event.id }
          end.to change(Attendee, :count).by(-1)
        end

        it 'returns a success response' do
          delete :destroy, params: { id: simple_attendee.id, event_id: event.id }

          expect(response).to have_http_status(:ok)
        end
      end

      context 'when user is not authenticated' do
        it 'returns unauthorized status' do
          delete :destroy, params: { id: simple_attendee.id, event_id: event.id }
          expect(response).to have_http_status(:unauthorized)
        end

        it 'does not delete the attendee' do
          expect do
            delete :destroy, params: { id: simple_attendee.id, event_id: event.id }
          end.not_to change(Attendee, :count)
        end
      end
    end
  end
end
