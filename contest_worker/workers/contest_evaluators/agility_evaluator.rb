class AgilityEvaluator < EvaluatorBase
  def coerced(pet)
    pet.agility * 1_000_000 + pet.experience
  end
end