  CSV.generate(encoding: Encoding::SJIS, write_headers: true, force_quotes: true) do |csv|
      csv_headers = ["日付","曜日","変更前出社時間","変更前退社時間","備考"]
      day_of_the_week = ["日", "月", "火", "水", "木", "金", "土"]
      csv << csv_headers
      @attendances.each do |day|
        values = [
          day.worked_on.strftime('%m/%d'),
          day_of_the_week[day.worked_on.wday],
          day&.edit_day_started_at&.strftime('%H:%M'),
          day&.edit_day_finished_at&.strftime('%H:%M'),
          day.note
        ]
  
        csv << values
      end   
    end 
