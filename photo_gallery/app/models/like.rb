class Like < ApplicationRecord
  belongs_to :user, required: true
  belongs_to :photo, required: true, counter_cache: true

  validates :user_id, uniqueness: { scope: :photo_id }
end
