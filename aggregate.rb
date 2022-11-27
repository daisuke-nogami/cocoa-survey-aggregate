require 'json'

# 結果を格納する変数群
total_lines = 0
last_percent = 0
cnt = 0
q1 = {
  "N/A"=> 0,
  1=> 0,
  2=> 0,
  3=> 0,
  4=> 0,
  5=> 0,
  6=> 0,
  7=> 0,
  8=> 0,
  9=> 0
}
q2 = {
  "N/A"=> 0,
  1=> 0,
  2=> 0,
  3=> 0
}
start_date = {
  "N/A"=> 0
}
exposure_data_count = {
  "N/A"=> 0
}
exposure_notify_count = {
  "N/A"=> 0
}

# 画面出力のバッファリングを止める
STDOUT.sync = true

# 引数にファイル名が指定されていたら
if ( ARGV[0] ) then
  # ファイルの行数を確認し
  print "Checking source file size...\n"
  total_lines = `wc #{ARGV[0]}`.split(/ +/)[1].to_i
  # 1行ずつ読み込んで処理する
  IO.foreach(ARGV[0]) { |x|
    # 処理行数をカウントし
    cnt += 1
    if ( cnt*100/total_lines > last_percent ) then
      print "Line: #{cnt} ( #{cnt*100/total_lines}% )\n"
      last_percent = cnt*100/total_lines
    end
    # 余分な文字を取り除いてJSONとして成立するようにしてから
    ans_raw = x.gsub(/^\u{FEFF}\[/,'').gsub(/^\[/,'').gsub(/(\]$)/,'').gsub(/(^,)/,'')
    next if (ans_raw == '')
    # JSONをHashに変換
    ans = JSON.parse(ans_raw)
    if (ans.has_key?('Content')) then
      if (ans['Content'].has_key?('q1')) then
        if (ans['Content']['q1']) then
          q1[ans['Content']['q1']] += 1
        else
          q1["N/A"] += 1
        end
      else
        q1["N/A"] += 1
      end
      if (ans['Content'].has_key?('q2')) then
        if (ans['Content']['q2']) then
          q2[ans['Content']['q2']] += 1
        else
          q2["N/A"] += 1
        end
      else
        q2["N/A"] += 1
      end
      if (ans['Content'].has_key?('start_date')) then
        if (ans['Content']['start_date']) then
          if (start_date.has_key?(Time.at(ans['Content']['start_date']).strftime("%Y/%m/%d"))) then
            start_date[Time.at(ans['Content']['start_date']).strftime("%Y/%m/%d")] +=1
          else
            start_date[Time.at(ans['Content']['start_date']).strftime("%Y/%m/%d")] =1
          end
        else
          start_date["N/A"] += 1
        end
      else
        start_date["N/A"] += 1
      end

      if (ans['Content'].has_key?('exposure_data')) then
        if (ans['Content']['exposure_data']) then
          if (ans['Content']['exposure_data'].has_key?('daily_summaries')) then
            if (exposure_data_count.has_key?(ans['Content']['exposure_data']['daily_summaries'].size)) then
              exposure_data_count[ans['Content']['exposure_data']['daily_summaries'].size] += 1
            else
              exposure_data_count[ans['Content']['exposure_data']['daily_summaries'].size] = 1
            end

            if (ans['Content']['exposure_data']['daily_summaries'].size > 0) then
              ds_detected = 0
              ans['Content']['exposure_data']['daily_summaries'].each { |ds|
                if ds['ExposureDetected'] > 0 then
                  ds_detected += 1
                end
              }
              if (exposure_notify_count.has_key?(ds_detected)) then
                exposure_notify_count[ds_detected] += 1
              else
                exposure_notify_count[ds_detected] = 1
              end
            end
          else
            exposure_data_count["N/A"] += 1
          end
        else
          exposure_data_count["N/A"] += 1
        end
      else
        exposure_data_count["N/A"] += 1
      end

    else
      q1["N/A"] += 1
      q2["N/A"] += 1
    end
  }

  File.open("result.txt", "w+") do |f|
    f.print("Total records: ", cnt, "\n")
    f.print("Q1 answers: \n")
    q1.each { |q1e|
      f.print(q1e[0], "\t", q1e[1], "\n")
    }
    f.print("Q2 answers: \n")
    q2.each { |q2e|
      f.print(q2e[0], "\t", q2e[1], "\n")
    }
    f.print("Start_date answers: \n")
    start_date.each { |start_datee|
      f.print(start_datee[0], "\t", start_datee[1], "\n")
    }
    f.print("Exposure_data counts: \n")
    exposure_data_count.each { |exposure_data_counte|
      f.print(exposure_data_counte[0], "\t", exposure_data_counte[1], "\n")
    }
    f.print("Exposure_notify counts: \n")
    exposure_notify_count.each { |exposure_notify_counte|
      f.print(exposure_notify_counte[0], "\t", exposure_notify_counte[1], "\n")
    }
  end
end
