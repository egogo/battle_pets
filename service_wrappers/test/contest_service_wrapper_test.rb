require File.expand_path '../test_helper.rb', __FILE__

describe "ContestServiceWrapper" do
  let(:described_class) { ContestServiceWrapper }
  let(:instance) { described_class.new }

  let(:contest_json) {
    {
        id: 42,
        title: 'Contest #42',
        type: 'wit',
        first_pet_id: 5,
        second_pet_id: 12,
        winner_id: 5,
        started_at: '2016-08-02T18:25:43.511Z',
        finished_at: '2016-08-02T18:26:13.511Z'
    }
  }

  describe '#get' do

    describe 'when context exists' do
      before do
        stub_request(:get, "http://localhost:5000/api/v1/contests/42.json").to_return(status: 200, body: contest_json.to_json )
      end

      it 'returns an instance of ContestServiceWrapper::Contest with all properties assigned' do
        result = instance.get(42)
        result.must_be_instance_of(ContestServiceWrapper::Contest)
        result.id.must_equal 42
        result.title.must_equal 'Contest #42'
        result.type.must_equal 'wit'
        result.first_pet_id.must_equal 5
        result.second_pet_id.must_equal 12
        result.winner_id.must_equal 5
        result.started_at.must_equal Time.parse('2016-08-02T18:25:43.511Z')
        result.finished_at.must_equal Time.parse('2016-08-02T18:26:13.511Z')
      end
    end

    describe 'when contest does not exists' do
      before do
        stub_request(:get, "http://localhost:5000/api/v1/contests/42.json").to_return(status: 404, body: '' )
      end

      it 'raises an error' do
        err = -> { instance.get(42) }.must_raise ContestServiceWrapper::InvalidContestError
        err.message.must_equal 'Contest with ID#42 does not exist.'
      end
    end

    describe 'when service is down' do
      before do
        stub_request(:get, "http://localhost:5000/api/v1/contests/42.json").to_return(status: 500, body: '' )
      end

      it 'raises an error' do
        err = -> { instance.get(42) }.must_raise ContestServiceWrapper::ServiceNotAvailableError
        err.message.must_equal 'Contest service at url: http://localhost:5000 is not available at this time.'
      end
    end
  end

  describe 'ContestServiceWrapper::Contest' do
    let(:contest) { instance.get(42) }

    before do
      stub_request(:get, "http://localhost:5000/api/v1/contests/42.json").to_return(status: 200, body: contest_json.merge(winner_id: nil).to_json )
      stub_request(:put, "http://localhost:5000/api/v1/contests/42.json").with(body: {"token"=>"service_token", "winner_id"=>"123"}).to_return(status: 204, body: "")
    end

    describe '#set_winner' do
      it 'sends winner id to the service' do
        contest.set_winner(123)
      end
    end
  end
end
