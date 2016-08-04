require File.expand_path '../test_helper.rb', __FILE__

include Rack::Test::Methods

def json(body)
  JSON.parse(body, symbolize_names: true)
end

def app
  PetService::App
end

describe "Pet Service" do
  let(:pet_a) { Pet.create_random }
  let(:pet_b) { Pet.create_random }

  describe '/api/v1/pets.json' do
    before { [pet_a, pet_b] }

    it "should return a list of existing pets" do
      get '/api/v1/pets.json'
      json = json(last_response.body)
      json.size.must_equal 2
      json.must_include({
                               id: pet_a.id,
                               name: pet_a.name,
                               strength: pet_a.strength,
                               agility: pet_a.agility,
                               wit: pet_a.wit,
                               senses: pet_a.senses,
                               experience: pet_a.experience
                            })

      json.must_include({
                                id: pet_b.id,
                                name: pet_b.name,
                                strength: pet_b.strength,
                                agility: pet_b.agility,
                                wit: pet_b.wit,
                                senses: pet_b.senses,
                                experience: pet_b.experience
                            })
    end
  end

  describe 'GET /api/v1/pets/:id.json' do
    before { [pet_a, pet_b] }

    describe 'for existing pet' do
      it "should a specific pet by ID" do
        get "/api/v1/pets/#{pet_b.pk}.json"
        json = json(last_response.body)
        json.must_equal({
                            id: pet_b.id,
                            name: pet_b.name,
                            strength: pet_b.strength,
                            agility: pet_b.agility,
                            wit: pet_b.wit,
                            senses: pet_b.senses,
                            experience: pet_b.experience
                        })
      end
    end

    describe 'for non-existing pet' do
      it "should render 404" do
        get "/api/v1/pets/100500.json"
        last_response.status.must_equal 404
        last_response.body.must_equal ''
      end
    end
  end

  describe 'POST /api/v1/pets.json' do
    it "should create a pet with random attributes" do
      Pet.count.must_equal 0
      post '/api/v1/pets.json'
      Pet.count.must_equal 1
      pet = Pet.first
      json = json(last_response.body)
      json.must_equal({
                          id: pet.id,
                          name: pet.name,
                          strength: pet.strength,
                          agility: pet.agility,
                          wit: pet.wit,
                          senses: pet.senses,
                          experience: pet.experience
                      })

    end
  end

  describe 'PUT /api/v1/pets/:id.json' do
    before { pet_a.update(experience: 123) }

    describe 'with no or wrong service token' do
      it 'renders 403' do
        put "/api/v1/pets/#{pet_a.pk}.json"
        last_response.status.must_equal 403
      end
    end

    describe 'with correct service token' do
      describe 'for non-existing pet' do
        it "should render 404" do
          put "/api/v1/pets/100500.json", { token: PetService::SERVICE_TOKEN, experience_gain: 15  }
          last_response.status.must_equal 404
          last_response.body.must_equal ''
        end
      end

      describe 'without required parameters' do
        it "should render error message" do
          put "/api/v1/pets/#{pet_a.pk}.json", { token: PetService::SERVICE_TOKEN }
          last_response.status.must_equal 400
          json = json(last_response.body)
          json.must_equal({
                              message: 'Parameter is required',
                              errors: {experience_gain: 'Parameter is required'}
                          })
        end
      end

      describe 'with required parameters' do
        it "should update pet's experience" do
          put "/api/v1/pets/#{pet_a.pk}.json", { token: PetService::SERVICE_TOKEN, experience_gain: 15 }
          last_response.status.must_equal 204
          last_response.body.must_equal ''
          pet_a.reload.experience.must_equal 138
        end
      end

    end

  end
end