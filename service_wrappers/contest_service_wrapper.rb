class ContestServiceWrapper < ServiceWrapperBase
  URL = 'http://localhost:5000'
  BASE_PATH = '/api/v1/contests'
  SERVICE_TOKEN = 'service_token'

  class ServiceError < StandardError; end
  class InvalidContestError < ServiceError; end
  class ServiceNotAvailableError < ServiceError; end

  def initialize
    @connection = self.class.connection(URL)
  end

  def get(id)
    resp = connection.get!("#{BASE_PATH}/#{id}.json").as_json
    args = [:id, :started_at, :finished_at, :type, :title, :first_pet_id,
            :second_pet_id, :winner_id].map {|s| resp[s.to_s] } + [self]
    Contest.new(*args)
  rescue Faraday::Bang::Response404Error
    raise InvalidContestError.new("Contest with ID##{id} does not exist.")
  rescue Faraday::Bang::Response500Error
    raise ServiceNotAvailableError.new("Contest service at url: #{URL} is not available at this time.")
  end

  class Contest < Struct.new(:id, :started_at, :finished_at, :type, :title, :first_pet_id, :second_pet_id, :winner_id, :service)
    def started_at
      self[:started_at].nil? ? nil : Time.parse(self[:started_at])
    end

    def finished_at
      self[:finished_at].nil? ? nil : Time.parse(self[:finished_at])
    end

    def set_winner(winner_id)
      service.connection.put "#{ContestServiceWrapper::BASE_PATH}/#{self.id}.json",
                             { winner_id: winner_id, token: ContestServiceWrapper::SERVICE_TOKEN }
    end
  end
end