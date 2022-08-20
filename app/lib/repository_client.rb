# frozen_string_literal: true

class RepositoryClient
  def initialize(token)
    @client = ApplicationContainer[:octokit_client].new access_token: token, per_page: 100
  end

  def repo(github_id)
    @client.repo(github_id)
  end

  def repos
    @client.repos
  end

  def commits(github_id)
    @client.commits github_id
  end

  def create_webhook(repo_full_name)
    @client.create_hook(
      repo_full_name,
      'web',
      {
        url: "#{Rails.application.routes.default_url_options[:host]}/api/checks",
        content_type: 'json'
      },
      {
        events: %w[push pull_request],
        active: true
      }
    )
  end
end
