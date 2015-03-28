require "codeclimate-test-reporter"
CodeClimate::TestReporter.start
require 'conventional_changelog'
require 'pp'
require 'fakefs'
FakeFS.activate!
