class WitEvaluator < EvaluatorBase
  def coerced(pet)
    pet.wit * 1_000_000 + pet.experience
  end
end