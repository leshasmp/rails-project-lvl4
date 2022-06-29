# frozen_string_literal: true

class RepositoryLoaderJob < ApplicationJob
  queue_as :default

  def perform(id, token)
    repository = Repository.find id
    repository.fetch!

    github_id = repository.github_id

    client = RepositoryInfo.new token: token

    client.create_webhook(github_id)

    repo_info = client.repo(github_id)
    params = repository_params(repo_info)

    params[:id] = repository.id

    issues = client.issues(github_id)
    params[:issues_count] = issues.count

    if repository.update(params)
      repository.to_fetched!
    else
      repository.fail!
    end
  end

  private

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
