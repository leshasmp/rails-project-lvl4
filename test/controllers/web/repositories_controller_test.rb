# frozen_string_literal: true

require 'test_helper'
require 'addressable/uri'

class Web::RepositoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users :one
    @attrs = {
      github_id: Faker::Number.number(digits: 7)
    }
  end

  test 'guest cant get index' do
    get repositories_url
    assert_redirected_to root_path
  end

  test 'should get index' do
    sign_in @user
    get repositories_url
    assert_response :success
  end

  test 'should get new' do
    sign_in @user
    get new_repository_url
    assert_response :success
  end

  test 'should create repository' do
    sign_in @user
    post repositories_url params: { repository: @attrs }

    repository = Repository.find_by github_id: @attrs[:github_id]

    assert { repository }
    assert_redirected_to repositories_url
  end
end
