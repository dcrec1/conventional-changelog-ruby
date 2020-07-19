require 'date'

module ConventionalChangelog
  class ByDateWriter < Writer
    private

    def filter_key
      :since_date
    end

    def build_new_lines(options)
      if commits.any?
        if options[:version_headers]
          commits.group_by { |commit| commit[:date] }.sort.reverse_each do |date, commits|
            write_section commits, date, options
          end
        else
          write_section commits, commits[0][:date], options
        end
      elsif options[:force]
        write_section commits, Date.today.strftime("%Y-%m-%d"), options
      end
    end

    def version_header_title(id)
      id
    end
  end
end
