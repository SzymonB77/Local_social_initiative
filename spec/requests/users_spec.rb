require 'rails_helper'
include JwtToken

RSpec.describe UsersController, type: :controller do
  describe 'GET #index' do
    let(:admin) { create(:user, role: 'admin') }
    let(:user) { create(:user) }
    let!(:users) { create_list(:user, 3) }
    let(:admin_headers) { { 'Authorization': "Bearer #{jwt_encode(admin.id, 'admin')}" } }
    let(:user_headers) { { 'Authorization': "Bearer #{jwt_encode(user.id, 'user')}" } }

    context 'when admin is authenticated' do
      before { request.headers.merge! admin_headers }
      let(:users) { create_list(:user, 3) }
      it 'returns a success response' do
        get :index
        expect(response).to have_http_status(:ok)
      end

      it 'returns all users' do
        get :index
        expect(JSON.parse(response.body).size).to eq(4)
      end
    end

    context 'when user is authenticated' do
      before { request.headers.merge! user_headers }

      it 'raises an Access Denied error if user role is not admin' do
        get :index
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET #show' do
    let(:admin) { create(:user, role: 'admin') }
    let(:user) { create(:user) }
    let(:admin_headers) { { 'Authorization': "Bearer #{jwt_encode(admin.id, 'admin')}" } }
    let(:user_headers) { { 'Authorization': "Bearer #{jwt_encode(user.id, 'user')}" } }

    context 'when user is authenticated' do
      before { request.headers.merge! user_headers }

      it 'returns http success' do
        get :show, params: { id: user.id }
        expect(response).to have_http_status(:ok)
      end

      it 'has no access to data other than his own' do
        get :show, params: { id: admin.id }
        expect(response).to have_http_status(:unauthorized)
      end

      it 'renders user data' do
        get :show, params: { id: user.id }
        expect(JSON.parse(response.body)['id']).to eq(user.id)
      end
    end

    context 'when admin is authenticated' do
      before { request.headers.merge! admin_headers }

      it 'returns http success' do
        get :show, params: { id: user.id }
        expect(response).to have_http_status(:ok)
      end

      it 'has access to data other than his own' do
        get :show, params: { id: user.id }
        expect(JSON.parse(response.body)['id']).to eq(user.id)
      end

      it 'renders user data' do
        get :show, params: { id: admin.id }
        expect(JSON.parse(response.body)['id']).to eq(admin.id)
      end
    end

    context 'when user is not authenticated' do
      it 'returns http unauthorized' do
        get :show, params: { id: user.id }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'POST #create' do
    context 'when valid params are passed' do
      it 'creates a new user' do
        user_attributes = FactoryBot.attributes_for(:user)
        expect do
          post :create, params: { user: user_attributes }
        end.to change(User, :count).by(1)
      end
    end

    context 'when email is nil' do
      let(:email_nil_params) do
        { user: attributes_for(:user, email: nil) }
      end
      it 'does not create a new user' do
        expect do
          post :create, params: email_nil_params
        end.not_to change(User, :count)
      end

      it 'returns an unprocessable entity response' do
        post :create, params: email_nil_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when email is already taken' do
      let(:existing_user) { create(:user) }
      let(:invalid_params) do
        { user: attributes_for(:user, email: existing_user.email) }
      end

      it 'returns an unprocessable entity response' do
        post :create, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when the password is nil' do
      let(:invalid_params) do
        { user: attributes_for(:user, password: nil) }
      end

      it 'does not create a new user' do
        expect do
          post :create, params: invalid_params
        end.not_to change(User, :count)
      end

      it 'returns an unprocessable entity response' do
        post :create, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when the nickname is nil' do
      let(:invalid_params) do
        { user: attributes_for(:user, nickname: nil) }
      end

      it 'does not create a new user' do
        expect do
          post :create, params: invalid_params
        end.not_to change(User, :count)
      end

      it 'returns an unprocessable entity response' do
        post :create, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when the role is nil' do
      let(:nil_params) do
        { user: attributes_for(:user, password: nil) }
      end
      it 'does not create a new user' do
        expect do
          post :create, params: nil_params
        end.not_to change(User, :count)
      end

      it 'returns an unprocessable entity response' do
        post :create, params: nil_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PUT #update' do
    let(:admin) { create(:user, role: 'admin') }
    let(:user) { create(:user) }
    let(:params) do
      {
        id: user.id,
        user: {
          name: 'John',
          surname: 'Doe'
        }
      }
    end
    let(:headers) { { 'Authorization': "Bearer #{jwt_encode(user.id, 'user')}" } }

    context 'when user is authenticated and authorized' do
      before { request.headers.merge! headers }
      before { put :update, params: params }

      it 'returns 200 status code' do
        expect(response).to have_http_status(:ok)
      end

      it 'updates user attributes' do
        user.reload
        expect(user.name).to eq('John')
        expect(user.surname).to eq('Doe')
      end
    end

    context 'when admin is authenticated and authorized' do
      let(:headers) { { 'Authorization': "Bearer #{jwt_encode(admin.id, 'admin')}" } }
      before { request.headers.merge! headers }
      before { put :update, params: params }

      it 'returns 200 status code' do
        expect(response).to have_http_status(:ok)
      end

      it 'updates user attributes' do
        user.reload
        expect(user.name).to eq('John')
        expect(user.surname).to eq('Doe')
      end
    end

    context 'when user is not authenticated' do
      before { put :update, params: params }

      it 'returns 401 status code' do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when user id is invalid' do
      let(:params) do
        {
          id: 0,
          user: {
            name: 'John',
            surname: 'Doe'
          }
        }
      end
      let(:headers) { { 'Authorization': "Bearer #{jwt_encode(admin.id, 'user')}" } }
      before { request.headers.merge! headers }
      before { put :update, params: params }

      it 'returns 404 status code' do
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when user params are invalid' do
      let(:params) do
        {
          id: user.id,
          user: {
            email: nil
          }
        }
      end
      let(:headers) { { 'Authorization': "Bearer #{jwt_encode(admin.id, 'user')}" } }
      before { request.headers.merge! headers }
      before { put :update, params: params }

      it 'returns 422 status code' do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:admin) { create(:user, role: 'admin') }
    let!(:user) { create(:user) }
    let(:admin_headers) { { 'Authorization': "Bearer #{jwt_encode(admin.id, 'admin')}" } }
    let(:user_headers) { { 'Authorization': "Bearer #{jwt_encode(user.id, 'user')}" } }

    context 'when admin is authenticated' do
      before { request.headers.merge! admin_headers }

      it 'deletes the user' do
        expect do
          delete :destroy, params: { id: user.id }
        end.to change(User, :count).by(-1)
      end

      it 'returns the deleted user' do
        delete :destroy, params: { id: user.id }
        expect(JSON.parse(response.body)['id']).to eq(user.id)
      end
    end

    context 'when user is authenticated' do
      before { request.headers.merge! user_headers }

      it 'deletes the user' do
        expect do
          delete :destroy, params: { id: user.id }
        end.to change(User, :count).by(-1)
      end
    end

    context 'when user is not authenticated' do
      it 'returns http unauthorized' do
        delete :destroy, params: { id: user.id }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when user try to delete another user' do
      before { request.headers.merge! user_headers }

      it 'raises an Access Denied error if user role is not admin' do
        delete :destroy, params: { id: admin.id }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
