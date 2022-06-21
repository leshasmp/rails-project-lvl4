# frozen_string_literal: true

class CheckRepositoryLoaderJob < ApplicationJob
  queue_as :default

  def perform(check_id)
    check = Repository::Check.find check_id
    check.check!
    repository = check.repository
    user = repository.user
    params = RepositoryTester.new.run(check_id,
                                      repository.language.downcase,
                                      repository.name,
                                      repository.clone_url,
                                      repository.issues_count)
    if check.update(params)
      check.to_finished!
      UserMailer.with(user: user, check: check).data_check_email.deliver_later unless check.passed
    else
      check.fail!
    end
  end
end
