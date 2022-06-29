# frozen_string_literal: true

class RepositoryInfo
  def initialize(params)
    @token = params[:token]
    @client = ApplicationContainer[:octokit_client].new access_token: @token, per_page: 100
  end

  def repo(github_id)
    @client.repo(github_id)
  end

  def repos
    @client.repos
  end

  def issues(github_id)
    @client.issues github_id
  end

  def create_webhook(github_id)
    repo = repo(github_id)
    repo_name = repo[:full_name].to_s
    @client.create_hook(
      repo_name,
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
