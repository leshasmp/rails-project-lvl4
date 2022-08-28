# frozen_string_literal: true

module OutputFormatters
  module Javascript
    def self.run(check_result_data)
      result = []
      data = JSON.parse(check_result_data)
      filtered_check = data.filter { |value| value['messages'].present? }
      issues_count = 0
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
          issues_count += 1
        end
        result << params
      end
      { output: result, issues: issues_count }
    end
  end
end
