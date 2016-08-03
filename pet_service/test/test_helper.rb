$VERBOSE=nil

ENV['RACK_ENV'] = 'test'
require 'minitest/autorun'
require 'rack/test'

class Minitest::Spec
  def run(*args, &block)
    Sequel::Model.db.transaction(:rollback=>:always, :auto_savepoint=>true){super}
  end
end

require File.expand_path '../../app/pets_service.rb', __FILE__