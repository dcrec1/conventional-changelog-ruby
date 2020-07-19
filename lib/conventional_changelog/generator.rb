module ConventionalChangelog
  class Generator
    DEFAULT_OPTIONS = {
      version_headers: true,
      anchors: true,
      dry_run: false,
      force: false
    }.freeze

    def generate!(options = {})
      writer(options).new("CHANGELOG.md").write!(DEFAULT_OPTIONS.merge(options))
    end

    private

    def writer(options)
      options[:version] ? ByVersionWriter : ByDateWriter
    end
  end
end
