# frozen_string_literal: true

class RepositoryInfo
  include Import['octokit_client']

  attr_accessor :github_id, :token

  def initialize(params)
    @github_id = params[:github_id]
    @token = params[:token]
    if Rails.env.test?
      @client = Octokit::Client.new access_token: @token, per_page: 100
    else
      @client = OctokitClientStub.new access_token: @token, per_page: 100
    end
  end

  def repo
    @client.repo
  end

  def issues
    @client.issues
  end

  def create_webhook
    @client.create_hook repo[:full_name].to_s
  end

  def create_hook
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
