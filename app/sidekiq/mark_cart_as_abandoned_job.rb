class MarkCartAsAbandonedJob
  include Sidekiq::Job

  def perform(*args)
    Cart.stale.in_batches(of: 500) do |carts|
      carts.each { |cart|
        cart.mark_as_abandoned
      }
    end
    Cart.dead.in_batches(of: 500) do |carts|
      carts.each { |cart| 
        cart.remove_if_abandoned
      }
    end
  end
end
