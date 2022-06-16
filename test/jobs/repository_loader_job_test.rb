# frozen_string_literal: true

require 'test_helper'
require 'addressable/uri'

class RepositoryLoaderJobTest < ActiveJob::TestCase
  test 'update created repo' do
    repo = repositories :created
    uri_template = Addressable::Template.new 'https://api.github.com/repositories/1234567'
    uri_ussues = Addressable::Template.new 'https://api.github.com/repositories/1234567/issues'

    response = load_fixture('files/repository.json')

    stub_request(:get, uri_template)
      .to_return(
        status: 200,
        body: response,
        headers: { 'Content-Type' => 'application/json' }
      )

    stub_request(:get, uri_ussues)
      .to_return(
        status: 200,
        body: "[{}]",
        headers: { 'Content-Type' => 'application/json' }
      )  

    RepositoryLoaderJob.perform_now repo.id
    repo.reload

    assert { repo.fetched? }
  end
end
