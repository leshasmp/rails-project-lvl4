# frozen_string_literal: true

class OctokitClientStub
  attr_accessor :access_token, :per_page

  def initialize(params)
    @access_token = params[:access_token]
    @per_page = params[:per_page]
  end

  def repo(_github_id)
    JSON.parse File.read('test/fixtures/files/repository.json')
  end

  def repos
    JSON.parse File.read('test/fixtures/files/repositories.json')
  end

  def commits(_github_id)
    [
      { sha: 'adf31a2asdasdgfdgsdfasd' },
      { sha: 'asda18aas18asd1gdefdsff' }
    ]
  end

  def create_hook(_repo, _name, _config, options = {}); end
end
