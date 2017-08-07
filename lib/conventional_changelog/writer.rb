module ConventionalChangelog

  class LastReleaseNotFound < StandardError
    MESSAGE = <<-EOM
Could not determine last tag or release date from existing CHANGELOG.md.
Please specify the last tag (eg. v1.2.3) or release date (eg. 2016-02-14)
manually by setting the environment variable CONVENTIONAL_CHANGELOG_LAST_RELEASE
and running the generate command again.
    EOM

    def initialize message = MESSAGE
      super(message)
    end
  end

  class Writer < File
    def initialize(file_name)
      FileUtils.touch file_name
      super file_name, 'r+'

      @previous_body = read
    end

    def write!(options)
      seek 0
      write_new_lines options
      puts @previous_body
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
        type_commits.group_by { |commit| commit[:component] }.each do |component, component_commits|
          puts "* **#{component}**" if component
          component_commits.each { |commit| write_commit commit, component }
          puts ""
        end
        puts ""
      end
    end

    def write_commit(commit, componentized)
      puts "#{componentized ? '  ' : ''}* #{commit[:change]} ([#{commit[:id]}](/../../commit/#{commit[:id]}))"
    end

    def write_section(commits, id)
      return if commits.empty?

      puts version_header(id)
      append_changes commits, "feat", "Features"
      append_changes commits, "fix", "Bug Fixes"
    end

    def last_id
      return nil if @previous_body.to_s.length == 0
      matches = @previous_body.split("\n")[0].to_s.match(/"(.*)"/)

      if matches
        matches[1]
      elsif manually_set_id = ENV['CONVENTIONAL_CHANGELOG_LAST_RELEASE']
        manually_set_id
      else
        raise LastReleaseNotFound.new
      end
    end
  end
end
