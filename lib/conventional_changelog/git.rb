module ConventionalChangelog
  class Git
    DELIMITER = "/////"

    def self.commits(since:)
      log.split("\n").map { |commit| commit.split DELIMITER }.select { |commit| since.nil? or commit[1] > since }.map do |commit|
        comment = commit[2].match(/(.*)\((.*)\): (.*)/)
        { id: commit[0], date: commit[1], type: comment[1], component: comment[2], change: comment[3] }
      end
    end

    private

    def self.log
      `git log --pretty=format:'%h#{DELIMITER}%ad#{DELIMITER}%s%x09' --date=short --grep='^(feat|fix)\\(' -E`
    end
  end
end
