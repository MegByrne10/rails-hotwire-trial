require 'rails_helper'

RSpec.describe Like, type: :model do
  it "allows only one like per user for a specific photo" do
    user = User.create!(email: "unique@example.com", password: "password123")
    photo = Photo.create!(
      photographer_name: "Unique Test",
      source_md_url: "https://example.com/unique.jpg",
      source_url: "https://example.com/unique"
    )
    Like.create!(user:, photo:)

    duplicate_like = Like.new(user:, photo:)

    expect(duplicate_like).not_to be_valid
    expect(duplicate_like.errors[:user_id]).to include("has already been taken")
  end
end
