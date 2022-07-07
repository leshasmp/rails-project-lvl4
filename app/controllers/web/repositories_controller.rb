# frozen_string_literal: true

require 'octokit'

class Web::RepositoriesController < Web::ApplicationController
  after_action :verify_authorized
  caches_action :new

  def index
    authorize Repository
    @repositories = current_user.repositories.all.order('created_at DESC')
  end

  def new
    authorize Repository
    @repository = Repository.new

    @user_repositories = []
    language_values = Repository.language.values

    client = RepositoryInfo.new token: current_user.token
    filtered_repos = client.repos.filter { |repos| language_values.include? repos['language'] }

    filtered_repos.each do |repos|
      @user_repositories << [repos['full_name'], repos['id']]
    end
  end

  def create
    authorize Repository
    @repository = current_user.repositories.find_or_initialize_by(permitted_params)

    if @repository.save
      redirect_to repositories_path, notice: t('.success')
      RepositoryLoaderJob.perform_later @repository.id
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @repository = Repository.find(params[:id])
    @checks = @repository.checks.order('created_at DESC').page(params[:page])
    authorize @repository
  end

  private

  def permitted_params
    params.require(:repository).permit(:github_id)
  end
end
