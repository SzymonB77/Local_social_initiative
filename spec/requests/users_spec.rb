require 'rails_helper'
include JwtToken

RSpec.describe UsersController, type: :controller do
  let(:admin) { create(:user, :admin) }
  let(:user) { create(:user) }
  let(:admin_headers) { { 'Authorization': "Bearer #{jwt_encode(admin.id, 'admin')}" } }
  let(:user_headers) { { 'Authorization': "Bearer #{jwt_encode(user.id, 'user')}" } }

  describe 'GET #index' do
    let(:users) { create_list(:user, 3) }

    context 'when admin is authenticated' do
      before do
        request.headers.merge! admin_headers
        users
        get :index
      end

      it { is_expected.to respond_with 200 }

      it 'returns all users' do
        expect(JSON.parse(response.body).size).to eq(4)
      end
    end

    context 'when user is authenticated' do
      before do
        request.headers.merge! user_headers
        users
        get :index
      end

      it { is_expected.to respond_with 401 }
    end
  end

  describe 'GET #show' do
    let(:user_params) { { id: user.id } }
    let(:admin_params) { { id: admin.id } }

    context 'when user is authenticated' do
      before { request.headers.merge! user_headers }

      it 'returns http success' do
        get :show, params: user_params
        expect(response).to have_http_status(:ok)
      end

      it 'has no access to data other than his own' do
        get :show, params: admin_params
        expect(response).to have_http_status(:unauthorized)
      end

      it 'renders user data' do
        get :show, params: user_params
        expect(JSON.parse(response.body)['id']).to eq(user.id)
      end
    end

    context 'when admin is authenticated' do
      before { request.headers.merge! admin_headers }

      it 'returns http success' do
        get :show, params: admin_params
        expect(response).to have_http_status(:ok)
      end

      it 'renders his own data' do
        get :show, params: admin_params
        expect(JSON.parse(response.body)['id']).to eq(admin.id)
      end

      it 'has access to data other than his own' do
        get :show, params: user_params
        expect(JSON.parse(response.body)['id']).to eq(user.id)
      end
    end

    context 'when user does not exist' do
      before do
        request.headers.merge! admin_headers
        get :show, params: { id: 999_999_999 }
      end

      it { is_expected.to respond_with 404 }
      it { expect(response.body).to eq({ error: 'User not found' }.to_json) }
    end

    context 'when user is not authenticated' do
      before { get :show, params: user_params }
      it { is_expected.to respond_with 401 }
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
      let(:email_nil_params) { { user: attributes_for(:user, email: nil) } }

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
      let(:existing_user_params) { { user: attributes_for(:user, email: existing_user.email) } }

      it 'returns an unprocessable entity response' do
        post :create, params: existing_user_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when the password is nil' do
      let(:invalid_params) { { user: attributes_for(:user, password: nil) } }

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
      let(:invalid_params) { { user: attributes_for(:user, nickname: nil) } }

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
    let(:valid_params) { { id: user.id, user: { name: 'John', surname: 'Doe' } } }
    let(:id_invalid_params) { { id: 0, user: { name: 'John', surname: 'Doe' } } }
    let(:email_invalid_params) { { id: user.id, user: { email: nil } } }

    context 'when user is authenticated and authorized' do
      before do
        request.headers.merge! user_headers
        put :update, params: valid_params
      end

      it { is_expected.to respond_with 200 }

      it 'updates user attributes' do
        user.reload
        expect(user.name).to eq('John')
        expect(user.surname).to eq('Doe')
      end
    end

    context 'when admin is authenticated and authorized' do
      before do
        request.headers.merge! admin_headers
        put :update, params: valid_params
      end

      it { is_expected.to respond_with 200 }

      it 'updates user attributes' do
        user.reload
        expect(user.name).to eq('John')
        expect(user.surname).to eq('Doe')
      end
    end

    context 'when user is not authenticated' do
      before { put :update, params: valid_params }

      it { is_expected.to respond_with 401 }
    end

    context 'when user id is invalid' do
      before do
        request.headers.merge! user_headers
        put :update, params: id_invalid_params
      end

      it { is_expected.to respond_with 404 }
    end

    context 'when user params are invalid' do
      before do
        request.headers.merge! user_headers
        put :update, params: email_invalid_params
      end

      it { is_expected.to respond_with 422 }
    end
  end

  describe 'DELETE #destroy' do
    let(:user_params) { { id: user.id } }
    let(:admin_params) { { id: admin.id } }

    context 'when admin is authenticated' do
      before do
        request.headers.merge! admin_headers
        delete :destroy, params: user_params
      end

      it 'deletes the user' do
        expect(User.exists?(user.id)).to be_falsey
      end

      it 'returns the deleted user' do
        expect(JSON.parse(response.body)['id']).to eq(user.id)
      end
    end

    context 'when user is authenticated' do
      before do
        request.headers.merge! user_headers
        delete :destroy, params: user_params
      end

      it 'deletes the user' do
        expect(User.exists?(user.id)).to be_falsey
      end

      it 'returns the deleted user' do
        expect(JSON.parse(response.body)['id']).to eq(user.id)
      end
    end

    context 'when user is not authenticated' do
      before { delete :destroy, params: { id: user.id } }

      it { is_expected.to respond_with 401 }
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
