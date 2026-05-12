require 'rails_helper'

RSpec.describe Photo, type: :model do
  describe "likes_count counter cache" do
    it "tracks like count when likes are created and removed" do
      user = User.create!(email: "counter@example.com", password: "password123")
      photo = Photo.create!(
        photographer_name: "Counter Test",
        source_md_url: "https://example.com/counter.jpg",
        source_url: "https://example.com/counter"
      )

      expect(photo.likes_count).to eq(0)

      like = Like.create!(user:, photo:)
      expect(photo.reload.likes_count).to eq(1)

      like.destroy!
      expect(photo.reload.likes_count).to eq(0)
    end
  end
end
