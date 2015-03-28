require "codeclimate-test-reporter"
CodeClimate::TestReporter.start
require 'conventional_changelog'
require 'pp'
require 'fakefs'

RSpec.configure do |config|
  config.before(:all) { FakeFS.activate! }
  config.after(:all) { FakeFS.deactivate! }
end
