class GroupEventsController < ApplicationController
  before_action :authenticate_user_or_admin, only: %i[create update destroy]
  before_action :set_event, only: %i[show update destroy]
  before_action :set_group, only: %i[create]

  # GET /groups/:id/events
  def index
    @group = Group.find(params[:group_id])
    @events = @group.events

    render json: @events, each_serializer: SimpleEventSerializer
  end

  # GET /groups/:id/events/:id
  def show
    render json: @event, serializer: EventSerializer
  end

  # POST /groups/:id/events
  def create
    if @current_user.members.find_by(group_id: @group.id, role: %w[organizer co-organizer])

      @event = Event.new(event_params)
      @event.group = @group
      if @event.save

        @event.attendees.create(user_id: @current_user.id, role: 'host')

        render json: @event, serializer: EventSerializer
      else
        render json: @event.errors, status: :unprocessable_entity
      end
    else
      render json: { error: 'Unauthorized or invalid parameters' }, status: :unprocessable_entity
    end
  end

  # PUT /groups/:id/events/:id
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

  # DELETE /groups/:id/events/:id
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
  end

  def set_group
    @group = Group.find(params[:group_id])
  end

  def event_params
    params.require(:event).permit(:id, :name, :start_date, :end_date, :status, :location, :description, :group_id)
  end
end
