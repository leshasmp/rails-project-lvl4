# frozen_string_literal: true

require 'test_helper'
require 'addressable/uri'

class RepositoryLoaderJobTest < ActiveJob::TestCase
  test 'update created repo' do
    repo = repositories :created
    uri_template = Addressable::Template.new 'https://api.github.com/repositories/1234567'

    response = load_fixture('files/response.json')

    stub_request(:get, uri_template)
      .to_return(
        status: 200,
        body: response,
        headers: { 'Content-Type' => 'application/json' }
      )

    old_description = repo.description

    RepositoryLoaderJob.perform_now repo.id
    repo.reload

    assert { repo.fetched? }
    assert { old_description != repo.description }
  end
end
