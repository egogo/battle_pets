class EvaluatorBase
  attr_accessor :pet_a, :pet_b, :winner, :pet_a_exp_gain, :pet_b_exp_gain

  def initialize(pet_a, pet_b)
    @pet_a = pet_a
    @pet_b = pet_b
  end

  def contestants
    [pet_a, pet_b]
  end

  def evaluate!
    identify_winner
    @pet_a_exp_gain = calculate_exp_gain(pet_a)
    @pet_b_exp_gain = calculate_exp_gain(pet_b)
  end

  def calculate_exp_gain(pet)
    winner == pet ? 20 : 10
  end

  def identify_winner
    @winner = if coerced(contestants[0]) == coerced(contestants[1])
                contestants[rand(1)]
              else
                contestants.max {|a,b| coerced(a) <=> coerced(b) }
              end
  end

  def coerced(pet)
    raise StandardError.new('Implement in subclass')
  end
end