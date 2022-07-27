module AttendancesHelper

  def attendance_state(attendance)
    # 受け取ったAttendanceオブジェクトが当日と一致するか評価します。
    if Date.current == attendance.worked_on
      return '出勤' if attendance.started_at.nil?
      return '退勤' if attendance.started_at.present? && attendance.finished_at.nil?
    end
    # どれにも当てはまらなかった場合はfalseを返します。
    false
  end
  
   # 出勤時間と退勤時間を受け取り、在社時間を計算して返します。
   def working_times(start, finish)
     format("%.2f", (((finish - start) / 60) / 60.0))
   end
   
     def working_overtime(scheduled_end_time, designated_work_end_time, next_day)
    if  next_day == "1"
      
      format("%.2f", (scheduled_end_time.hour - designated_work_end_time.hour) + ((scheduled_end_time.min - designated_work_end_time.min) / 60.0) +24)
    elsif next_day == "0"
      format("%.2f", (scheduled_end_time.hour - designated_work_end_time.hour) + ((scheduled_end_time.min - designated_work_end_time.min) / 60.0))
    end
  end
  
  def superiors(over_request_superior)
    User.find(over_request_superior)
  end
end

