# frozen_string_literal: true

class CheckRepositoryLoaderJob < ApplicationJob
  queue_as :default

  def perform(id)
    @check = Repository::Check.find id
    @check.check!
    @repository = @check.repository
    @check_commands = {
      javascript: 'npx eslint --format json',
      ruby: 'rubocop --format json'
    }
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
    repository_path = "tmp/repositories/#{@repository[:name]}/"
    check_result_data = check_code(repository_path, clone_url, @check_commands[:"#{@repository.language.downcase}"])
    if @repository.language.casecmp('javascript').zero?
      check_result = generate_result_js check_result_data
    end
    if @repository.language.casecmp('ruby').zero?
      check_result = generate_result_rb check_result_data
    end
    {
      name: "Check ##{@check.id}",
      issues_count: issues.count,
      value: check_result,
      commit: commit(repository_path),
      passed: check_result.blank?
    }
  end

  def generate_result_js(check_result_data)
    result = []
    data = JSON.parse(check_result_data)
    filtered_check = data.filter { |value| value['messages'].present? }
    filtered_check.each do |value|
      params = {}
      params[:file_path] = value['filePath']
      params[:messages] = []
      value['messages'].each do |message|
        params[:messages] << {
          rule: message['ruleId'],
          message: message['message'],
          line_column: "#{message['line']}:#{message['column']}"
        }
      end
      result << params
    end
    JSON.generate result if result.present?
  end

  def generate_result_rb(check_result_data)
    result = []
    data = JSON.parse(check_result_data)['files']
    filtered_check = data.filter { |value| value['offenses'].present? }
    filtered_check.each do |value|
      params = {}
      params[:file_path] = value['path']
      params[:messages] = []
      value['offenses'].each do |message|
        params[:messages] << {
          rule: message['cop_name'],
          message: message['message'],
          line_column: "#{message['location']['start_line']}:#{message['location']['start_column']}"
        }
      end
      result << params
    end
    JSON.generate result if result.present?
  end

  def check_code(repository_path, clone_url, check_command)
    stdout, _exit_status = Open3.popen3("rm -rf #{repository_path} &&
                                        git clone #{clone_url} #{repository_path} &&
                                        #{check_command} #{repository_path}") do |_stdin, stdout, _stderr, wait_thr|
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
