# frozen_string_literal: true

class RepositoryTester
  include Import['repository_check']

  def run(lang, repository_name, clone_url)
    data = repository_check.run_check(lang, repository_name, clone_url)
    return false if data.nil?

    case lang
    when 'javascript'
      check_result = generate_result_js(data)
    when 'ruby'
      check_result = generate_result_rb(data)
    end
    check_result
  end

  private

  def generate_result_js(check_result_data)
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

  def generate_result_rb(check_result_data)
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
end
