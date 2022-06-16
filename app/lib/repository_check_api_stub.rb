# frozen_string_literal: true

class RepositoryCheckApiStub
  def self.repo_path(_);end

  def self.command_check(_lang); end

  def self.run_check(_lang, _name, _clone_url)
    File.read('test/fixtures/files/check_result_js.json')
  end

  def self.commit(_name)
    '2a583b6'
  end
end
