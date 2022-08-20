# frozen_string_literal: true

class RepositoryCheckStub
  def self.repo_path(_); end

  def self.command_check(_lang); end

  def self.run_check(_lang, _name, _clone_url)
    '[{}]'
  end
end
