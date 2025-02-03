require 'rails_helper'
RSpec.describe MarkCartAsAbandonedJob, type: :job do
  describe 'perform' do
    it 'marks carts not interacted with for over 3 hours as abandoned' do
      time_fresh = 1.hour.ago
      time_stale = 5.hours.ago
      10.times {
        create(:cart, last_interaction_at: time_fresh, abandoned: false)
      }
      20.times {
        create(:cart, last_interaction_at: time_stale, abandoned: false)
      }

      expect {
        MarkCartAsAbandonedJob.new().perform
      }.to change(Cart.abandoned, :count).by(20)
    end

    it 'destroys jobs abandoned for over 7 days' do
      time_fresh = 1.day.ago
      time_stale = 10.days.ago
      10.times {
        create(:cart, last_interaction_at: time_fresh, abandoned: true)
      }
      20.times {
        create(:cart, last_interaction_at: time_stale, abandoned: true)
      }

      expect {
        MarkCartAsAbandonedJob.new().perform
      }.to change(Cart.abandoned, :count).by(-20)
    end
  end
end
