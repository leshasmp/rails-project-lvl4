# frozen_string_literal: true

class RepositoryCheck
  def self.run(repo)
    data = run_check(repo)
    return false if data.nil?

    case repo.language
    when 'javascript'
      check_result = generate_result_js(data)
    when 'ruby'
      check_result = generate_result_rb(data)
    end
    check_result
  end

  def self.repo_path(name)
    "tmp/repositories/#{name}/"
  end

  def self.command_check(lang)
    case lang
    when 'javascript'
      './node_modules/.bin/eslint --config .eslintrc_repos.json --format json'
    when 'ruby'
      'rubocop --config .rubocop_repos.yml --format json'
    end
  end

  def self.run_check(repo)
    command_check = command_check(repo.language)
    path = repo_path(repo.name)
    command_run_check = "rm -rf #{path} && git clone #{repo.clone_url} #{path} && #{command_check} #{path}"

    stdout, _exit_status = Open3.popen3(command_run_check) do |_stdin, stdout, _stderr, wait_thr|
      [stdout.read, wait_thr.value]
    end
    stdout
  end

  def self.generate_result_js(check_result_data)
    result = []
    data = JSON.parse(check_result_data)
    filtered_check = data.filter { |value| value['messages'].present? }
    issues = 0
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
        issues += 1
      end
      result << params
    end
    { output: result, issues: issues }
  end

  def self.generate_result_rb(check_result_data)
    result = []
    data = JSON.parse(check_result_data)['files']
    filtered_check = data.filter { |value| value['offenses'].present? }
    issues = 0
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
        issues += 1
      end
      result << params
    end
    { output: result, issues: issues }
  end

  private_class_method :generate_result_js, :generate_result_rb, :repo_path, :command_check, :run_check
end
