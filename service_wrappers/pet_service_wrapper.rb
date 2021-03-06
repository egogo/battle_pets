class PetServiceWrapper < ServiceWrapperBase
  URL = 'http://localhost:4000'
  BASE_PATH = '/api/v1/pets'
  SERVICE_TOKEN = 'service_token'

  class ServiceError < StandardError; end
  class InvalidPetError < ServiceError; end
  class ServiceNotAvailableError < ServiceError; end

  def initialize
    @connection = self.class.connection(URL)
  end

  def get(id)
    resp = connection.get!("#{BASE_PATH}/#{id}.json").as_json
    args = [:id, :name, :strength, :agility, :wit, :senses, :experience].map {|s| resp[s.to_s] } + [self]
    Pet.new(*args)
  rescue Faraday::Bang::Response404Error
    raise InvalidPetError.new("Pet with ID##{id} does not exist.")
  rescue Faraday::Bang::Response500Error
    raise ServiceNotAvailableError.new("Pets service at url: #{URL} is not available at this time.")
  end

  class Pet < Struct.new(:id, :name, :strength, :agility, :wit, :senses, :experience, :service)
    def update_experience(gain)
      service.connection.put "#{PetServiceWrapper::BASE_PATH}/#{self.id}.json",
                     { experience_gain: gain, token: PetServiceWrapper::SERVICE_TOKEN }
    end
  end
end