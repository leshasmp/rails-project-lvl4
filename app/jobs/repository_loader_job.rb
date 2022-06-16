# frozen_string_literal: true

class RepositoryLoaderJob < ApplicationJob
  queue_as :default

  def perform(id)
    repository = Repository.find id
    repository.fetch!
    client = Octokit::Client.new
    remote_repository = client.repo repository.github_id
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
