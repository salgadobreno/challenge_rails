class Cart < ApplicationRecord
  has_many :cart_items

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

  def total_price
    cart_items.map { |e| e.total_price }.sum.to_f
  end

  def serializable_hash(options = nil)
    super({
      only: [:id],
      methods: [:total_price, :products]
    })
  end

  private

  def products
    cart_items
  end
end
