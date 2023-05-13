require 'rails_helper'
include JwtToken

RSpec.describe PhotosController, type: :controller do
  let(:admin) { create(:user, role: 'admin') }
  let(:host) { create(:user) }
  let(:co_host) { create(:user) }
  let(:my_user) { create(:user) }
  let(:user) { create(:user) }
  let(:event) { create(:event) }
  let(:host_attendee) { create(:attendee, user: host, event: event, role: 'host') }
  let(:co_host_attendee) { create(:attendee, user: co_host, event: event, role: 'co-host') }
  let(:simple_attendee) { create(:attendee, user: my_user, event: event) }
  let(:admin_token) { jwt_encode(admin.id, 'admin') }
  let(:host_token) { jwt_encode(host.id, 'user') }
  let(:co_host_token) { jwt_encode(co_host.id, 'user') }
  let(:user_token) { jwt_encode(my_user.id, 'user') }
  let(:photo) { create(:photo, event: event, user: user) }

  describe 'GET /index' do
    let(:photos) { create_list(:photo, 3, event: event, user: user) }
    context 'when the event has photos' do
      before do
        photos
        get :index, params: { event_id: event.id }
      end

      it { is_expected.to respond_with 200 }

      it 'returns all photos for the specified event' do
        expect(JSON.parse(response.body).size).to eq(3)
      end
    end

    context 'when the event does not have any photos' do
      it 'returns an empty array' do
        get :index, params: { event_id: event.id }
        expect(JSON.parse(response.body).size).to eq(0)
      end
    end
  end

  describe 'GET #show' do
    context 'when photo exists' do
      before { get :show, params: { event_id: event.id, id: photo.id } }

      it { is_expected.to respond_with 200 }

      it 'returns the photo' do
        expect(response.body).to eq(PhotoSerializer.new(photo).to_json)
      end
    end

    context 'when photo does not exist' do
      before { get :show, params: { event_id: event.id, id: 0 } }

      it { is_expected.to respond_with 404 }

      it 'returns error message' do
        expect(response.body).to eq({ error: 'Photo not found' }.to_json)
      end
    end
  end

  describe 'POST #create' do
    context 'when user try to create new photo' do
      let(:request_params) { { event_id: event.id, photo: photo_attributes } }
      let(:photo_attributes) { attributes_for(:photo, user_id: host.id, event_id: event.id) }
      
      before do
        host_attendee
        co_host_attendee
        simple_attendee
      end

      context 'when user is host' do
        before do
           request.headers.merge! 'Authorization' => "Bearer #{host_token}" 
           post :create, params: request_params
        end

        it { is_expected.to respond_with 200 }

        it 'creates a new photo' do
          expect(Photo.count).to eq(1)
        end

        it 'associates the photo with the user and event' do
          expect(Photo.first.user).to eq(host)
          expect(Photo.first.event).to eq(event)
        end

        it 'returns the newly created photo' do
          photo = JSON.parse(response.body)
          expect(photo['url']).to eq(photo_attributes[:url])
        end
      end

      context 'when user is co-host' do
        before do
          request.headers.merge! 'Authorization' => "Bearer #{co_host_token}" 
          post :create, params: request_params
       end

        it 'returns a successful response' do
          expect(response).to have_http_status(:ok)
        end

        it 'creates a new photo' do
          expect(Photo.count).to eq(1)
        end

        it 'associates the photo with the user and event' do
          expect(Photo.first.user).to eq(co_host)
          expect(Photo.first.event).to eq(event)
        end

        it 'returns the newly created photo' do
          photo = JSON.parse(response.body)
          expect(photo['url']).to eq(photo_attributes[:url])
        end
      end

      context 'when user has role admin' do
        before do
          request.headers.merge! 'Authorization' => "Bearer #{admin_token}" 
          post :create, params: request_params
        end

        it 'returns a successful response' do
          expect(response).to have_http_status(:ok)
        end

        it 'creates a new photo' do
          expect(Photo.count).to eq(1)
        end

        it 'associates the photo with the user and event' do
          expect(Photo.first.user).to eq(admin)
          expect(Photo.first.event).to eq(event)
        end

        it 'returns the newly created photo' do
          photo = JSON.parse(response.body)
          expect(photo['url']).to eq(photo_attributes[:url])
        end
      end

      context 'when it s just user' do
        before do
          request.headers.merge! 'Authorization' => "Bearer #{user_token}" 
          post :create, params: request_params
        end

        it 'returns an unauthorized response' do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'does not create a new photo' do
          expect(Photo.count).to eq(0)
        end

        it 'returns an error message' do
          response_body = JSON.parse(response.body)
          expect(response_body['error']).to eq('Unauthorized')
        end
      end

      context 'when user is not authenticated' do
        it 'does not create a new photo' do
          expect(Photo.count).to eq(0)
        end
      end
    end
  end
  describe 'DELETE #destroy' do
    context 'when user tries to delete a photo' do

      let(:request_params) { { event_id: event.id, id: photo.id } }

      before do
        host_attendee
        co_host_attendee
        simple_attendee
        photo
      end

      context 'when user is host' do
        before { request.headers.merge! 'Authorization' => "Bearer #{host_token}" }

        it 'returns a successful response' do
          delete :destroy, params: request_params
          expect(response).to have_http_status(:ok)
        end

        it 'deletes the photo' do
          expect do
            delete :destroy, params: request_params
          end.to change(Photo, :count).by(-1)
        end

        it 'returns the deleted photo' do
          delete :destroy, params: request_params
          expect(JSON.parse(response.body)['id']).to eq(photo.id)
        end
      end

      context 'when user is co-host' do
        before { request.headers.merge! 'Authorization' => "Bearer #{co_host_token}" }

        it 'returns a successful response' do
          delete :destroy, params: request_params
          expect(response).to have_http_status(:ok)
        end

        it 'deletes the photo' do
          expect do
            delete :destroy, params: request_params
          end.to change(Photo, :count).by(-1)
        end

        it 'returns the deleted photo' do
          delete :destroy, params: request_params
          expect(JSON.parse(response.body)['id']).to eq(photo.id)
        end
      end

      context 'when user has role admin' do
        before { request.headers.merge! 'Authorization' => "Bearer #{admin_token}" }

        it 'returns a successful response' do
          delete :destroy, params: request_params
          expect(response).to have_http_status(:ok)
        end

        it 'deletes the photo' do
          expect do
            delete :destroy, params: request_params
          end.to change(Photo, :count).by(-1)
        end

        it 'returns the deleted photo' do
          delete :destroy, params: request_params
          expect(JSON.parse(response.body)['id']).to eq(photo.id)
        end
      end
      context 'when user is not authorized' do
        it 'does not delete the photo' do
          expect do
            delete :destroy, params: request_params
          end.not_to change(Photo, :count)
        end
      end
    end
  end
end
