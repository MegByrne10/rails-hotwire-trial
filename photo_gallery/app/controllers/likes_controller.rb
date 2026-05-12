class LikesController < ApplicationController
  before_action :set_photo

  def create
    @photo.likes.create!(user: current_user)
    redirect_to @photo
  end

  def destroy
    @photo.likes.find_by(user: current_user).destroy
    redirect_to @photo
  end
end