# frozen_string_literal: true

require 'test_helper'

class Web::Repositories::ChecksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users :one
    @repository = repositories :one
    @check = repository_checks :one
    sign_in @user
  end

  test 'should create check' do
    post repository_checks_url(@repository)

    check = Repository::Check.find_by repository_id: @repository.id

    check.reload
    assert { check.passed? }
    assert { check.finished? }
  end

  test 'should get show' do
    get repository_check_url(@repository, @check)
    assert_response :success
  end
end
