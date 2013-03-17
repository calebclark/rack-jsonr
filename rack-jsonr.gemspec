# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rack/jsonr'

Gem::Specification.new do |gem|
  gem.name        = 'rack-jsonr'
  gem.version     = Rack::JSONR::VERSION
  gem.date        = '2013-03-17'
  gem.summary     = %q{A Rack middleware for providing enhanced JSONP-type access, but with get, post, put, and delete
                       verbs as well as http status, headers, and a json body that can be read when there are errors.}
  gem.authors     = ['Caleb Clark']
  gem.email       = ['cclark@fanforce.com']
  gem.homepage    = 'http://github.com/calebclark/rack-jsonr'

  gem.files         = `git ls-files`.split($/)
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_development_dependency 'rack'
end
