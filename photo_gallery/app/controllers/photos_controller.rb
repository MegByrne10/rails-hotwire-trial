class PhotosController < ApplicationController
  def index
    @photos = Photo.all
    @user_liked_photo_ids = current_user.liked_photos.pluck(:id)
  end
end