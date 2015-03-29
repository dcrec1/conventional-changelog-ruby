module ConventionalChangelog
  class CLI
    def self.execute(params)
      Generator.new.generate! parse(params)
    end

    private
    def self.parse(params)
      Hash[*params.map { |param| param.split("=") }.map { |key, value| [key.to_sym, value] }.flatten]
    end
  end
end
