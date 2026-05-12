require "rails_helper"

RSpec.describe "Gallery authentication flow", type: :system do
  it "redirects guests to the sign-in page when visiting the gallery" do
    visit root_path

    expect(page).to have_current_path(new_user_session_path, ignore_query: true)
    expect(page).to have_text("Sign in")
  end

  it "lets a user sign in, see the gallery, and sign out" do
    user = User.create!(email: "system@example.com", password: "password123")
    photo = Photo.create!(
      photographer_name: "System Photographer",
      source_md_url: "https://example.com/system.jpg",
      source_url: "https://example.com/system",
      likes_count: 0
    )

    visit new_user_session_path
    fill_in "Email", with: user.email
    fill_in "Password", with: "password123"
    click_button "Sign in"

    expect(page).to have_current_path(root_path)
    expect(page).to have_text("All Photos")
    expect(page).to have_text(photo.photographer_name)
    expect(page).to have_button("Log out")

    click_button "Log out"

    expect(page).to have_current_path(new_user_session_path)
    expect(page).to have_text("Sign in")
  end

  it "renders expected star states and updates when liking/unliking a photo", js: true do
    user = User.create!(email: "starstate@example.com", password: "password123")
    other_user_1 = User.create!(email: "other1@example.com", password: "password123")
    other_user_2 = User.create!(email: "other2@example.com", password: "password123")

    zero_likes_photo = Photo.create!(
      photographer_name: "Zero Likes",
      source_md_url: "https://example.com/zero.jpg",
      source_url: "https://example.com/zero",
      likes_count: 0
    )

    liked_photo = Photo.create!(
      photographer_name: "Has Likes",
      source_md_url: "https://example.com/liked.jpg",
      source_url: "https://example.com/liked",
      likes_count: 0
    )
    Like.create!(user: other_user_1, photo: liked_photo)
    Like.create!(user: other_user_2, photo: liked_photo)

    visit new_user_session_path
    fill_in "Email", with: user.email
    fill_in "Password", with: "password123"
    click_button "Sign in"

    within("#like_photo_#{zero_likes_photo.id}") do
      expect(page).to have_css(".text-gray-400")
      expect(page).to have_text("0")
    end

    within("#like_photo_#{liked_photo.id}") do
      expect(page).to have_css(".text-gray-400")
      expect(page).to have_text("2")
    end

    within("#like_photo_#{zero_likes_photo.id}") do
      find("button").click
      expect(page).to have_css(".text-yellow-400")
      expect(page).to have_text("1")
    end
    expect(page).to have_current_path(root_path)

    within("#like_photo_#{zero_likes_photo.id}") do
      find("button").click
      expect(page).to have_css(".text-gray-400")
      expect(page).to have_text("0")
    end
    expect(page).to have_current_path(root_path)
  end
end
