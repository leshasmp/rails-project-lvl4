# frozen_string_literal: true

require 'octokit'

class Api::ChecksController < Api::ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    @repository = Repository.find_by github_id: params['repository']['id']
    return if @repository.present?

    @check = @repository.checks.build
    @check.save
    CheckRepositoryJob.perform_later @check.id
    head :ok
  end
end
