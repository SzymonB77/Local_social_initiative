require 'rails_helper'
include JwtToken

RSpec.describe AuthenticationController, type: :controller do
  describe 'POST #login' do
    let(:user) { create(:user, email: 'test@example.com', password: 'password') }

    context 'when valid credentials are provided' do
      it 'returns a success response with authentication token' do
        post :login, params: { email: user.email, password: 'password' }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to include('token')
      end
    end

    context 'when invalid credentials are provided' do
      it 'returns an unauthorized response' do
        post :login, params: { email: user.email, password: 'wrong_password' }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when user is not found' do
      it 'returns an unauthorized response' do
        post :login, params: { email: 'nonexistent@example.com', password: 'password' }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
