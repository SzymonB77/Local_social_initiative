require 'rails_helper'
include JwtToken

RSpec.describe EventsController, type: :controller do
  let(:admin) { create(:user, role: 'admin') }
  let(:host) { create(:user) }
  let(:co_host) { create(:user) }
  let(:attendee) { create(:user) }
  let(:user) { create(:user) }
  let(:event) { create(:event) }
  let(:admin_headers) { { 'Authorization': "Bearer #{jwt_encode(admin.id, 'admin')}" } }
  let(:user_headers) { { 'Authorization': "Bearer #{jwt_encode(user.id, 'user')}" } }
  let(:host_headers) { { 'Authorization': "Bearer #{jwt_encode(host.id, 'user')}" } }
  let(:co_host_headers) { { 'Authorization': "Bearer #{jwt_encode(co_host.id, 'user')}" } }
  let(:attendee_headers)  { { 'Authorization': "Bearer #{jwt_encode(attendee.id, 'user')}" } }
  let(:host_attendee) { create(:attendee, event: event, user: host, role: 'host') }
  let(:co_host_attendee) { create(:attendee, event: event, user: co_host, role: 'co-host') }
  let(:simple_attendee) { create(:attendee, event: event, user: attendee) }

  describe 'GET #index' do
    let(:events) { create_list(:event, 3) }
    
    context 'when events exist' do
      before { events }
      before { get :index }

      it { is_expected.to respond_with 200 }

      it 'returns all events' do
        expect(JSON.parse(response.body).size).to eq(3)
      end
    end

    context 'when there are no events' do
      it 'returns a success response' do
        get :index
        expect(response).to have_http_status(:ok)
      end

      it 'returns an empty array' do
        get :index
        expect(JSON.parse(response.body)).to be_empty
      end
    end
  end

  describe 'GET #show' do
    let(:attendees) { create_list(:attendee, 3, event: event) }
    let(:photos) { create_list(:photo, 5, event: event, user: user) }

    before { attendees && photos }

    context 'when user is authenticated' do
      before do 
        request.headers.merge! user_headers
        get :show, params: { id: event.id }
      end

      it 'returns a success response' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns the event details' do
        response_body = JSON.parse(response.body)
        expect(response_body['id']).to eq(event.id)
        expect(response_body['name']).to eq(event.name)
        expect(response_body['start_date']).to eq(event.start_date.as_json)
        expect(response_body['end_date']).to eq(event.end_date.as_json)
        expect(response_body['status']).to eq(event.status)
        expect(response_body['location']).to eq(event.location)
        expect(response_body['description']).to eq(event.description)
      end

      it 'returns all associated photos' do
        response_body = JSON.parse(response.body)
        expect(response_body['photos'].size).to eq(5)
      end

      it 'returns all associated attendees' do
        response_body = JSON.parse(response.body)
        expect(response_body['attendees'].size).to eq(3)
      end
    end

    context 'when user is not authenticated' do
      it 'returns a success response' do
        get :show, params: { id: event.id }
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when event does not exist' do
      before { get :show, params: { id: 0 } }

      it { is_expected.to respond_with 404 }

      it 'returns error message' do
        expect(response.body).to eq({ error: 'Event not found' }.to_json)
      end
    end
  end

  describe 'POST #create' do
    let(:event_params) { attributes_for(:event) }

    context 'when user is authenticated and parameters are valid' do

      before { request.headers.merge! user_headers }

      it 'creates a new event' do
        expect do
          post :create, params: { event: event_params }
        end.to change(Event, :count).by(1)
      end

      it 'adds the current user as an attendee to the new event with role `host`' do
        post :create, params: { event: event_params }
        event = Event.last
        expect(event.attendees.last.user).to eq(user)
        expect(event.attendees.last.role).to eq('host')
      end

      it 'returns status code 200 and the created event' do
        post :create, params: { event: event_params }
        expect(response).to have_http_status(:ok)
      end

      it 'returns deatails of the created event' do
        post :create, params: { event: event_params }
        response_body = JSON.parse(response.body)
        expect(response_body['name']).to eq(event_params[:name])
        expect(response_body['status']).to eq(event_params[:status])
        expect(response_body['location']).to eq(event_params[:location])
        expect(response_body['description']).to eq(event_params[:description])
      end
    end

    context 'when user is authenticated and parameters are valid' do

      before { request.headers.merge! admin_headers }

      it 'creates a new event' do
        expect do
          post :create, params: { event: event_params }
        end.to change(Event, :count).by(1)
      end

      it 'returns status code 200 and the created event' do
        post :create, params: { event: event_params }
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when parameters are invalid' do
      before { request.headers.merge! user_headers }

      let(:invalid_params) { attributes_for(:event, name: nil) }

      it 'does not create a new event' do
        expect do
          post :create, params: { event: invalid_params }
        end.not_to change(Event, :count)
      end

      it 'returns status unprocessable entity' do
        post :create, params: { event: invalid_params }

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when user is not authenticated' do
      it 'returns status code 401' do
        post :create, params: { event: attributes_for(:event) }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'PUT #update' do
    let(:new_name) { 'New Name' }
    let(:new_start_date) { event.start_date + 1.day }
    let(:valid_params) { { id: event.id, event: { name: new_name, start_date: new_start_date } } }

    before { host_attendee && co_host_attendee && simple_attendee && event }

    context 'when user is not authenticated' do
      it 'returns unauthorized status' do
        put :update, params: valid_params
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when user is authenticated' do
      before { request.headers.merge!(user_headers) }

      context 'and is not a attendee of the group' do
        it 'returns unauthorized status' do
          put :update, params: valid_params
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'does not update the event' do
          put :update, params: valid_params
          expect(event.reload.updated_at).to eq(event.updated_at)
        end
      end

      context 'and is a attendee of the group and non-host' do
        before { request.headers.merge!(attendee_headers) }
        it 'returns unauthorized status' do
          put :update, params: valid_params
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'does not update the event' do
          put :update, params: valid_params
          expect(event.reload.updated_at).to eq(event.updated_at)
        end
      end

      context 'as an host' do
        before { request.headers.merge!(host_headers) }

        context 'with valid params' do
          it 'returns success status' do
            put :update, params: valid_params
            expect(response).to have_http_status(:ok)
          end

          it 'updates the event' do
            put :update, params: valid_params
            expect(event.reload.name).to eq(new_name)
          end
        end

        context 'with invalid params' do
          let(:invalid_name) { nil }

          it 'returns unprocessable_entity status' do
            put :update, params: { id: event.id, event: { name: invalid_name } }
            expect(response).to have_http_status(:unprocessable_entity)
          end

          it 'does not update the event' do
            put :update, params: { id: event.id, event: { name: invalid_name } }
            expect(event.reload.updated_at).to eq(event.updated_at)
          end
        end
      end

      context 'as an co-host' do

        before { request.headers.merge!(co_host_headers) }

        context 'with valid params' do
          it 'returns success status' do
            put :update, params: valid_params
            expect(response).to have_http_status(:ok)
          end

          it 'updates the event' do
            put :update, params: valid_params
            expect(event.reload.name).to eq(new_name)
          end
        end
      end
    end

    context 'when admin is authenticated and is not a attendee of the group' do
      before { request.headers.merge!(admin_headers) }
      context 'with valid params' do
        it 'returns success status' do
          put :update, params: valid_params
          expect(response).to have_http_status(:ok)
        end

        it 'updates the event' do
          put :update, params: valid_params
          expect(event.reload.name).to eq(new_name)
        end
      end
    end
  end

  describe 'DELETE #destroy' do

    before { host_attendee && co_host_attendee && simple_attendee && event }

    context 'when user is not authenticated' do
      it 'returns unauthorized status' do
        delete :destroy, params: { id: event.id }
        expect(response).to have_http_status(:unauthorized)
      end

      it 'does not delete the group' do
        expect do
          delete :destroy, params: { id: event.id }
        end.not_to change(Event, :count)
      end
    end

    context 'when user is authenticated' do
      context 'when the user is not a attendee of the event' do
        before { request.headers.merge! user_headers }
        it 'returns forbidden status' do
          delete :destroy, params: { id: event.id }
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'does not delete the group' do
          expect do
            delete :destroy, params: { id: event.id }
          end.not_to change(Event, :count)
        end
      end

      context 'when the user is an host of the event' do
        before { request.headers.merge! host_headers }

        it 'deletes the event' do
          expect do
            delete :destroy, params: { id: event.id }
          end.to change(Event, :count).by(-1)
        end

        it 'returns a success response' do
          delete :destroy, params: { id: event.id }
          expect(response).to have_http_status(:ok)
        end
      end

      context 'when the user is a co-host of the event' do
        before { request.headers.merge! co_host_headers }

        it 'returns forbidden status' do
          delete :destroy, params: { id: event.id }
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'does not delete the event' do
          expect do
            delete :destroy, params: { id: event.id }
          end.not_to change(Group, :count)
        end
      end
    end

    context 'when admin is authenticated' do
      before { request.headers.merge! admin_headers }

      it 'deletes the group' do
        expect do
          delete :destroy, params: { id: event.id }
        end.to change(Event, :count).by(-1)
      end
    end
  end
end
