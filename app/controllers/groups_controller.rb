class GroupsController < ApplicationController
  before_action :authenticate_user_or_admin, only: %i[create]
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
      render json: @group, serializer: GroupSerializer
    else
      render json: @group.errors, status: :unprocessable_entity
    end
  end

  # PUT /groups/:id
  def update
    if @group.update(group_params)
      render json: @group, serializer: GroupSerializer
    else
      render json: { errors: @group.errors.messages }, status: :unprocessable_entity
    end
  end

  # DELETE /groups/:id
  def destroy
    render json: @group if @group.destroy
  end

  private

  def set_group
    @group = Group.find(params[:id])
  end

  def group_params
    params.require(:group).permit(:id, :name, :description, :avatar)
  end
end
