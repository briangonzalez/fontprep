if !ENV['CI'] && defined?(RUBY_ENGINE) && RUBY_ENGINE == 'ruby'
  require 'simplecov'
  SimpleCov.start do
    add_filter 'vendor'
  end
end

require 'multi_json'
require 'rspec'

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

def macruby?
  defined?(RUBY_ENGINE) && RUBY_ENGINE == 'macruby'
end

def jruby?
  defined?(RUBY_ENGINE) && RUBY_ENGINE == 'jruby'
end

class MockDecoder
  def self.load(string, options={})
    {'abc' => 'def'}
  end

  def self.dump(string)
    '{"abc":"def"}'
  end
end

module MockModuleDecoder
  extend self

  def load(string, options={})
    {'abc' => 'def'}
  end

  def dump(string)
    '{"abc":"def"}'
  end
end
