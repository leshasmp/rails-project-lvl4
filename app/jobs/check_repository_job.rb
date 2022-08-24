# frozen_string_literal: true

class CheckRepositoryJob < ApplicationJob
  queue_as :default

  def perform(check_id)
    check = Repository::Check.find_by id: check_id
    return if check.blank?

    check.start_check!

    repo = check.repository
    user = repo.user

    client = RepositoryClient.new user.token

    begin
      check_result = RepositoryCheck.run(repo)
    rescue StandardError
      return check.fail!
    end

    commits = commits(client, repo.github_id)
    params = params(check_result, commits.first)

    update(check, params)
  end

  def params(check_result, commit)
    {
      output: JSON.generate(check_result[:output]),
      passed: check_result[:issues].zero?,
      issues_count: check_result[:issues],
      commit: commit[:sha].slice(0..6)
    }
  end

  def commits(client, github_id)
    client.commits github_id
  end

  def update(check, params)
    if check.update(params)
      check.finish_check!
      UserMailer.with(user: user, check: check).data_check_email.deliver_later unless check.passed
    else
      check.fail!
    end
  end
end
