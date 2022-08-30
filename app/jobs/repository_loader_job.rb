# frozen_string_literal: true

class RepositoryLoaderJob < ApplicationJob
  queue_as :default

  def perform(repo_id)
    repo = Repository.find_by id: repo_id
    return if repo.blank?

    repo.start_fetching!

    github_id = repo.github_id
    token = repo.user.token

    client = RepositoryClient.new token

    repo_info = client.repo(github_id)

    params = repo_params(repo_info)

    repo.update!(params)
    repo.complete_fetching!
    client.create_webhook params[:full_name].to_s
  rescue StandardError => e
    repo.fail!
    Rails.logger.debug e
  end

  private

  def repo_params(data)
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
