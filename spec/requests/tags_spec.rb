require 'rails_helper'
include JwtToken

RSpec.describe TagsController, type: :controller do
  let(:user) { create(:user) }
  let(:user_token) { jwt_encode(user.id, 'user') }
  let(:admin) { create(:user, role: 'admin') }
  let(:admin_token) { jwt_encode(admin.id, 'admin') }
  let(:tag) { create(:tag) }

  describe 'GET #index' do
    let(:tags) { create_list(:tag, 5) }

    context 'when user is not authenticated' do
      before do
        tags
        get :index
      end

      it { is_expected.to respond_with 200 }
      it 'returns all tags' do
        expect(JSON.parse(response.body).size).to eq(5)
      end
    end
  end

  describe 'GET #show' do
    context 'when user is not authenticated' do
      before { tag }

      it 'returns a success response' do
        get :show, params: { id: tag.id }
        expect(response).to have_http_status(:ok)
      end

      it 'returns all associated events' do
        3.times { create(:event, tags: [tag]) }
        get :show, params: { id: tag.id }
        expect(JSON.parse(response.body)['events'].size).to eq(3)
      end
    end

    context 'when user does not exist' do
      before do
        get :show, params: { id: 999_999_999 }
      end

      it { is_expected.to respond_with 404 }
      it { expect(response.body).to eq({ error: 'Tag not found' }.to_json) }
    end
  end

  describe 'POST #create' do
    context 'when user is not authenticated' do
      it 'returns unauthorized status' do
        post :create
        expect(response).to have_http_status(:unauthorized)
      end

      it 'does not create a new tag' do
        expect do
          post :create
        end.not_to change(Tag, :count)
      end
    end

    context 'when user is authenticated' do
      before { request.headers.merge! 'Authorization' => "Bearer #{user_token}" }

      it 'returns unauthorized status' do
        post :create
        expect(response).to have_http_status(:unauthorized)
      end

      it 'does not create a new tag' do
        expect do
          post :create
        end.not_to change(Tag, :count)
      end
    end

    context 'when admin is authenticated' do
      before { request.headers.merge! 'Authorization' => "Bearer #{admin_token}" }

      context 'with valid parameters' do
        let(:valid_params) { { tag: { name: 'Test Tag' } } }

        it 'creates a new tag' do
          expect do
            post :create, params: valid_params
          end.to change(Tag, :count).by(1)
        end

        it 'returns a success response' do
          post :create, params: valid_params
          expect(response).to have_http_status(:ok)
        end

        it 'returns the created tag' do
          post :create, params: valid_params
          expect(JSON.parse(response.body)['name']).to eq('Test Tag')
        end
      end

      context 'with invalid parameters' do
        let(:invalid_params) { { tag: { name: nil } } }

        it 'does not create a new tag' do
          expect do
            post :create, params: invalid_params
          end.not_to change(Tag, :count)
        end

        it 'returns an unprocessable entity status' do
          post :create, params: invalid_params
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end

  describe 'PUT #update' do
    let(:new_tag_name) { 'New Tag Name' }
    let(:valid_params) { { id: tag.id, tag: { name: new_tag_name } } }
    let(:invalid_params) { { id: tag.id, tag: { name: nil } } }

    context 'when admin is authenticated' do
      before { request.headers.merge! 'Authorization' => "Bearer #{admin_token}" }

      context 'with valid parameters' do
        before { put :update, params: valid_params }
        it 'updates the tag' do
          tag.reload
          expect(tag.name).to eq(new_tag_name)
        end

        it 'returns a success response' do
          expect(response).to have_http_status(:ok)
        end

        it 'returns the updated tag' do
          expect(JSON.parse(response.body)['name']).to eq(new_tag_name)
        end
      end

      context 'with invalid parameters' do
        it 'does not update the tag' do
          old_tag_name = tag.name
          put :update, params: invalid_params
          tag.reload
          expect(tag.name).to eq(old_tag_name)
        end

        it 'returns an unprocessable entity status' do
          put :update, params: invalid_params
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context 'when user is authenticated' do
      before { request.headers.merge! 'Authorization' => "Bearer #{user_token}" }

      it 'returns unauthorized status' do
        put :update, params: valid_params
        expect(response).to have_http_status(:unauthorized)
      end

      it 'does not update the tag' do
        old_tag_name = tag.name
        put :update, params: valid_params
        tag.reload
        expect(tag.name).to eq(old_tag_name)
      end
    end

    context 'when user is not authenticated' do
      it 'returns unauthorized status' do
        put :update, params: valid_params
        expect(response).to have_http_status(:unauthorized)
      end

      it 'does not update the tag' do
        old_tag_name = tag.name
        put :update, params: valid_params
        tag.reload
        expect(tag.name).to eq(old_tag_name)
      end
    end
  end

  describe 'DELETE #destroy' do
    before { tag }

    context 'when the user is logged in as an admin' do
      before { request.headers.merge! 'Authorization' => "Bearer #{admin_token}" }

      context 'when the tag exists' do
        it 'destroys the tag' do
          expect do
            delete :destroy, params: { id: tag.id }
          end.to change(Tag, :count).by(-1)
        end

        it 'returns a success response' do
          delete :destroy, params: { id: tag.id }
          expect(response).to have_http_status(:ok)
        end
      end

      context 'when the tag does not exist' do
        it 'returns a not found response' do
          delete :destroy, params: { id: 999 }
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'when the user is logged in as a regular user' do
      before { request.headers.merge! 'Authorization' => "Bearer #{user_token}" }

      context 'when the tag exists' do
        it 'does not destroy the tag' do
          expect do
            delete :destroy, params: { id: tag.id }
          end.not_to change(Tag, :count)
        end

        it 'returns a unauthorized response' do
          delete :destroy, params: { id: tag.id }
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end

    context 'when the user is not logged in' do
      context 'when the tag exists' do
        it 'does not destroy the tag' do
          expect do
            delete :destroy, params: { id: tag.id }
          end.not_to change(Tag, :count)
        end

        it 'returns an unauthorized response' do
          delete :destroy, params: { id: tag.id }
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end
  end
end
