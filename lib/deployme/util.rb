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
  end
end
