  CSV.generate(encoding: Encoding::SJIS, write_headers: true, force_quotes: true) do |csv|
      csv_headers = ["日付","曜日", "出社時間", "退社時間","変更後出社時間","変更後退社時間","備考"]
      day_of_the_week = ["日", "月", "火", "水", "木", "金", "土"]
      csv << csv_headers
      @attendances.each do |day|
        values = [
          day.worked_on.strftime('%m/%d'),
          day_of_the_week[day.worked_on.wday],
          day&.started_at&.strftime('%H:%M'),
          day&.finished_at&.strftime('%H:%M'),
          day&.last_edit_day_started_at&.strftime('%H:%M'),
          day&.last_edit_day_finished_at&.strftime('%H:%M'),
          day.note
        ]
  
        csv << values
      end   
    end 
