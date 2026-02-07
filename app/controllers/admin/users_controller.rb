# frozen_string_literal: true

module Admin
  class UsersController < BaseController
    def index
      per = 20
      page = [params[:page].to_i, 1].max
      @users = User.order(created_at: :desc).limit(per).offset((page - 1) * per)
      @users_total = User.count
      @users_total_pages = (@users_total.to_f / per).ceil
      @users_current_page = page
    end

    def destroy
      @user = User.find(params[:id])
      if @user == current_user
        flash[:alert] = "You cannot delete your own account."
        redirect_to admin_users_path and return
      end
      if @user.admin?
        flash[:alert] = "You cannot delete an admin account."
        redirect_to admin_users_path and return
      end
      @user.destroy
      flash[:notice] = "User account has been deleted."
      redirect_to admin_users_path
    end

    def ban
      @user = User.find(params[:id])
      if @user == current_user
        flash[:alert] = "You cannot ban yourself."
        redirect_to admin_users_path and return
      end
      if @user.admin?
        flash[:alert] = "You cannot ban an admin account."
        redirect_to admin_users_path and return
      end
      @user.ban!
      flash[:notice] = "User has been banned."
      redirect_to admin_users_path
    end

    def unban
      @user = User.find(params[:id])
      @user.unban!
      flash[:notice] = "User has been unbanned."
      redirect_to admin_users_path
    end
  end
end
