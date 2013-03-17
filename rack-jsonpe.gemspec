# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rack/jsonpe'

Gem::Specification.new do |gem|
  gem.name        = 'rack-jsonpe'
  gem.version     = Rack::JSONPe::VERSION
  gem.date        = '2013-03-17'
  gem.summary     = %q{A Rack middleware for providing JSONP in a usable way - accepts GET/POST/PUT/DELETE verbs and
                       http status and headers are readable from the body.}
  gem.authors     = ['Caleb Clark']
  gem.email       = ['cclark@fanforce.com']
  gem.homepage    = 'http://github.com/calebclark/rack-jsonpe'

  gem.files         = `git ls-files`.split($/)
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_development_dependency 'rack'
end
