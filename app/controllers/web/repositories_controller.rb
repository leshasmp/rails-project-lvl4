# frozen_string_literal: true

require 'octokit'

module Web
  class RepositoriesController < Web::ApplicationController
    after_action :verify_authorized

    def index
      authorize Repository
      @repositories = current_user.repositories.all.order('created_at DESC')
    end

    def new
      authorize Repository
      @repository = Repository.new
      @user_repositories = user_repositories
    end

    def create
      authorize Repository
      @repository = current_user.repositories.find_or_initialize_by(permitted_params)

      if @repository.save
        redirect_to repositories_path, notice: t('.success')
        RepositoryLoaderJob.perform_later @repository.id
      else
        @user_repositories = user_repositories
        render :new, status: :unprocessable_entity
      end
    end

    def show
      @repository = Repository.find(params[:id])
      authorize @repository
      @checks = @repository.checks.order('created_at DESC').page(params[:page])
    end

    private

    def permitted_params
      params.require(:repository).permit(:github_id)
    end

    def user_repositories
      language_values = Repository.language.values

      client = RepositoryClient.new current_user.token
      filtered_repos = client.repos.filter do |repo|
        language = repo['language']&.downcase
        language_values.include? language
      end

      filtered_repos.map { |repo| [repo['full_name'], repo['id']] }
    end
  end
end
