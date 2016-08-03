class Pet < Sequel::Model
  MAX_PROP_VALUE = 30
  def validate
    super
    errors.add(:strength, 'too high') if strength > MAX_PROP_VALUE
    errors.add(:agility, 'too high') if agility > MAX_PROP_VALUE
    errors.add(:wit, 'too high') if wit > MAX_PROP_VALUE
    errors.add(:senses, 'too high') if senses > MAX_PROP_VALUE
  end

  def self.create_random
    create(
        name: Haikunator.haikunate(0,' '),
        strength: rand(MAX_PROP_VALUE),
        agility: rand(MAX_PROP_VALUE),
        wit: rand(MAX_PROP_VALUE),
        senses: rand(MAX_PROP_VALUE),
        experience: 0
    )
  end

  def increment_experience(earned_value)
    update(experience: (self.experience + earned_value.to_i))
  end
end