# frozen_string_literal: true

class RepositoryCheckStub
  def self.run(_repo)
    { output: '[{}]', issues: 0 }
  end
end
