# frozen_string_literal: true

class CheckRepositoryLoaderJob < ApplicationJob
  queue_as :default

  def perform(check_id)
    check = Repository::Check.find check_id
    check.check!
    repository = check.repository
    params = RepositoryTester.new.run(check_id,
                                      repository.language.downcase,
                                      repository.name,
                                      repository.clone_url,
                                      repository.issues_count)
    if check.update(params)
      check.to_finished!
    else
      check.fail!
    end
  end
end
