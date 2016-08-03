class SensesEvaluator < EvaluatorBase
  def coerced(pet)
    pet.senses * 1_000_000 + pet.experience
  end
end