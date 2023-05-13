class EventsController < ApplicationController
  before_action :authenticate_user_or_admin, only: %i[create update destroy]
  before_action :set_event, only: %i[update destroy]

  # GET /events
  def index
    @events = Event.all
    render json: @events, each_serializer: SimpleEventSerializer
  end

  # GET /events/:id
  def show
    begin
      @event = Event.includes(attendees: :user, photos: :user).find(params[:id])
      render json: @event, serializer: EventSerializer
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Event not found" }, status: :not_found
    end
  end

  # POST /events
  def create
    @event = Event.new(event_params)

    if @event.save

      # add the current user as an attendee to the new event
      @event.attendees.create(user_id: @current_user.id, role: 'host')

      render json: @event, serializer: EventSerializer
    else
      render json: @event.errors, status: :unprocessable_entity
    end
  end

  # PUT /events/:id
  def update
    # check if current user is an admin attendee for this event
    attendee = @event.attendees.find_by(user_id: @current_user.id,
                                        role: %w[host co-host]) || @current_user.role == 'admin'

    if attendee.present? && @event.update(event_params)
      render json: @event, serializer: EventSerializer
    else
      render json: { errors: 'Only host can update this event' }, status: :unprocessable_entity
    end
  end

  # DELETE /events/:id
  def destroy
    # check if current user is an admin attendee for this event
    attendee = @event.attendees.find_by(user_id: @current_user.id, role: 'host') || @current_user.role == 'admin'

    if attendee.present? && @event.destroy
      render json: @event, serializer: EventSerializer
    else
      render json: { errors: 'Only host can delete this event' }, status: :unprocessable_entity
    end
  end

  private

  def set_event
    @event = Event.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Event not found' }, status: :not_found
  end

  def event_params
    params.require(:event).permit(:id, :name, :start_date, :end_date, :status, :location, :description)
  end
end
