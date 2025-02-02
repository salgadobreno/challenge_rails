class Cart < ApplicationRecord
  validates_numericality_of :total_price, greater_than_or_equal_to: 0

  def mark_as_abandoned
    last_interaction_diff = Time.zone.now - last_interaction_at

    self.update(abandoned: true) if last_interaction_diff > 3.hours
  end

  def remove_if_abandoned
    last_interaction_diff = Time.zone.now - last_interaction_at

    if last_interaction_at > 7.days
      self.destroy
    end
  end
end
