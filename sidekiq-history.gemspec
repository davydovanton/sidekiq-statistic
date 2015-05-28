# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sidekiq/history/version'

Gem::Specification.new do |gem|
  gem.name          = 'sidekiq-history'
  gem.version       = Sidekiq::History::VERSION
  gem.authors       = ['Anton Davydov']
  gem.email         = ['antondavydov.o@gmail.com']

  gem.summary       = %q{See history about your workers (GSoC project)}
  gem.description   = %q{See history about your workers (GSoC project)}
  gem.homepage      = "https://github.com/davydovanton/sidekiq-history"
  gem.license       = 'MIT'

  gem.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features|images)/}) }
  gem.bindir        = 'exe'
  gem.executables   = gem.files.grep(%r{^exe/}) { |f| File.basename(f) }
  gem.require_paths = ['lib']

  gem.add_dependency 'sidekiq', '~> 3.3', '>= 3.3.4'
  gem.add_dependency 'sinatra-contrib'

  gem.add_development_dependency 'rake', '~> 10'
  gem.add_development_dependency 'sinatra'
  gem.add_development_dependency 'mocha', '~> 0'
  gem.add_development_dependency 'rack-test', '~> 0'
  gem.add_development_dependency 'minitest', '~> 5.0', '>= 5.0.7'
  gem.add_development_dependency 'minitest-utils', '~> 0'
end
