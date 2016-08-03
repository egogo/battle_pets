class ContestServiceWrapper < ServiceWrapperBase
  URL = 'http://localhost:5000'
  BASE_PATH = '/api/v1/contests'
  SERVICE_TOKEN = 'service_token'

  def initialize
    @connection = self.class.connection(URL)
  end

  def get(id)
    resp = connection.get!("#{BASE_PATH}/#{id}.json").as_json
    args = [:id, :started_at, :finished_at, :type, :title, :first_pet_id,
            :second_pet_id, :winner_id].map {|s| resp[s.to_s] } + [self]
    Contest.new(*args)
  end

  class Contest < Struct.new(:id, :started_at, :finished_at, :type, :title, :first_pet_id, :second_pet_id, :winner_id, :service)
    def set_winner(winner_id)
      service.connection.put "#{ContestServiceWrapper::BASE_PATH}/#{self.id}.json",
                             { winner_id: winner_id, token: ContestServiceWrapper::SERVICE_TOKEN }
    end
  end
end