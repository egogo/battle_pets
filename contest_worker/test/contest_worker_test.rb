require File.expand_path '../test_helper.rb', __FILE__

describe 'ContestWorker' do
  let(:described_class) { ContestWorker }
  let(:instance) { described_class.new }

  it 'is a sidekiq worker' do
    described_class.respond_to?(:perform_async).must_equal true
  end

  describe '#perform' do
    let(:contest_wrap) { mock }
    let(:pet_a_wrap) { mock }
    let(:pet_b_wrap) { mock }

    before do
      instance.expects(:get_contest).with(42).returns(contest_wrap)
      contest_wrap.stubs(:first_pet_id).returns(22)
      contest_wrap.stubs(:second_pet_id).returns(44)

      instance.expects(:get_pet).with(22).returns(pet_a_wrap)
      instance.expects(:get_pet).with(44).returns(pet_b_wrap)

      instance.expects(:get_results_for).with(contest_wrap, pet_a_wrap, pet_b_wrap).returns(
          mock(winner: mock(id: 44), pet_a_exp_gain: 10, pet_b_exp_gain: 20)
      )

      contest_wrap.expects(:set_winner).with(44)
      pet_a_wrap.expects(:update_experience).with(10)
      pet_b_wrap.expects(:update_experience).with(20)
    end

    it 'fetches Contest from Contests API with dependencies, evaluates it and updates Contest/Pets with results' do
      instance.perform(42)
    end
  end

  describe '#pets_svc' do
    it 'returns cached instance of PetServiceWrapper' do
      svc1 = instance.pets_svc
      svc2 = instance.pets_svc
      svc1.is_a?(PetServiceWrapper).must_equal true
      svc1.must_equal(svc2)
    end
  end

  describe '#contests_svc' do
    it 'returns cached instance of ContestServiceWrapper' do
      svc1 = instance.contests_svc
      svc2 = instance.contests_svc
      svc1.is_a?(ContestServiceWrapper).must_equal true
      svc1.must_equal(svc2)
    end
  end

  describe '#get_contest' do
    before do
      instance.stubs(:contests_svc).returns(svc = mock)
      svc.expects(:get).with(42)
    end

    it 'forwards the call to ContestsService' do
      instance.get_contest(42)
    end
  end

  describe '#get_pet' do
    before do
      instance.stubs(:pets_svc).returns(svc = mock)
      svc.expects(:get).with(42)
    end

    it 'forwards the call to PetsService' do
      instance.get_pet(42)
    end
  end

  describe '#get_results_for' do # (contest, petA, petB)
    let(:contest) { mock }
    let(:pet_a) { mock }
    let(:pet_b) { mock }
    let(:evaluator) { mock }

    before do
      instance.expects(:evaluator_class_for).with(contest).returns(evaluator_klass = mock)
      evaluator_klass.expects(:new).with(pet_a, pet_b).returns(evaluator)
      evaluator.expects(:evaluate!)
    end

    it 'instantiates suitable evaluator with correct params, evaluates contestants and returns evaluator' do
      instance.get_results_for(contest, pet_a, pet_b).must_equal evaluator
    end
  end

  describe '#evaluator_class_for' do
    it 'returns suitable evaluator class' do
      instance.evaluator_class_for(mock(type: 'strength')).must_equal StrengthEvaluator
      instance.evaluator_class_for(mock(type: 'agility')).must_equal AgilityEvaluator
      instance.evaluator_class_for(mock(type: 'wit')).must_equal WitEvaluator
      instance.evaluator_class_for(mock(type: 'senses')).must_equal SensesEvaluator

      err = -> { instance.evaluator_class_for(mock(type: 'other')) }.must_raise ArgumentError
      err.message.must_equal 'Unknown evaluator type'
    end
  end

end