class GroupsController < ApplicationController
  before_action :authenticate_user_or_admin, only: %i[create update destroy]
  before_action :set_group, only: %i[show update destroy]

  # GET /groups
  def index
    @groups = Group.all
    render json: @groups, each_serializer: SimpleGroupSerializer
  end

  # GET /groups/:id
  def show
    render json: @group, serializer: GroupSerializer
  end

  # POST /groups
  def create
    @group = Group.new(group_params)

    if @group.save

      # add the current user as an organizer to the new event
      @group.members.create(user_id: @current_user.id, role: 'organizer')

      render json: @group, serializer: GroupSerializer
    else
      render json: @group.errors, status: :unprocessable_entity
    end
  end

  # PUT /groups/:id
  def update
    # check if current user is an admin attendee for this event
    member = @group.members.find_by(user_id: @current_user.id,
                                    role: %w[organizer
                                             co-organizer]) || @current_user.role == 'admin'

    if member.present? && @group.update(group_params)
      render json: @group, serializer: GroupSerializer
    else
      render json: { errors: 'Only organizer and co-organizer can update this event' }, status: :unprocessable_entity
    end
  end

  # DELETE /groups/:id
  def destroy
    # check if current user is an organizer for this event
    member = @group.members.find_by(user_id: @current_user.id, role: %w[organizer]) || @current_user.role == 'admin'

    if member.present? && @group.destroy
      render json: @group, serializer: GroupSerializer
    else
      render json: { errors: 'Only organizer can delete this event' }, status: :unprocessable_entity
    end
  end

  private

  def set_group
    @group = Group.find(params[:id])
  end

  def group_params
    params.require(:group).permit(:id, :name, :description, :avatar)
  end
end
