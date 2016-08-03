$VERBOSE=nil

ENV['RACK_ENV'] = 'test'
require 'minitest/autorun'
require 'mocha/mini_test'
require 'sidekiq/testing'

require File.expand_path '../../workers/contest_worker.rb', __FILE__