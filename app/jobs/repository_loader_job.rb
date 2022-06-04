# frozen_string_literal: true

class RepositoryLoaderJob < ApplicationJob
  queue_as :default

  def perform(id)
    repository = Repository.find id
    repository.fetch!
    client = Octokit::Client.new
    remote_repository = client.repo repository.github_id
    params = repository_params(remote_repository)
    if repository.update(params)
      repository.to_fetched!
    else
      repository.fail!
    end
  end

  private

  def repository_params(data)
    {
      owner_name: data[:owner][:login],
      repo_name: data[:full_name],
      description: data[:description],
      default_branch: data[:default_branch],
      watchers_count: data[:watchers],
      language: data[:language],
      repo_created_at: data[:created_at],
      repo_updated_at: data[:updated_at]
    }
  end
end
