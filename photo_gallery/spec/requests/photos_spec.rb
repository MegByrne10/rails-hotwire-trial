require "rails_helper"

RSpec.describe "Photos", type: :request do
  describe "GET /" do
    it "redirects unauthenticated users to sign in" do
      get root_path

      expect(response).to redirect_to(new_user_session_path)
    end

    it "renders the gallery for authenticated users" do
      user = User.create!(email: "viewer@example.com", password: "password123")
      photo = Photo.create!(
        photographer_name: "Felix",
        source_md_url: "https://example.com/photo.jpg",
        source_url: "https://example.com/source",
        likes_count: 0
      )
      sign_in user

      get root_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("All Photos")
      expect(response.body).to include(photo.photographer_name)
    end
  end
end
