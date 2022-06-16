# frozen_string_literal: true

class ApplicationContainer
  extend Dry::Container::Mixin

  if Rails.env.test?
    register :repository_check_api, -> { RepositoryCheckApiStub }
  else
    register :repository_check_api, -> { RepositoryCheckApi }
  end
end
