# frozen_string_literal: true

require 'test_helper'

class Web::AuthControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users :one
  end

  test 'check github auth' do
    post auth_request_path('github')
    assert_response :redirect
  end

  test 'create' do
    auth_hash = {
      provider: 'github',
      uid: '12345',
      info: {
        email: Faker::Internet.email,
        nickname: Faker::Name.first_name,
        name: Faker::Name.name,
        image: Faker::Internet.url(host: 'faker')
      },
      credentials: {
        token: Faker::Number.number(digits: 10)
      }
    }

    OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash::InfoHash.new(auth_hash)

    get callback_auth_url('github')
    assert_response :redirect

    user = User.find_by(email: auth_hash[:info][:email].downcase)

    assert user
    assert signed_in?
  end

  test 'logout' do
    sign_in @user
    assert { signed_in? }

    delete auth_logout_url

    assert_redirected_to root_path
    assert { session[:user_id].nil? }
  end
end
