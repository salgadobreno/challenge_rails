class Cart < ApplicationRecord
  has_many :cart_items

  def register_item(product:, quantity:)
    return if quantity < 1
    product_item = cart_items.find_by(product:)

    if product_item
      product_item.update!(quantity:)
    else
      cart_items.create!(product:, quantity:)
    end
    interacted!
  end

  def add_item(product:, quantity:)
    product_item = cart_items.find_by(product:)
    return if !product_item
    new_qty = [0, product_item.quantity + quantity].max

    if product_item
      product_item.update!(quantity: new_qty)
    else
      cart_items.create!(product:, quantity:)
    end
    interacted!
  end

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

  def interacted!
    update(last_interaction_at: Time.zone.now)
  end
end
