require File.expand_path '../test_helper.rb', __FILE__

describe 'SensesEvaluator' do
  let(:pet_a) { PetServiceWrapper::Pet.new(3, 'Pet #1', 1, 1, 1, 1, 0, nil) }
  let(:pet_b) { PetServiceWrapper::Pet.new(7, 'Pet #2', 1, 1, 1, 1, 0, nil) }

  let(:described_class) { SensesEvaluator }

  let(:evaluator) { described_class.new(pet_a, pet_b) }

  describe '#identify_winner' do
    describe 'pet with greater senses wins' do
      before do
        pet_a.senses = 6
        pet_b.senses = 12
      end

      it 'assigns and returns winner' do
        winner = evaluator.identify_winner
        winner.must_equal pet_b
        evaluator.winner.must_equal winner
      end
    end

    describe 'pet with more experience wins when senses is equal' do
      before do
        pet_a.senses = 7
        pet_a.experience = 30
        pet_b.senses= 7
        pet_b.experience = 10
      end

      it 'assigns and returns winner' do
        winner = evaluator.identify_winner
        winner.must_equal pet_a
        evaluator.winner.must_equal winner
      end
    end

    describe 'random pet wins when senses and experience is equal' do
      before do
        pet_a.senses = 15
        pet_a.experience = 20
        pet_b.senses = 15
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