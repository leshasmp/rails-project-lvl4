# frozen_string_literal: true

class RepositoryCheck
  def self.run(repo)
    data = run_check(repo)

    formatter = "OutputFormatters::#{repo.language.capitalize}"
    formatter.constantize.run(data)
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

  private_class_method :repo_path, :command_check, :run_check
end
