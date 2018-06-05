module Deployme
  module Util
    # From activesupport/lib/active_support/inflector/methods.rb, line 67
    def self.camelize(term)
      string = term.to_s
      string = string.sub(/^[a-z\d]*/) { $&.capitalize }
      string.gsub!(%r{(?:_|(/))([a-z\d]*)}) { "#{Regexp.last_match(1)}#{inflections.acronyms[Regexp.last_match(2)] || Regexp.last_match(2).capitalize}" }
      string.gsub!(%r{/}, '::')
      string
    end

    def self.deep_dup(obj)
      Marshal.load(Marshal.dump(obj))
    end

    def self.deep_symbolize_keys(hash)
      case hash
      when Hash
        Hash[
          hash.map do |k, v|
            [k.respond_to?(:to_sym) ? k.to_sym : k, deep_symbolize_keys(v)]
          end
        ]
      when Enumerable
        hash.map { |v| deep_symbolize_keys(v) }
      else
        hash
      end
    end
  end
end
