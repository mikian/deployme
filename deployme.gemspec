
lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'deployme/version'

Gem::Specification.new do |spec|
  spec.name          = 'deployme'
  spec.version       = Deployme::VERSION
  spec.authors       = ['Mikko Kokkonen']
  spec.email         = ['mikko.kokkonen@appearhere.co.uk']

  spec.summary       = 'Deploys current directory to anywhere'
  spec.description   = 'Simple tool to deploy current directory to anywhere'
  spec.homepage      = 'https://github.com/mikian/deployme'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'aws-sdk-ecs', '~> 1.14.0'
  spec.add_dependency 'jira-ruby'

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
