# frozen_string_literal: true

class RepositoryLoaderJob < ApplicationJob
  queue_as :default

  def perform(id, token)
    repository = Repository.find id
    repository.fetch!
    client = Octokit::Client.new access_token: token, per_page: 100
    remote_repository = client.repo repository.github_id
    create_webhook(client, remote_repository[:full_name])
    params = repository_params(remote_repository)
    params[:id] = repository.id
    params[:issues_count] = client.issues(repository.github_id).count
    if repository.update(params)
      repository.to_fetched!
    else
      repository.fail!
    end
  end

  private

  def create_webhook(client, repo_name)
    client.create_hook(
      repo_name.to_s,
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

  def repository_params(data)
    {
      name: data[:name],
      full_name: data[:full_name],
      clone_url: data[:clone_url],
      language: data[:language],
      repo_created_at: data[:created_at],
      repo_updated_at: data[:updated_at]
    }
  end
end
