class Contest < Sequel::Model
  AVAILABLE_TYPES = %w(strength wit agility senses).freeze
  def validate
    super
    errors.add(:type, 'must be one of: strength, wit, agility, senses.') unless AVAILABLE_TYPES.include?(type)
  end

  def set_winner(id)
    update(winner_id: id, finished_at: Time.now)
  end
end