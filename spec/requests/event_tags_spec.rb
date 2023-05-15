require 'rails_helper'
include JwtToken

RSpec.describe EventTagsController, type: :controller do
  let(:event) { create(:event) }
  let(:tag) { create(:tag) }
  let(:host) { create(:user) }
  let(:host_attendee) { create(:attendee, user: host, event: event, role: 'host') }
  let(:host_headers) { { 'Authorization': "Bearer #{jwt_encode(host.id, 'user')}" } }

  describe 'GET /index' do
    let(:tag1) { create(:tag) }
    let(:tag2) { create(:tag) }

    context 'when the event has photos' do
      let(:event_tag1) { create(:event_tag, event: event, tag: tag1) }
      let(:event_tag2) { create(:event_tag, event: event, tag: tag2) }

      before { event_tag1 && event_tag2 }
      before { get :index, params: { event_id: event.id } }

      it 'returns a success response' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns all photos for the specified event' do
        expect(JSON.parse(response.body).size).to eq(2)
      end
    end

    context 'when the event does not have any photos' do
      before { get :index, params: { event_id: event.id } }

      it 'returns a success response' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns an empty array' do
        expect(JSON.parse(response.body).size).to eq(0)
      end
    end
  end

  describe 'POST #create' do
    context 'when user is authenticated' do
      before { host_attendee }

      context 'with valid parameters' do
        let(:valid_params) { { event_tag: { tag: { name: tag.name } }, event_id: event.id } }

        before { request.headers.merge! host_headers }

        it 'creates a new event tag' do
          expect do
            post :create, params: valid_params
          end.to change(EventTag, :count).by(1)
        end

        it 'returns a success response' do
          post :create, params: valid_params
          expect(response).to have_http_status(:ok)
        end

        it 'returns the created event tag' do
          post :create, params: valid_params
          json_response = JSON.parse(response.body)
          expect(json_response['event_id']).to eq(event.id)
          expect(json_response['tag_id']).to eq(tag.id)
        end
      end

      context 'with invalid parameters' do
        let(:invalid_params) { { event_tag: { tag: { name: nil } }, event_id: event.id } }

        before do
          request.headers.merge! host_headers
        end

        it 'does not create a new event tag' do
          expect do
            post :create, params: invalid_params
          end.to_not change(EventTag, :count)
        end

        it 'returns an error response' do
          post :create, params: invalid_params
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context 'when user is not authenticated' do
      let(:valid_params) { { event_tag: { tag: { name: tag.name } }, event_id: event.id } }

      it 'does not create a new event tag' do
        expect do
          post :create, params: valid_params
        end.to_not change(EventTag, :count)
      end

      it 'returns an error response' do
        post :create, params: valid_params
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:event_tag) { create(:event_tag, event: event, tag: tag) }

    before { host_attendee && event_tag }
    context 'when user is authorized' do
      before { request.headers.merge! host_headers }

      it 'deletes the event tag' do
        expect do
          delete :destroy, params: { id: event_tag.id, event_id: event.id }
        end.to change(EventTag, :count).by(-1)
      end

      it 'returns a successful response' do
        delete :destroy, params: { id: event_tag.id, event_id: event.id }
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when user is not authorized' do
      before do
        event_tag
      end
      it 'does not delete the event tag' do
        expect do
          delete :destroy, params: { id: event_tag.id, event_id: event.id }
        end.to_not change(EventTag, :count)
      end

      it 'returns an unauthorized response' do
        delete :destroy, params: { id: event_tag.id, event_id: event.id }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
