class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :edit_basic_info, :edit_basic_info_admin, :update_basic_info, :working_list, :attendance_log, :csv_export]
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy, :edit_basic_info, :update_basic_info, :attendance_log, :working_list]
  before_action :correct_user, only: [:edit, :update, :attendance_log]
  before_action :admin_user, only: [:destroy, :edit_basic_info, :update_basic_info]
  before_action :admin_or_correct_user, only: [:index, :show, :edit, :update, :working_list]
  before_action :set_one_month, only: [:show, :attendance_log, :csv_export]
  
  def index
    @users = User.paginate(page: params[:page],per_page: 10).search(params[:search])
  end
  
  def show
    @worked_sum = @attendances.where.not(started_at: nil).count
  end
  
 def csv_export
    respond_to do |format|
      format.html do
          #html用の処理を書く
      end 
      format.csv do
          #csv用の処理を書く
          send_data render_to_string,
          filename: "【勤怠】#{@user.name}_#{@first_day.strftime("%Y-%m")}.csv", type: :csv
      end
    end
  end  
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = "ユーザーを新規作成しました。"
      redirect_to @user
    else
      render :new
    end
  end
  
  def edit
  end
  
  def update
    if @user.update_attributes(user_params)
      flash[:success] = "ユーザー情報を更新しました。"
      redirect_to @user
    else
      render :edit
    end
  end
  
  def destroy
    @user.destroy
    flash[:success] = "#{@user.name}のデータを削除しました。"
    redirect_to users_url
  end
  
  def edit_basic_info
  end
  
  def edit_basic_info_admin
  end
  
  def working_list
    @users = User.all
  end
  
  def update_basic_info
    if @user.update_attributes(basic_info_params)
      flash[:success] = "#{@user.name}の基本情報を更新しました。"
    else
      flash[:danger] = "#{@user.name}の更新は失敗しました。<br>" + @user.errors.full_messages.join("<br>")
    end
    redirect_to users_url
  end
  
  def import
    # fileはtmp(temporary)に自動で一時保存される
    if params[:file].presence
      @regist_check = User.import(params[:file])
      
      if @regist_check
        flash[:success] = "CSVファイルのインポートが完了しました。"
      else
        flash[:danger] = "更新できるデータがありませんでした。"
      end
    else
      flash[:danger] = "CSVファイルが選択されていません。"
    end
    redirect_to users_url
  end

   # 勤怠修正ログ
  def attendance_log
    @attendances = Attendance.where(user_id: @user).where(c_approval: "承認").order(worked_on: "DESC")
    
    if params[:attendance].present?
      unless params[:attendance][:worked_on] == ""
        @search_date = params[:attendance][:worked_on] + "-1"
        @attendances = @attendances.where(started_at: @search_date.in_time_zone.all_year)
                                  .where(started_at: @search_date.in_time_zone.all_month)
        if @attendances.count == 0
          flash.now[:warning] = "承認済みの修正履歴がありません。"
        end
      else
        flash.now[:warning] = "年月を選択してください。"
      end
    end
  end
  
  private
  
  def user_params
    params.require(:user).permit(:name, :email, :department, :basic_work_time, :employee_number, :uid, :password, :password_confirmation)
  end
  
  def basic_info_params
    params.require(:user).permit(:name, :email, :department, :basic_work_time, :employee_number, :uid, :password, :password_confirmation)
  end
end
