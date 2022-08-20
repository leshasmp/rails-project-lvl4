# frozen_string_literal: true

class RepositoryCheck
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

  def self.run_check(lang, name, clone_url)
    command_check = command_check(lang)
    path = repo_path(name)
    command_run_check = "rm -rf #{path} && git clone #{clone_url} #{path} && #{command_check} #{path}"

    stdout, exit_status = Open3.popen3(command_run_check) do |_stdin, stdout, _stderr, wait_thr|
      [stdout.read, wait_thr.value]
    end
    return if exit_status.success? == false

    stdout
  end
end