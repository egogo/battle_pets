require File.expand_path '../test_helper.rb', __FILE__

describe "PetServiceWrapper" do
  let(:described_class) { PetServiceWrapper }
  let(:instance) { described_class.new }

  let(:pet_json) {
    {
      id: 42,
      name: 'Witty Pet',
      strength: 3,
      agility: 5,
      wit: 29,
      senses: 4,
      experience: 10
    }
  }

  describe '#get' do

    describe 'when pet exists' do
      before do
        stub_request(:get, "http://localhost:4000/api/v1/pets/42.json").to_return(status: 200, body: pet_json.to_json )
      end

      it 'returns an instance of PetServiceWrapper::Pet with all properties assigned' do
        result = instance.get(42)
        result.must_be_instance_of(PetServiceWrapper::Pet)
        result.id.must_equal 42
        result.name.must_equal 'Witty Pet'
        result.strength.must_equal 3
        result.agility.must_equal 5
        result.wit.must_equal 29
        result.senses.must_equal 4
        result.experience.must_equal 10
      end
    end

    describe 'when pet does not exists' do
      before do
        stub_request(:get, "http://localhost:4000/api/v1/pets/42.json").to_return(status: 404, body: '' )
      end

      it 'raises an error' do
        err = -> { instance.get(42) }.must_raise PetServiceWrapper::InvalidPetError
        err.message.must_equal 'Pet with ID#42 does not exist.'
      end
    end

    describe 'when service is down' do
      before do
        stub_request(:get, "http://localhost:4000/api/v1/pets/42.json").to_return(status: 500, body: '' )
      end

      it 'raises an error' do
        err = -> { instance.get(42) }.must_raise PetServiceWrapper::ServiceNotAvailableError
        err.message.must_equal 'Pets service at url: http://localhost:4000 is not available at this time.'
      end
    end
  end

  describe 'PetServiceWrapper::Pet' do
    let(:pet) { instance.get(42) }

    before do
      stub_request(:get, "http://localhost:4000/api/v1/pets/42.json").to_return(status: 200, body: pet_json.to_json )
      stub_request(:put, "http://localhost:4000/api/v1/pets/42.json").with(body: {"token"=>"service_token", "experience_gain"=>"20"}).to_return(status: 204, body: "")
    end

    describe '#update_experience' do
      it 'sends winner id to the service' do
        pet.update_experience(20)
      end
    end
  end
end
