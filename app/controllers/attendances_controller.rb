class AttendancesController < ApplicationController
  before_action :set_user, only: [:edit_one_month, :update_one_month]
  before_action :logged_in_user, only: [:update, :edit_one_month, :edit_overwork_reqest, :update_overwork_reqest]
  before_action :admin_or_correct_user, only: [:update, :edit_one_month, :update_one_month]
  before_action :set_one_month, only: [:edit_one_month]
  
  UPDATE_ERROR_MSG = "勤怠登録に失敗しました。やり直してください。"
  
  def update
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:id])
    # 出勤時間が未登録であることを判定します。
    if @attendance.started_at.nil?
      if @attendance.update_attributes(started_at: Time.current.change(sec: 0))
        flash[:info] = "おはようございます！"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    elsif @attendance.finished_at.nil?
      if @attendance.update_attributes(finished_at: Time.current.change(sec: 0))
        flash[:info] = "お疲れ様でした。"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    end
    redirect_to @user
  end
  
  def edit_one_month
  end
  
  def update_one_month
    ActiveRecord::Base.transaction do # トランザクションを開始します。
      attendances_params.each do |id, item|
        if item[:started_at].blank? && item[:finished_at].present?
          flash[:danger] = "開始時間がないと終了時間の入力はできません。"
          redirect_to attendances_edit_one_month_user_url(date: params[:date]) and return
        elsif item[:started_at].present? && item[:finished_at].blank?
          flash[:danger] = "終了時間がないと開始時間の入力はできません。"
          redirect_to attendances_edit_one_month_user_url(date: params[:date]) and return
        else
          attendance = Attendance.find(id)
          attendance.update_attributes!(item)
        end
      end
    end
      flash[:success] = "1ヶ月分の勤怠情報を更新しました。"
      redirect_to user_url(date: params[:date]) and return
    
  rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐です。
    flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
    redirect_to attendances_edit_one_month_user_url(date: params[:date])
  end
  
  def edit_overwork_reqest
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:attendance_id])
    @superiors = User.where(superior: true).where.not(id: @user.id)
  end
  
  def update_overtime_reqest
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:attendance_id])
    params[:attendance][:over_request_status] = "申請中"
    if overwork_params[:scheduled_end_time].present?
      @attendance.update_attributes(overwork_params)
      flash[:info] = "残業申請をしました。"
    else
      flash[:danger] = "残業申請をキャンセルしました。"
    end
    redirect_to @user
  end
  
  private
  
   # 1ヶ月分の勤怠情報を扱います。
   def attendances_params
     params.require(:user).permit(attendances: [:started_at, :finished_at, :note])[:attendances]
   end
   
    def overwork_params
      params.require(:attendance).permit(:scheduled_end_time, :work_description, :next_day, :over_request_superior, :over_request_status)
    end
   
   # beforeフィルター
   
   # 管理権限者、または現在ログインしているユーザーを許可します。
   def admin_or_correct_user
     @user = User.find(params[:user_id]) if @user.blank?
     unless current_user?(@user) || current_user.admin?
       flash[:success] = "編集権限がありません。"
       redirect_to(root_url)
     end
   end
end
