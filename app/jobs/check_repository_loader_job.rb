# frozen_string_literal: true

class CheckRepositoryLoaderJob < ApplicationJob
  queue_as :default

  def perform(check_id)
    check = Repository::Check.find check_id
    check.check!

    repository = check.repository
    token = repository.user.token
    language = repository.language
    repo_name = repository.name
    clone_url = repository.clone_url
    user = repository.user
    github_id = repository.github_id

    client = RepositoryInfo.new token: token

    params = {}
    params[:name] = "Check ##{check_id}"

    commits = client.commits github_id
    last_commit = commits.first
    params[:commit] = last_commit[:sha].slice(0..6)

    check_result = RepositoryTester.new.run(language, repo_name, clone_url)

    params[:value] = JSON.generate check_result[:value]

    params[:passed] = check_result[:issues].zero?
    params[:issues_count] = check_result[:issues]

    if check.update(params) && params[:value] != false
      check.to_finished!
      UserMailer.with(user: user, check: check).data_check_email.deliver_later unless check.passed
    else
      check.fail!
    end
  end
end
