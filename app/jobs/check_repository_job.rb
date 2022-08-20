# frozen_string_literal: true

class CheckRepositoryJob < ApplicationJob
  queue_as :default

  def perform(check_id)
    check = Repository::Check.find_by id: check_id
    return if check.blank?

    check.start_check!

    repository = check.repository
    user = repository.user

    client = RepositoryClient.new user.token

    params = {}

    commits = client.commits repository.github_id
    last_commit = commits.first
    params[:commit] = last_commit[:sha].slice(0..6)

    check_result = RepositoryTester.new.run(repository.language, repository.name, repository.clone_url)
    return check.fail! unless check

    params[:output] = JSON.generate check_result[:output]
    params[:passed] = check_result[:issues].zero?
    params[:issues_count] = check_result[:issues]

    if check.update(params)
      check.finish_check!
      UserMailer.with(user: user, check: check).data_check_email.deliver_later unless check.passed
    else
      check.fail!
    end
  end
end
