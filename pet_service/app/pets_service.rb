$LOAD_PATH.unshift File.dirname(__FILE__)

require 'rubygems'
require 'bundler'

Bundler.require

require 'sidekiq/api'


module PetService
  SERVICE_TOKEN = 'service_token'

  module Models
    Sequel.extension :migration
    Sequel::Model.plugin :json_serializer
    DB = Sequel.sqlite File.expand_path("../../pets_#{ENV['RACK_ENV'] || 'development'}.sqlite", __FILE__)
    Sequel::Migrator.run(DB, File.expand_path('../migrations', __FILE__), use_transactions: true)
    Dir[File.expand_path('../models/*', __FILE__)].each {|file| require file }
  end

  class App < Sinatra::Application
    helpers Sinatra::Param
    include PetService::Models

    before { content_type :json }

    before do
      invalid = request.request_method.downcase.to_sym == :put && (!params[:token] || params[:token] != PetService::SERVICE_TOKEN)
      halt 403 if invalid
    end

    get '/api/v1/pets.json' do
      Pet.all.to_json
    end

    post '/api/v1/pets.json' do
      Pet.create_random.to_json
    end

    get '/api/v1/pets/:id.json' do
      get_pet.to_json
    end

    put '/api/v1/pets/:id.json' do
      param :experience_gain, Integer, required: true, min: 0
      get_pet.increment_experience(params[:experience_gain])
      status 204
    end

    private

    def get_pet
      halt 404 unless (pet = Pet[params[:id]])
      pet
    end

  end
end

