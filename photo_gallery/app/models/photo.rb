class Photo < ApplicationRecord
  has_many :likes, dependent: :destroy
  has_many :user_likes, through: :likes, source: :user

  validates :photographer_name, :source_md_url, :source_url, presence: true, uniqueness: true
end
