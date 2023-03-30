class AttendeesController < ApplicationController
  before_action :authenticate_admin, only: [:index]
  before_action :authenticate_user_or_admin, only: [:create, :destroy]
  before_action :set_attendee, only: [:destroy]
  before_action :set_event, only: [:create, :destroy]

  # GET /events/attendees
  def index
    @attendees = Attendee.all
    render json: @attendees, each_serializer: AttendeeSerializer
  end

  # POST /events/attendees
  def create
    @attendee = @event.attendees.build(attendee_params)
    @attendee.user = @current_user
    if @attendee.save
      render json: @attendee, serializer: AttendeeSerializer
    else
      render json: @attendee.errors, status: :unprocessable_entity
    end
  end

  # DELETE /events/attendees/:id
  def destroy
    render json: @attendee if @attendee.destroy
  end

  private

  def set_attendee
    @attendee = Attendee.find(params[:id])
  end

  def set_event
    @event = Event.find(params[:event_id])
  end

  def attendee_params
    params.require(:attendee).permit(:id, :admin, :user_id, :event_id)
  end

end
