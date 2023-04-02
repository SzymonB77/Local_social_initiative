class AttendeesController < ApplicationController
  before_action :authenticate_user_or_admin, only: %i[create update destroy]
  before_action :set_attendee, only: %i[update destroy]
  before_action :set_event, only: %i[create destroy]

  # GET /events/:id/attendees
  def index
    @event = Event.find(params[:event_id])
    @attendees = @event.attendees
    render json: @attendees, each_serializer: SimpleAttendeeSerializer
  end

  # POST /events/:id/attendees
  def create
    @attendee = @event.attendees.build(attendee_params)
    @attendee.user = @current_user
    if @attendee.save
      render json: @attendee, serializer: AttendeeSerializer
    else
      render json: @attendee.errors, status: :unprocessable_entity
    end
  end

  # UPDATE /events/:id/attendees/:id
  def update
    if @current_user.attendees.find_by(event_id: @attendee.event_id,
                                       role: %w[host co-host]) && @attendee.update(admin_params)
      if admin_params[:role] == 'host'
        render json: { error: 'Cannot change host role' }, status: :unprocessable_entity
      elsif @attendee.update(admin_params)
        render json: @attendee, serializer: AttendeeSerializer
      else
        render json: @attendee.errors, status: :unprocessable_entity
      end
    else
      render json: { error: 'Unauthorized or invalid parameters' }, status: :unprocessable_entity
    end
  end

  # DELETE /events/:id/attendees/:id
  def destroy
    if @current_user.attendees.find_by(event_id: @attendee.event_id, role: %w[host co-host]) && @attendee.destroy
      render json: @attendee
    else
      render json: { error: 'Unauthorized' }, status: :unprocessable_entity
    end
  end

  private

  def set_attendee
    @attendee = Attendee.find(params[:id])
  end

  def set_event
    @event = Event.find(params[:event_id])
  end

  def attendee_params
    params.require(:attendee).permit(:id, :user_id, :event_id)
  end

  def admin_params
    params.require(:attendee).permit(:role)
  end
end
