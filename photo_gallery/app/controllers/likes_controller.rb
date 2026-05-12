class LikesController < ApplicationController
  before_action :set_photo

  def create
    if @photo.likes.create(user: current_user)
      @photo.reload
      @liked_by_current_user = @photo.likes.exists?(user: current_user)
    else
      @liked_by_current_user = false
      @error_message = "Failed to like photo"
    end
  end

  def destroy
    if @photo.likes.find_by(user: current_user).destroy
      @liked_by_current_user = current_user.likes.exists?(photo: @photo)
    else
      @liked_by_current_user = false
      @error_message = "Failed to unlike photo"
    end
  end

  private

  def set_photo
    @photo = Photo.find(params.expect(:photo_id))
  end
end