module ConventionalChangelog
  class CLI
    def self.execute
      File.open("CHANGELOG.md", "w") do |file|
        write_new_lines_to file
        file.puts previous_body
      end
    end

    private

    def self.write_new_lines_to(f)
      Git.commits(since: last_date).group_by { |commit| commit[:date] }.sort.reverse.each do |date, commits|
        f.puts version_header(date)
        append_changes f, commits, "feat", "Features"
        append_changes f, commits, "fix", "Bug Fixes"
      end
    end

    def self.last_date
      previous_body == "" ? nil : previous_body.split("\n")[0].to_s.match(/"(.*)"/)[1]
    end

    def self.previous_body
      @previous_body ||= File.open("CHANGELOG.md", "a+").read
    end

    def self.version_header(date)
      <<-HEADER
<a name="#{date}"></a>
### #{date}


      HEADER
    end

    def self.append_changes(f, commits, type, title)
      unless (type_commits = commits.select { |commit| commit[:type] == type }).empty?
        f.puts "#### #{title}", ""
        type_commits.group_by { |commit| commit[:component] }.each do |component, commits|
          f.puts "* **#{component}**"
          commits.each { |commit| f.puts "  * #{commit[:change]} (#{commit[:id]})" }
          f.puts ""
        end
        f.puts ""
      end
    end
  end
end
