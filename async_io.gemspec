# encoding: utf-8

$:.unshift File.expand_path('../lib', __FILE__)
require 'async_io/version'

Gem::Specification.new do |s|
  s.name          = "async_io"
  s.version       = AsyncIo::VERSION.dup
  s.authors       = ["Antonio C Nalesso"]
  s.email         = ["acnalesso@yahoo.co.uk"]
  s.homepage      = "https://github.com/acnalesso/async_io"
  s.summary       = "Simple asynchronous IO for ruby."
  s.description   = "Perform asyncrhonous IO for ruby using blocks and threads just pure old ruby code."
  s.license       = "MIT"

  s.files         = `git ls-files app lib`.split("\n")
  s.test_files    = `git ls-files spec`.split("\n")
  s.platform      = Gem::Platform::RUBY
  s.require_paths = ['lib']

  s.add_development_dependency "rspec"
end
