require File.expand_path '../test_helper.rb', __FILE__

include Rack::Test::Methods

def json(body)
  JSON.parse(body, symbolize_names: true)
end

def app
  ArenaService::App
end

describe "Arena Service" do
  let(:contest_a) { Contest.create(title: 'Contest #1', first_pet_id: 1, second_pet_id: 2, winner_id: 2, type: 'strength') }
  let(:contest_b) { Contest.create(title: 'Contest #2', first_pet_id: 1, second_pet_id: 2, winner_id: 1, type: 'wit') }
  let(:contest_c) { Contest.create(title: 'Contest #3', first_pet_id: 10, second_pet_id: 11, type: 'agility') }
  let(:contest_d) { Contest.create(title: 'Contest #4', first_pet_id: 11, second_pet_id: 12, type: 'senses') }

  describe 'GET /api/v1/contests.json' do
    before { [contest_a, contest_b] }

    it "should return a list of existing contests" do
      get '/api/v1/contests.json'
      json = json(last_response.body)
      json.size.must_equal 2

      json.first.must_equal({
                            id: contest_a.id,
                            title: 'Contest #1',
                            type: 'strength',
                            first_pet_id: 1,
                            second_pet_id: 2,
                            winner_id: 2,
                            started_at: nil,
                            finished_at: nil
                        })

      json.last.must_equal({
                                id: contest_b.id,
                                title: 'Contest #2',
                                type: 'wit',
                                first_pet_id: 1,
                                second_pet_id: 2,
                                winner_id: 1,
                                started_at: nil,
                                finished_at: nil
                            })
    end
    describe 'filters' do
      before { [contest_c, contest_d] }
      it "should return a list of existing contests, filtered by contestant ID" do
        get '/api/v1/contests.json', contestant_id: 11
        json = json(last_response.body)
        json.size.must_equal 2

        json.include?({
                          id: contest_c.id,
                          title: 'Contest #3',
                          type: 'agility',
                          first_pet_id: 10,
                          second_pet_id: 11,
                          winner_id: nil,
                          started_at: nil,
                          finished_at: nil
                      }).must_equal true
        json.include?({
                          id: contest_d.id,
                          title: 'Contest #4',
                          type: 'senses',
                          first_pet_id: 11,
                          second_pet_id: 12,
                          winner_id: nil,
                          started_at: nil,
                          finished_at: nil
                      }).must_equal true
      end
    end
  end

  describe 'GET /api/v1/contests/:id.json' do
    before { [contest_a, contest_b] }
    describe 'with existing contest' do
      it "should return a contest by ID" do
        get "/api/v1/contests/#{contest_b.pk}.json"
        json = json(last_response.body)
        json.must_equal({
                           id: contest_b.id,
                           title: 'Contest #2',
                           type: 'wit',
                           first_pet_id: 1,
                           second_pet_id: 2,
                           winner_id: 1,
                           started_at: nil,
                           finished_at: nil
                       })
      end
    end

    describe 'with non-existing contest' do
      it "should render 404" do
        get "/api/v1/contests/100500.json"
        last_response.status.must_equal 404
      end
    end
  end

  describe 'PUT /api/v1/contests/:id.json' do
    before { [contest_a, contest_b, contest_c] }

    describe 'with service token' do
      it "set winner for the contest with ID" do
        contest_c.winner_id.must_equal nil

        put "/api/v1/contests/#{contest_c.pk}.json", { winner_id: 11, token: ArenaService::SERVICE_TOKEN }

        last_response.status.must_equal 204
        last_response.body.must_be_empty

        contest_c.reload
        contest_c.winner_id.must_equal 11
        contest_c.finished_at.must_be_within_delta Time.now, 0.5
      end
    end

    describe 'without service token' do
      it "renders 403, changes nothing" do
        contest_c.winner_id.must_equal nil

        put "/api/v1/contests/#{contest_c.pk}.json", { winner_id: 11 }
        last_response.status.must_equal 403
        last_response.body.must_be_empty

        contest_c.reload
        contest_c.winner_id.must_equal nil
        contest_c.finished_at.must_equal nil
      end
    end

  end

  describe 'POST /api/v1/contests.json' do
    let(:pet_svc_wrapper) { mock }
    let(:correct_params) { { type: 'strength', title: 'Test Contest', pet_one_id: 2, pet_two_id: 4 } }
    before { PetServiceWrapper.stubs(:new).returns(pet_svc_wrapper) }

    describe 'with missing parameters' do
      describe 'missing type' do
        let(:incorrect_params) { correct_params.delete(:type); correct_params }
        it "renders an error" do
          Contest.count.must_equal 0
          post "/api/v1/contests.json", incorrect_params
          last_response.status.must_equal 400
          json(last_response.body).must_equal({message: 'Parameter is required', errors: { type: 'Parameter is required' }})
          Contest.count.must_equal 0
        end
      end

      describe 'missing title' do
        let(:incorrect_params) { correct_params.delete(:title); correct_params }
        it "renders an error" do
          Contest.count.must_equal 0
          post "/api/v1/contests.json", incorrect_params
          last_response.status.must_equal 400
          json(last_response.body).must_equal({message: 'Parameter is required', errors: { title: 'Parameter is required' }})
          Contest.count.must_equal 0
        end
      end

      describe 'missing pet_one_id' do
        let(:incorrect_params) { correct_params.delete(:pet_one_id); correct_params }
        it "renders an error" do
          Contest.count.must_equal 0
          post "/api/v1/contests.json", incorrect_params
          last_response.status.must_equal 400
          json(last_response.body).must_equal({message: 'Parameter is required', errors: { pet_one_id: 'Parameter is required' }})
          Contest.count.must_equal 0
        end
      end

      describe 'missing pet_two_id' do
        let(:incorrect_params) { correct_params.delete(:pet_two_id); correct_params }
        it "renders an error" do
          Contest.count.must_equal 0
          post "/api/v1/contests.json", incorrect_params
          last_response.status.must_equal 400
          json(last_response.body).must_equal({message: 'Parameter is required', errors: { pet_two_id: 'Parameter is required' }})
          Contest.count.must_equal 0
        end
      end

      describe 'invalid pet_one_id' do
        before do
          pet_svc_wrapper.expects(:get).with(2).raises(PetServiceWrapper::InvalidPetError)
        end

        it "renders an error" do
          Contest.count.must_equal 0
          post "/api/v1/contests.json", correct_params
          last_response.status.must_equal 400
          json(last_response.body).must_equal({message: 'Pet with ID 2 is not a valid pet', errors: {pet_one_id: "'2' is not a valid Pet ID"}})
          Contest.count.must_equal 0
        end
      end

      describe 'invalid pet_two_id' do
        before do
          pet_svc_wrapper.expects(:get).with(2).returns(true)
          pet_svc_wrapper.expects(:get).with(4).raises(PetServiceWrapper::InvalidPetError)
        end

        it "renders an error" do
          Contest.count.must_equal 0
          post "/api/v1/contests.json", correct_params
          last_response.status.must_equal 400
          json(last_response.body).must_equal({message: 'Pet with ID 4 is not a valid pet', errors: {pet_two_id: "'4' is not a valid Pet ID"}})
          Contest.count.must_equal 0
        end
      end
    end

    describe 'with all required parameters' do
      before do
        pet_svc_wrapper.expects(:get).with(2).returns(true)
        pet_svc_wrapper.expects(:get).with(4).returns(true)
      end

      it "creates new contest with given parameters" do
        Contest.count.must_equal 0
        ContestWorker.jobs.size.must_equal 0

        post "/api/v1/contests.json", correct_params

        last_response.status.must_equal 200
        expected = Contest.first
        json(last_response.body).must_equal({
                                                id: expected.pk,
                                                started_at: expected.started_at.to_s,
                                                finished_at: nil,
                                                type: 'strength',
                                                title: 'Test Contest',
                                                first_pet_id: 2,
                                                second_pet_id: 4,
                                                winner_id: nil
                                            })
        ContestWorker.jobs.size.must_equal 1
        job = ContestWorker.jobs.first
        job['class'].must_equal 'ContestWorker'
        job['args'].must_equal [expected.pk]
      end
    end

  end
end
