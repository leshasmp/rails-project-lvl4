# frozen_string_literal: true

require 'octokit'

class ApplicationContainer
  extend Dry::Container::Mixin

  if Rails.env.test?
    register :repository_check, -> { RepositoryCheckStub }
    register :octokit_client, -> { OctokitClientStub }
  else
    register :repository_check, -> { RepositoryCheck }
    register :octokit_client, -> { Octokit::Client }
  end
end
