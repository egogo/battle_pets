$LOAD_PATH.unshift File.dirname(__FILE__)

require 'bundler'

Bundler.require

require 'sidekiq/api'

require './service_wrappers/service_wrapper_base.rb'
require './service_wrappers/pet_service_wrapper.rb'

class ContestWorker; include Sidekiq::Worker; end # making sidekiq happy

module ArenaService
  SERVICE_TOKEN = 'service_token'

  module Models
    Sequel.extension :migration
    Sequel::Model.plugin :json_serializer

    DB = Sequel.sqlite File.expand_path("../../arena_#{ENV['RACK_ENV'] || 'development'}.sqlite", __FILE__)

    Sequel::Migrator.run(DB, File.expand_path('../migrations', __FILE__), use_transactions: true)

    Dir[File.expand_path('../models/*', __FILE__)].each {|file| require file }
  end

  class App < Sinatra::Application
    include ArenaService::Models
    helpers Sinatra::Param

    before { content_type :json }

    before do
      invalid = request.request_method.downcase.to_sym == :put && (!params[:token] || params[:token] != ArenaService::SERVICE_TOKEN)
      halt 403 if invalid
    end

    get '/api/v1/contests.json' do
      Contest.all.to_json
    end

    post '/api/v1/contests.json' do
      param :title, String, required: true
      param :type, String, in: Contest::AVAILABLE_TYPES, required: true
      param :pet_one_id, Integer, required: true, min: 1
      param :pet_two_id, Integer, required: true, min: 1

      [:pet_one_id, :pet_two_id].each {|k| validate_pet!(k, params[k])}

      contest = Contest.create(started_at: Time.now,
                               type: params[:type],
                               title: params[:title],
                               first_pet_id: params[:pet_one_id],
                               second_pet_id: params[:pet_two_id]
                              )

      Sidekiq::Client.push({ 'class' => ContestWorker, 'args' => [contest.pk] })

      contest.to_json
    end

    get '/api/v1/contests/:id.json' do
      get_contest.to_json
    end

    put '/api/v1/contests/:id.json' do
      param :winner_id, Integer, required: true
      get_contest.set_winner(params[:winner_id])
      status 204
    end

    private

    def get_contest
      halt 404 unless (contest = Contest[params[:id]])
      contest
    end

    def validate_pet!(field, id)
      @pet_svc_wrap ||= PetServiceWrapper.new
      @pet_svc_wrap.get(id)
    rescue PetServiceWrapper::ServiceError
      halt 400, { message: "Pet with ID #{id} is not a valid pet", errors: { field => "'#{id}' is not a valid Pet ID"} }.to_json
    end
  end
end