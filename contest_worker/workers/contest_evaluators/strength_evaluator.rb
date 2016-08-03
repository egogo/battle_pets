class StrengthEvaluator < EvaluatorBase
  def coerced(pet)
    pet.strength * 1_000_000 + pet.experience
  end
end