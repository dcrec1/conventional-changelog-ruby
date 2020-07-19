require 'date'

module ConventionalChangelog
  class ByVersionWriter < Writer
    private

    def filter_key
      :since_version
    end

    def build_new_lines(options)
      if commits.any? || options[:force]
        write_section commits, options[:version], options
      end
    end

    def version_header_title(id)
      date = commits.any? ? commits[0][:date] : Date.today.strftime("%Y-%m-%d")
      "#{id} (#{date})"
    end
  end
end
