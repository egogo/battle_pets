$LOAD_PATH.unshift File.dirname(__FILE__)
require_relative 'app/pets_service.rb'
run PetService::App