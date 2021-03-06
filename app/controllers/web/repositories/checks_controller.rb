# frozen_string_literal: true

require 'octokit'

class Web::Repositories::ChecksController < Web::Repositories::ApplicationController
  after_action :verify_authorized

  def create
    @repository = Repository.find params[:repository_id]
    @check = @repository.checks.build
    authorize @check
    if @check.save
      redirect_to repository_path(@repository), notice: t('.success')
      CheckRepositoryLoaderJob.perform_later @check.id
    else
      redirect_to repository_path(@repository), flash: { error: t('.error') }
    end
  end

  def show
    @repository = Repository.find params[:repository_id]
    @check = Repository::Check.find params[:id]
    @check_value = JSON.parse(@check.value) if @check.value.present?
    authorize @check
  end
end
