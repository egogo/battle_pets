require File.expand_path '../test_helper.rb', __FILE__

describe 'AgilityEvaluator' do
  let(:pet_a) { PetServiceWrapper::Pet.new(3, 'Pet #1', 1, 1, 1, 1, 0, nil) }
  let(:pet_b) { PetServiceWrapper::Pet.new(7, 'Pet #2', 1, 1, 1, 1, 0, nil) }

  let(:described_class) { AgilityEvaluator }

  let(:evaluator) { described_class.new(pet_a, pet_b) }

  describe '#identify_winner' do
    describe 'pet with greater agility wins' do
      before do
        pet_a.agility = 3
        pet_b.agility = 5
      end

      it 'assigns and returns winner' do
        winner = evaluator.identify_winner
        winner.must_equal pet_b
        evaluator.winner.must_equal winner
      end
    end

    describe 'pet with more experience wins when agility is equal' do
      before do
        pet_a.agility = 5
        pet_a.experience = 20
        pet_b.agility = 5
        pet_b.experience = 10
      end

      it 'assigns and returns winner' do
        winner = evaluator.identify_winner
        winner.must_equal pet_a
        evaluator.winner.must_equal winner
      end
    end

    describe 'random pet wins when agility and experience is equal' do
      before do
        pet_a.agility = 5
        pet_a.experience = 10
        pet_b.agility = 5
        pet_b.experience = 10
      end

      it 'assigns and returns winner' do
        winner = evaluator.identify_winner
        [pet_a, pet_b].include?(winner).must_equal true
        evaluator.winner.must_equal winner
      end
    end
  end
end