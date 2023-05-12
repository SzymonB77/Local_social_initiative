require 'rails_helper'
include JwtToken

RSpec.describe PhotosController, type: :controller do
  describe "GET /index" do
    let(:event) { create(:event) }
    let(:user) { create(:user) }
    context 'when the event has photos' do
      let!(:photos) { create_list(:photo, 3, event: event, user: user) }
      before do
        get :index, params: { event_id: event.id }
      end

      it 'returns a success response' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns all photos for the specified event' do
        expect(JSON.parse(response.body).size).to eq(3)
      end

    end

    context 'when the event does not have any photos' do
      before do
        get :index, params: { event_id: event.id }
      end

      it 'returns a success response' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns an empty array' do
        expect(JSON.parse(response.body).size).to eq(0)
      end
    end
  end
  describe "GET #show" do
    let(:event) { create(:event) }
    let(:user) { create(:user) }
    let(:photo) { create(:photo, event: event, user: user) }

    context "when photo exists" do
      before { get :show, params: { event_id: event.id, id: photo.id } }

      it "returns status 200" do
        expect(response).to have_http_status(200)
      end

      it "returns the photo" do
        expect(response.body).to eq(PhotoSerializer.new(photo).to_json)
      end
    end

    context "when photo does not exist" do
      before { get :show, params: { event_id: event.id, id: 0 } }

      it "returns status 404" do
        expect(response).to have_http_status(404)
      end

      it "returns error message" do
        expect(response.body).to eq({ error: "Photo not found" }.to_json)
      end
    end
  end

  describe 'POST #create' do
    context 'when user try to create new photo' do
       before do
        @admin = create(:user, role: 'admin')
        @host = create(:user)
        @co_host = create(:user)
        @my_user = create(:user)
        @event = create(:event)
        @host_attendee = create(:attendee, user: @host, event: @event, role: 'host')
        @co_host_attendee = create(:attendee, user: @co_host, event: @event, role: 'co-host')
        @simple_attendee = create(:attendee, user: @my_user, event: @event)
        @admin_token = jwt_encode(@admin.id, 'admin')
        @host_token = jwt_encode(@host.id, 'user')
        @co_host_token = jwt_encode(@co_host.id, 'user')
        @user_token = jwt_encode(@my_user.id, 'user')
        @photo_attributes = attributes_for(:photo, user_id: @host.id, event_id: @event.id)
        @request_params = { event_id: @event.id, photo: @photo_attributes }
      end
      context 'when user is host' do
        before { request.headers.merge! 'Authorization' => "Bearer #{@host_token}" }

        it 'returns a successful response' do
          post :create, params: @request_params
          expect(response).to have_http_status(:ok)
        end

        it 'creates a new photo' do
          post :create, params: @request_params
          expect(Photo.count).to eq(1)
        end

        it 'associates the photo with the user and event' do
          post :create, params: @request_params
          expect(Photo.first.user).to eq(@host)
          expect(Photo.first.event).to eq(@event)
        end

        it 'returns the newly created photo' do
          post :create, params: @request_params
          photo = JSON.parse(response.body)
          expect(photo['url']).to eq(@photo_attributes[:url])
        end
      end

      context 'when user is co-host' do
        before { request.headers.merge! 'Authorization' => "Bearer #{@co_host_token}" }

        it 'returns a successful response' do
          post :create, params: @request_params
          expect(response).to have_http_status(:ok)
        end

        it 'creates a new photo' do
          post :create, params: @request_params
          expect(Photo.count).to eq(1)
        end

        it 'associates the photo with the user and event' do
          post :create, params: @request_params
          expect(Photo.first.user).to eq(@co_host)
          expect(Photo.first.event).to eq(@event)
        end

        it 'returns the newly created photo' do
          post :create, params: @request_params
          photo = JSON.parse(response.body)
          expect(photo['url']).to eq(@photo_attributes[:url])
        end
      end

      context 'when user has role admin' do
        before { request.headers.merge! 'Authorization' => "Bearer #{@admin_token}" }

        it 'returns a successful response' do
          post :create, params: @request_params
          expect(response).to have_http_status(:ok)
        end

        it 'creates a new photo' do
          post :create, params: @request_params
          expect(Photo.count).to eq(1)
        end

        it 'associates the photo with the user and event' do
          post :create, params: @request_params
          expect(Photo.first.user).to eq(@admin)
          expect(Photo.first.event).to eq(@event)
        end

        it 'returns the newly created photo' do
          post :create, params: @request_params
          photo = JSON.parse(response.body)
          expect(photo['url']).to eq(@photo_attributes[:url])
        end
      end

      context 'when user has role admin' do
        before { request.headers.merge! 'Authorization' => "Bearer #{@user_token}" }
        it 'returns an unauthorized response' do
          post :create, params: @request_params
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'does not create a new photo' do
          post :create, params: @request_params
          expect(Photo.count).to eq(0)
        end

        it 'returns an error message' do
          post :create, params: @request_params
          response_body = JSON.parse(response.body)
          expect(response_body['error']).to eq('Unauthorized')
        end
      end
      
      context 'when user is not authenticated' do
        it 'returns an unauthorized response' do
          post :create, params: @request_params
          expect(response).to have_http_status(:unauthorized)
        end

        it 'does not create a new photo' do
          post :create, params: @request_params
          expect(Photo.count).to eq(0)
        end
      end
    end
  end
  describe 'DELETE #destroy' do
    context 'when user tries to delete a photo' do
      let(:admin) { create(:user, role: 'admin') }
      let(:host) { create(:user) }
      let(:co_host) { create(:user) }
      let(:my_user) { create(:user) }
      let(:event) { create(:event) }
      let(:host_attendee) { create(:attendee, user: host, event: event, role: 'host') }
      let(:co_host_attendee) { create(:attendee, user: co_host, event: event, role: 'co-host') }
      let(:simple_attendee) { create(:attendee, user: my_user, event: event) }
      let(:photo) { create(:photo, user: host, event: event) }
      let(:admin_token) { jwt_encode(admin.id, 'admin') }
      let(:host_token) { jwt_encode(host.id, 'user') }
      let(:co_host_token) { jwt_encode(co_host.id, 'user') }
      let(:user_token) { jwt_encode(my_user.id, 'user') }
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
          expect {
            delete :destroy, params: request_params
          }.to change(Photo, :count).by(-1)
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
          expect {
            delete :destroy, params: request_params
          }.to change(Photo, :count).by(-1)
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
          expect {
            delete :destroy, params: request_params
          }.to change(Photo, :count).by(-1)
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
