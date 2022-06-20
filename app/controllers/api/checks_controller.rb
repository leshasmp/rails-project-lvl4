# frozen_string_literal: true

require 'octokit'

class Api::ChecksController < Api::ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    params = JSON.parse(request.raw_post)
    @repository = Repository.find_by github_id: params['repository']['id']
    @check = @repository.checks.build
    if @check.save
      redirect_to repository_path(@repository), notice: t('.success')
      CheckRepositoryLoaderJob.perform_later @check.id
    else
      redirect_to repository_path(@repository), flash: { error: t('.error') }
    end
  end
end
