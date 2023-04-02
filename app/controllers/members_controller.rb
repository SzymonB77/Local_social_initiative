class MembersController < ApplicationController
  before_action :authenticate_user_or_admin, only: %i[create update destroy]
  before_action :set_member, only: %i[update destroy]
  before_action :set_group, only: %i[create destroy]

  # GET /groups/:id/members
  def index
    @group = Group.find(params[:group_id])
    @members = @group.members
    render json: @members, each_serializer: SimpleMemberSerializer
  end

  # POST /groups/:id/members
  def create
    @member = @group.members.build(member_params)
    @member.user = @current_user
    if @member.save
      render json: @member, serializer: MemberSerializer
    else
      render json: @member.errors, status: :unprocessable_entity
    end
  end

  # UPDATE /groups/:id/members/:id
  def update
    if @current_user.members.find_by(group_id: @member.group_id,
                                     role: %w[organizer
                                              co-organizer]) || @current_user.role == 'admin' && @member.update(admin_params)
      if admin_params[:role] == 'organizer'
        render json: { error: 'Cannot change organizer role' }, status: :unprocessable_entity
      elsif @member.update(admin_params)
        render json: @member, serializer: MemberSerializer
      else
        render json: @member.errors, status: :unprocessable_entity
      end
    else
      render json: { error: 'Unauthorized or invalid parameters' }, status: :unprocessable_entity
    end
  end

  # DELETE /groups/:id/members/:id
  def destroy
    if @current_user.members.find_by(group_id: @member.group_id,
                                     role: %w[organizer
                                              co-organizer]) || @current_user.role == 'admin' || @current_user.id == @member.user_id && @member.destroy
      render json: @member
    else
      render json: { error: 'Unauthorized' }, status: :unprocessable_entity
    end
  end

  private

  def set_group
    @group = Group.find(params[:group_id])
  end

  def set_member
    @member = Member.find(params[:id])
  end

  def member_params
    params.require(:member).permit(:id, :user_id, :group_id)
  end

  def admin_params
    params.require(:member).permit(:role)
  end
end
