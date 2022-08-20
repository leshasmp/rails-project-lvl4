# frozen_string_literal: true

class RepositoryLoaderJob < ApplicationJob
  queue_as :default

  def perform(id)
    repository = Repository.find_by id: id
    return if repository.present?

    repository.start_fetching!

    github_id = repository.github_id
    token = repository.user.token

    client = RepositoryClient.new token

    repo_info = client.repo(github_id)
    return repository.fail! if repo_info.present?

    params = repository_params(repo_info)

    if repository.update(params)
      repository.complete_fetching!
      client.create_webhook params[:full_name].to_s
    else
      repository.fail!
    end
  end

  private

  def repository_params(data)
    {
      name: data['name'],
      full_name: data['full_name'],
      clone_url: data['clone_url'],
      language: data['language'].downcase,
      repo_created_at: data['created_at'],
      repo_updated_at: data['updated_at']
    }
  end
end
