class EventTagsController < ApplicationController
  before_action :authenticate_user_or_admin, only: %i[create destroy]
  before_action :set_event_tag, only: [:destroy]
  before_action :set_event, only: %i[create destroy]

  # GET /event/:id/event_tags
  def index
    @event = Event.find(params[:event_id])
    @event_tags = @event.tags.includes(:event_tags, :events)

    render json: @event_tags, each_serializer: TagSerializer
  end

  # POST /event/:id/event_tags
  def create
    if @current_user.attendees.find_by(event_id: @event.id, role: %w[host co-host]) || @current_user.role == 'admin'
      tag_name = event_tag_params[:tag][:name]
      tag = Tag.find_by(name: tag_name)
      @event_tag = @event.event_tags.build(tag: tag)

      if @event_tag.save
        render json: @event_tag

      else
        render json: @event_tag.errors, status: :unprocessable_entity
      end
    else
      render json: { error: 'Unauthorized or invalid parameters' }, status: :unprocessable_entity
    end
  end

  # DELETE /event/:id/event_tags/:id
  def destroy
    if @current_user.attendees.find_by(event_id: @event.id,
                                       role: %w[host
                                                co-host]) || @current_user.role == 'admin' && @event_tag.destroy
      render json: @event_tag
    else
      render json: { error: 'Unauthorized' }, status: :unprocessable_entity
    end
  end

  private

  def set_event_tag
    @event_tag = EventTag.find(params[:id])
  end

  def set_event
    @event = Event.find(params[:event_id])
  end

  def event_tag_params
    params.require(:event_tag).permit(:id, tag: [:name])
  end
end
