module ConventionalChangelog
  class CLI
    def self.execute(params)
      Generator.new.generate! parse(params)
    end

    def self.parse(params)
      Hash[*params.map { |param| param.split("=") }.map { |key, value| [key.to_sym, parse_value(value)] }.flatten]
    end

    def self.parse_value(value)
      case value
      when 'true' then true
      when 'false' then false
      else value
      end
    end
  end
end
