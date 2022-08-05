class AttendancesController < ApplicationController
  before_action :set_user, only: [:edit_one_month, :update_one_month, :edit_monthly_request]
  before_action :logged_in_user, only: [:update, :edit_one_month, :edit_overwork_reqest, :update_overwork_reqest, :edit_monthly_request]
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
     @superiors = User.where(superior: true).where.not(id: @user.id)
  end
  
  def update_one_month
    c1 = 0
    ActiveRecord::Base.transaction do # トランザクションを開始します。
      attendances_params.each do |id, item|
        attendance = Attendance.find(id)
        if item[:edit_day_request_superior].present?
          item[:edit_day_request_status] = "申請中"
          c1 += 1
          attendance.update_attributes!(item)
        end
      end
    end
    if c1 > 0
      flash[:success] = "勤怠編集を#{c1}件、申請しました。"
      redirect_to user_url(date: params[:date])
    else
      flash[:danger] = "上長を選択してください"
      redirect_to attendances_edit_one_month_user_url(date: params[:date])
    end  
    
  rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐です。
    flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
    redirect_to attendances_edit_one_month_user_url(date: params[:date])
  end
  
  # 残業申請モーダル
  def edit_overwork_reqest
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:attendance_id])
    @superiors = User.where(superior: true).where.not(id: @user.id)
  end
  
  # 残業申請モーダルからのリクエストを保存
  def update_overwork_reqest
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
  
  # 上長側、残業申請通知画面をポップアップで表示
  def edit_overwork_notice
    @user = User.find(params[:user_id])
    @attendances = Attendance.where(over_request_status: "申請中", over_request_superior: @user.id).order(:worked_on).group_by(&:user_id)
  end
  
  # 上長側、残業申請結果を送信する機能
  def edit_overwork_approval
    @user = User.find(params[:user_id])
    c1 = 0
    ActiveRecord::Base.transaction do # トランザクションを開始します。
      overwork_approval_params.each do |id, item|
        attendance = Attendance.find(id)
        if item[:change] == "1"
          c1 += 1
          attendance.update_attributes!(item)
        end
      end
    end
    flash[:success] = "残業申請の結果を#{c1}件、送信しました"
    redirect_to @user
  rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐です。
    flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
    redirect_to @user
  end
  
  # 勤怠変更申請お知らせモーダル
  def edit_day_notice
    @user = User.find(params[:user_id])
    @superiors = User.where(superior: true).where.not(id: @user.id)
    @attendances = Attendance.where(edit_day_request_status: "申請中", edit_day_request_superior: @user.id).order(:worked_on).group_by(&:user_id)
  end
  
  #勤怠変更申請結果を送信するアクション
  def edit_day_approval
    @user = User.find(params[:user_id])
    c1 = 0
    ActiveRecord::Base.transaction do # トランザクションを開始します。
      edit_day_approval_params.each do |id, item|
        attendance = Attendance.find(id)
        if item[:edit_day_check_confirm] == "1"
          c1 += 1
          attendance.update_attributes!(item)
        end
      end
    end
    flash[:success] = "勤怠編集申請の#{c1}件、結果を送信しました"
    redirect_to @user
  rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐です。
    flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
    redirect_to @user
  end
  
  # 右下の月の勤怠申請アクション
  def edit_monthly_request
    @apply = @user.attendances.find_by(worked_on: params[:date])
    params[:edit_one_month_request_status] = "申請中"
    @apply.update_attributes(monthly_request_params)
    flash[:success] = "1ヶ月分の勤怠情報を申請しました。"
    redirect_to user_url(current_user)
  end  
  
  # 月の勤怠申請のお知らせ画面　モーダルで表示
  def edit_one_month_notice
    @user = User.find(params[:user_id])
    @attendances = Attendance.where(edit_one_month_request_status: "申請中", edit_one_month_request_superior: @user.id).order(:worked_on).group_by(&:user_id)
  end  
  
  # 月の勤怠申請結果を送信　アクション
  def edit_one_month_approval
    @user = User.find(params[:user_id])
    c1 = 0
    ActiveRecord::Base.transaction do # トランザクションを開始します。
      monthly_approval_params.each do |id, item|
        attendance = Attendance.find(id)
        if item[:edit_one_month_check_confirm] == "1"
          c1 += 1
          attendance.update_attributes!(item)
        end
      end
    end
    flash[:success] = "所属長承認申請の結果を#{c1}件、送信しました"
    redirect_to @user
  rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐です。
    flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
    redirect_to @user
  end
  
  private
  
  # beforeフィルター
  
  # 1ヶ月分の勤怠情報を扱います。
  def attendances_params
      params.require(:user).permit(attendances: [:started_at,
                                                 :finished_at,
                                                 :note,
                                                 :next_day,
                                                 :edit_day_request_superior,
                                                 :edit_day_request_status,
                                                 :edit_day_started_at,
                                                 :edit_day_finished_at,
                                                 :last_edit_day_started_at,
                                                 :last_edit_day_finished_at])[:attendances]
    end
   
  def overwork_params
    params.require(:attendance).permit(:scheduled_end_time, :work_description, :next_day, :over_request_superior, :over_request_status)
  end

  def overwork_approval_params
    params.require(:user).permit(attendances: [:over_request_status, :change])[:attendances]
  end
  
  def edit_day_approval_params
    params.require(:user).permit(attendances: [:edit_day_request_status, :edit_day_check_confirm])[:attendances]
  end
  
  def monthly_request_params
    params.permit(:edit_one_month_request_superior, :edit_one_month_request_status)
  end
  
  def monthly_approval_params
    params.require(:user).permit(attendances: [:edit_one_month_request_status, :edit_one_month_check_confirm])[:attendances]
  end  
   
   # 管理権限者、または現在ログインしているユーザーを許可します。
   def admin_or_correct_user
     @user = User.find(params[:user_id]) if @user.blank?
     unless current_user?(@user) || current_user.admin?
       flash[:success] = "編集権限がありません。"
       redirect_to(root_url)
     end
   end
end
