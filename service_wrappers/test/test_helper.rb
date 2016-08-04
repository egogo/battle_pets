$VERBOSE=nil

ENV['RACK_ENV'] = 'test'
require 'minitest/autorun'
require 'mocha/mini_test'
require 'webmock/minitest'

require File.expand_path '../../service_wrapper_base.rb', __FILE__
require File.expand_path '../../contest_service_wrapper.rb', __FILE__
require File.expand_path '../../pet_service_wrapper.rb', __FILE__