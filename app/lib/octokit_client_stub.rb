# frozen_string_literal: true

class OctokitClientStub
  attr_accessor :access_token, :per_page

  def self.repo(_github_id)
    File.read('test/fixtures/files/repositories.json')
  end
end
