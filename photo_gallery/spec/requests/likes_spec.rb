require "rails_helper"

RSpec.describe "Likes", type: :request do
  let(:user) { User.create!(email: "liker@example.com", password: "password123") }
  let(:photo) do
    Photo.create!(
      photographer_name: "Victor",
      source_md_url: "https://example.com/victor.jpg",
      source_url: "https://example.com/victor"
    )
  end

  describe "POST /photos/:photo_id/like" do
    it "redirects unauthenticated users to sign in" do
      post photo_like_path(photo), as: :turbo_stream

      expect(response).to redirect_to(new_user_session_path)
    end

    it "creates a like and returns turbo stream response" do
      sign_in user

      expect do
        post photo_like_path(photo), as: :turbo_stream
      end.to change(Like, :count).by(1)

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq(Mime[:turbo_stream].to_s)
      expect(photo.reload.likes_count).to eq(1)
    end

    it "does not create a duplicate like for the same user and photo" do
      sign_in user
      Like.create!(user:, photo:)

      expect do
        post photo_like_path(photo), as: :turbo_stream
      end.not_to change(Like, :count)

      expect(response).to have_http_status(:ok)
      expect(photo.reload.likes_count).to eq(1)
    end
  end

  describe "DELETE /photos/:photo_id/like" do
    it "redirects unauthenticated users to sign in" do
      delete photo_like_path(photo), as: :turbo_stream

      expect(response).to redirect_to(new_user_session_path)
    end

    it "destroys an existing like and returns turbo stream response" do
      sign_in user
      Like.create!(user:, photo:)

      expect do
        delete photo_like_path(photo), as: :turbo_stream
      end.to change(Like, :count).by(-1)

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq(Mime[:turbo_stream].to_s)
      expect(photo.reload.likes_count).to eq(0)
    end
  end
end
