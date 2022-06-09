# frozen_string_literal: true

class CheckRepositoryLoaderJob < ApplicationJob
  queue_as :default

  def perform(id)
    @check = Repository::Check.find id
    @check.check!
    @repository = @check.repository
    if @check.update(check_params)
      @check.to_finished!
    else
      @check.fail!
    end
  end

  private

  def check_params
    clone_url = @repository[:clone_url]
    client = Octokit::Client.new
    issues = client.issues @repository.github_id
    repository_path = "#{Rails.root}/tmp/repositories/#{@repository[:name]}"
    value = check_js(repository_path, clone_url)
    data_value = JSON.parse(value).first
    {
      name: "Check ##{@check.id}",
      issues_count: issues.count,
      value: value,
      commit: commit(repository_path),
      passed: data_value['messages'].empty?
    }
  end

  def check_js(repository_path, clone_url)
    stdout, _exit_status = Open3.popen3("rm -rf #{repository_path} &&
                                        git clone #{clone_url} #{repository_path} &&
                                        npx eslint --format json --ext .js #{repository_path}/**/*.js") do |_stdin, stdout, _stderr, wait_thr|
      [stdout.read, wait_thr.value]
    end
    stdout
  end

  def commit(repository_path)
    stdout, _exit_status = Open3.popen3("cd #{repository_path} && git rev-parse --short HEAD") do |_stdin, stdout, _stderr, wait_thr|
      [stdout.read, wait_thr.value]
    end
    stdout
  end
end
