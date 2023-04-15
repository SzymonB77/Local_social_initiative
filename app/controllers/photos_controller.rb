class PhotosController < ApplicationController
  before_action :authenticate_user_or_admin, only: %i[create destroy]
  before_action :set_photo, only: %i[show destroy]
  before_action :set_event, only: %i[create destroy]

  # GET /events/:id/photos
  def index
    @event = Event.find(params[:event_id])
    @photos = @event.photos.includes(:user)
    render json: @photos, each_serializer: PhotoSerializer
  end

  # GET /events/:id/photos/:id
  def show
    render json: @photo, serializer: PhotoSerializer
  end

  # POST /events/:id/photos
  def create
    if @current_user.attendees.find_by(event_id: @event.id,
                                       role: %w[host
                                                co-host]) || @current_user.role == 'admin' && @photo.destroy
      @photo = @event.photos.build(photo_params)
      @photo.user = @current_user
      if @photo.save
        render json: @photo, serializer: PhotoSerializer
      else
        render json: @photo.errors, status: :unprocessable_entity
      end

    else
      render json: { error: 'Unauthorized' }, status: :unprocessable_entity
    end
  end

  # DELETE /events/:id/photos/:id
  def destroy
    if @current_user.attendees.find_by(event_id: @event.id,
                                       role: %w[host
                                                co-host]) || @current_user.role == 'admin' && @photo.destroy
      render json: @photo
    else
      render json: { error: 'Unauthorized' }, status: :unprocessable_entity
    end
  end

  private

  def set_photo
    @photo = Photo.find(params[:id])
  end

  def set_event
    @event = Event.find(params[:event_id])
  end

  def photo_params
    params.require(:photo).permit(:id, :url, :user_id, :event_id)
  end
end
