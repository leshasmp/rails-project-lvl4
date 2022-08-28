# frozen_string_literal: true

module OutputFormatters
  module Ruby
    def self.run(check_result_data)
      result = []
      data = JSON.parse(check_result_data)['files']
      filtered_check = data.filter { |value| value['offenses'].present? }
      issues_count = 0
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
          issues_count += 1
        end
        result << params
      end
      { output: result, issues: issues_count }
    end
  end
end
