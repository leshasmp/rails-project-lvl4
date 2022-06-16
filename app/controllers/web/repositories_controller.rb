# frozen_string_literal: true

require 'octokit'

class Web::RepositoriesController < Web::ApplicationController
  before_action :check_admin
  caches_action :new

  def check_admin
    user_not_authorized unless signed_in?
  end

  def index
    @repositories = current_user.repositories.all.order('created_at DESC')
  end

  def new
    @user_repositories = []
    language_values = Repository.language.values
    filtered_repos = client_repos.filter { |repos| language_values.include? repos[:language] }
    filtered_repos.each do |repos|
      @user_repositories << [repos[:full_name], repos[:id]]
    end
    @repository = Repository.new
  end

  def create
    @repository = current_user.repositories.find_or_initialize_by(permitted_params)

    if @repository.save
      redirect_to repositories_path, notice: t('.success')
      RepositoryLoaderJob.perform_later @repository.id
    else
      render :new, notice: t('.error')
    end
  end

  def show
    @repository = Repository.find(params[:id])
    @checks = @repository.checks.order('created_at DESC').page(params[:page])
  end

  private

  def client_repos
    client = Octokit::Client.new access_token: current_user.token, per_page: 100
    client.repos
  end

  def permitted_params
    params.require(:repository).permit(:github_id)
  end

  def user_not_authorized
    redirect_to root_path, flash: { error: t('web.auth.error') }
  end
end
