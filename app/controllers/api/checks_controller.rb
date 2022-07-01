# frozen_string_literal: true

require 'octokit'

class Api::ChecksController < Api::ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    @repository = Repository.find_by github_id: params['repository']['id']
    @check = @repository.checks.build
    @check.save
    CheckRepositoryLoaderJob.perform_later @check.id
    render status: :ok
  end
end
