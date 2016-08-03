require File.expand_path '../test_helper.rb', __FILE__

describe 'StrengthEvaluator' do
  let(:pet_a) { PetServiceWrapper::Pet.new(3, 'Pet #1', 1, 1, 1, 1, 0, nil) }
  let(:pet_b) { PetServiceWrapper::Pet.new(7, 'Pet #2', 1, 1, 1, 1, 0, nil) }

  let(:described_class) { StrengthEvaluator }

  let(:evaluator) { described_class.new(pet_a, pet_b) }

  describe '#identify_winner' do
    describe 'pet with greater strength wins' do
      before do
        pet_a.strength = 4
        pet_b.strength = 8
      end

      it 'assigns and returns winner' do
        winner = evaluator.identify_winner
        winner.must_equal pet_b
        evaluator.winner.must_equal winner
      end
    end

    describe 'pet with more experience wins when strength is equal' do
      before do
        pet_a.strength = 2
        pet_a.experience = 30
        pet_b.strength= 2
        pet_b.experience = 10
      end

      it 'assigns and returns winner' do
        winner = evaluator.identify_winner
        winner.must_equal pet_a
        evaluator.winner.must_equal winner
      end
    end

    describe 'random pet wins when strength and experience is equal' do
      before do
        pet_a.strength = 10
        pet_a.experience = 20
        pet_b.strength = 10
        pet_b.experience = 20
      end

      it 'assigns and returns winner' do
        winner = evaluator.identify_winner
        [pet_a, pet_b].include?(winner).must_equal true
        evaluator.winner.must_equal winner
      end
    end
  end
end