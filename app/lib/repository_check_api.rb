# frozen_string_literal: true

class RepositoryCheckApi
  def self.repo_path(name)
    "tmp/repositories/#{name}/"
  end

  def self.command_check(lang)
    case lang
    when 'javascript'
      './node_modules/.bin/eslint --format json'
    when 'ruby'
      'rubocop --format json'
    end
  end

  def self.run_check(lang, name, clone_url)
    command = command_check(lang)
    path = repo_path(name)
    stdout, _exit_status = Open3.popen3("rm -rf #{path} &&
      git clone #{clone_url} #{path} &&
       #{command} #{path} --config .rubocop_repos.yml") do |_stdin, stdout, _stderr, wait_thr|
      [stdout.read, wait_thr.value]
    end
    stdout
  end
end
