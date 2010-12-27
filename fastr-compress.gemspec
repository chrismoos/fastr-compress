$:.unshift File.expand_path('../lib/', __FILE__)

require 'fastr-compress/version'

Gem::Specification.new do |s|
    s.name = "fastr-compress"
    s.version = Fastr::Compress::VERSION
    s.platform = Gem::Platform::RUBY
    s.authors = ['Chris Moos']
    s.email = ['chris@tech9computers.com']
    s.homepage = "http://github.com/chrismoos/fastr-compress"
    s.summary = "fastr plugin for compressing output"
    s.description = "Compresses output with GZip or Deflate for responses."

    s.add_dependency "fastr", ">= 0.1.0"

    s.required_rubygems_version = ">= 1.3.6"
    s.files = Dir.glob("lib/**/*") + %w(README.md)
    s.require_path = 'lib'
end
