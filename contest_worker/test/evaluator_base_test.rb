require File.expand_path '../test_helper.rb', __FILE__

describe 'EvaluatorBase' do
  let(:pet_a) { PetServiceWrapper::Pet.new(3, 'Pet #1', 10, 5, 2, 8, 20, nil) }
  let(:pet_b) { PetServiceWrapper::Pet.new(7, 'Pet #2', 4, 3, 6, 7, 0, nil) }

  let(:described_class) { EvaluatorBase }

  let(:evaluator) { described_class.new(pet_a, pet_b) }

  describe 'initialization' do
    it 'assigns pet_a and pet_b' do
      first, second = mock, mock
      inst = described_class.new(first, second)
      inst.pet_a = first
      inst.pet_b = second
    end
  end

  describe '#contestants' do
    it 'returns an array of contestants' do
      evaluator.contestants.must_equal [pet_a, pet_b]
    end
  end

  describe '#evaluate!' do
    before do
      evaluator.expects(:identify_winner)
      evaluator.expects(:calculate_exp_gain).with(pet_a).returns(42)
      evaluator.expects(:calculate_exp_gain).with(pet_b).returns(24)
    end

    it 'calls #identify_winner and assigns experience gain for each pet' do
      evaluator.evaluate!
      evaluator.pet_a_exp_gain.must_equal 42
      evaluator.pet_b_exp_gain.must_equal 24
    end
  end

  describe '#calculate_exp_gain' do
    before { evaluator.instance_variable_set(:@winner, pet_a) }

    describe 'for winning pet' do
      it 'returns 20 points' do
        evaluator.calculate_exp_gain(pet_a).must_equal 20
      end
    end

    describe 'for loosing pet' do
      it 'returns 10 points' do
        evaluator.calculate_exp_gain(pet_b).must_equal 10
      end
    end
  end
end