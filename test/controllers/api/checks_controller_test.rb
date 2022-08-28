# frozen_string_literal: true

require 'test_helper'

class Api::ChecksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @repository = repositories :one
  end

  test 'should create check' do
    post api_checks_url params: { repository: { id: @repository.github_id } }

    check = Repository::Check.find_by repository_id: @repository.id

    check.reload
    assert { check.passed? }
    assert { check.finished? }
    assert_response :success
  end
end
