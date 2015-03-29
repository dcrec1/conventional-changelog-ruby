module ConventionalChangelog
  class Writer < File
    def initialize(file_name)
      @previous_body = File.open(file_name, "a+").read
      super file_name, "w"
    end

    def write!(options)
      write_new_lines options
      self.puts @previous_body
    end

    private

    def version_header(id)
      <<-HEADER
<a name="#{id}"></a>
### #{version_header_title(id)}


      HEADER
    end

    def commits
      @commits ||= Git.commits filter_key => last_id
    end

    def append_changes(commits, type, title)
      unless (type_commits = commits.select { |commit| commit[:type] == type }).empty?
        puts "#### #{title}", ""
        type_commits.group_by { |commit| commit[:component] }.each do |component, commits|
          puts "* **#{component}**"
          commits.each { |commit| puts "  * #{commit[:change]} ([#{commit[:id]}](/commit/#{commit[:id]}))" }
          puts ""
        end
        puts ""
      end
    end

    def write_section(commits, id)
      puts version_header(id)
      append_changes commits, "feat", "Features"
      append_changes commits, "fix", "Bug Fixes"
    end

    def last_id
      @previous_body.to_s == "" ? nil : @previous_body.split("\n")[0].to_s.match(/"(.*)"/)[1]
    end
  end
end
