# frozen_string_literal: true

class CheckRepositoryLoaderJobTest < ActiveJob::TestCase
  test 'update created check' do
    check = repository_checks :one

    CheckRepositoryLoaderJob.perform_now check.id
    check.reload

    assert { check.finished? }
  end
end
