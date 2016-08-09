class Contest < Sequel::Model
  AVAILABLE_TYPES = %w(strength wit agility senses).freeze

  dataset_module do
    def for_contestant(contestant_id = nil)
      return self unless contestant_id
      where(Sequel.or(first_pet_id: contestant_id, second_pet_id: contestant_id))
    end
  end

  def validate
    super
    errors.add(:type, 'must be one of: strength, wit, agility, senses.') unless AVAILABLE_TYPES.include?(type)
  end

  def set_winner(id)
    update(winner_id: id, finished_at: Time.now)
  end
end