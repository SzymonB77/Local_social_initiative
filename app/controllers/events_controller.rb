class EventsController < ApplicationController
  before_action :authenticate_user_or_admin, only: %i[create]
  before_action :set_event, only: %i[show update destroy]

  # GET /events
  def index
    @events = Event.all
    render json: @events, each_serializer: SimpleEventSerializer
  end

  # GET /events/:id
  def show
    render json: @event, serializer: EventSerializer
  end

  # POST /events
  def create
    @event = Event.new(event_params)

    if @event.save
      render json: @event, serializer: EventSerializer
    else
      render json: @event.errors, status: :unprocessable_entity
    end
  end

  # PUT /events/:id
  def update
    if @event.update(event_params)
      render json: @event, serializer: EventSerializer
    else
      render json: { errors: @event.errors.messages }, status: :unprocessable_entity
    end
  end

  # DELETE /events/:id
  def destroy
    render json: @event if @event.destroy
  end

  private

  def set_event
    @event = Event.find(params[:id])
  end

  def set_user
    @user = User.find(params[:id])
  end

  def event_params
    params.require(:event).permit(:id, :name, :start_date, :end_date, :status, :location, :description)
  end
end
