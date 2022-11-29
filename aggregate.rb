require 'json'

# 進捗を画面表示するための変数
total_lines = 0
last_percent = 0
cnt = 0

# 結果を格納する変数群
q1 = {}   ## 年代別回答者数
q2 = {}   ## 通勤・通学の有無別回答者数
q1q2 = {} ## 年代別×通勤・通学の有無別回答者数
q3 = {}   ## インストール時期別回答者数

## 回答者単位の通算通知発生回数別回答者数
notify_person_all = {} ### 単純合計
notify_person_q1 = {}  ### 年代別
notify_person_q2 = {}  ### 通勤・通学の有無別
## 日次通知発生回数
notify_daily_all = {} ### 単純合計
### 年代別
### 通勤・通学の有無別
### インストール時期(年月)別

## 回答者単位の通算接触判定発生回数別回答者数
detection_person_all = {} ### 単純合計
### 年代別
### 通勤・通学の有無別
### インストール時期(年月)別
## 日次接触判定発生発生回数
detection_daily_all = {} ### 単純合計
### 年代別
### 通勤・通学の有無別
### インストール時期(年月)別

# ハッシュを使ってカウントするための関数(keyが無いときに+=1が出来ないので)
def countup(var, key)
  if (var.has_key?(key)) then
    var[key] += 1
  else
    var[key] = 1
  end
end

# ハッシュ変数を展開してファイル出力する関数
def hashprint(f, hash)
  hash.each { |x|
    f.print(x[0].to_s.split(',').join("\t"), "\t", x[1], "\n")
  }
end

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
    # 進捗を画面表示する（1%ごとに表示）
    if ( cnt*100/total_lines > last_percent ) then
      print "Line: #{cnt} ( #{cnt*100/total_lines}% )\n"
      last_percent = cnt*100/total_lines
    end
    # 余分な文字を取り除いてJSONとして成立するようにしてから
    ans_raw = x.gsub(/^\u{FEFF}\[/,'').gsub(/^\[/,'').gsub(/(\]$)/,'').gsub(/(^,)/,'')
    next if (ans_raw == '')
    # JSONをHashに変換
    ans = JSON.parse(ans_raw)
    # 回答を一時的な変数に格納する
    ## Q1
    tmp_q1 = "N/A"
    if (ans.has_key?('Content') && ans['Content'].has_key?('q1') && ans['Content']['q1']) then
      tmp_q1 = ans['Content']['q1']
    end
    ## Q2
    tmp_q2 = "N/A"
    if (ans.has_key?('Content') && ans['Content'].has_key?('q2') && ans['Content']['q2']) then
      tmp_q2 = ans['Content']['q2']
    end
    ## start_date
    tmp_start_date = nil
    if (ans.has_key?('Content') && ans['Content'].has_key?('start_date') && ans['Content']['start_date']) then
      tmp_start_date = Time.at(ans['Content']['start_date']).strftime("%Y/%m/%d")
    end
    ## exposure_data
    if (ans.has_key?('Content') && ans['Content'].has_key?('exposure_data')) then
      tmp_exposure_data = {}
      if (ans['Content']['exposure_data'] && ans['Content']['exposure_data'].has_key?('daily_summaries')) then
        ans['Content']['exposure_data']['daily_summaries'].each { |ds|
          tmp_exposure_data[Time.at(ds['DateMillisSinceEpoch']/1000).strftime("%Y/%m/%d")] = ds['ExposureDetected']
        }
      end
    else
      tmp_exposure_data = nil
    end
    ## exposure_data_count
    if (tmp_exposure_data) then
      tmp_exposure_data_count = tmp_exposure_data.size
    else
      tmp_exposure_data_count = "N/A"
    end
    ## exposure_notify_count
    if tmp_exposure_data then
      tmp_exposure_notify_count = 0
      tmp_exposure_data.each { |ds|
        if (ds[1] > 0) then
          tmp_exposure_notify_count += 1
        end
      }
    else
      tmp_exposure_notify_count = "N/A"
    end

    # 集計をする
    countup(q1,tmp_q1) ## 年代別回答者数
    countup(q2,tmp_q2) ## 通勤・通学の有無別回答者数
    countup(q1q2,"#{tmp_q1},#{tmp_q2}") ## 年代別×通勤・通学の有無別回答者数
    countup(q3,tmp_start_date) ## インストール時期別回答者数
    ## 回答者単位の通算通知発生回数別回答者数
    countup(notify_person_all,tmp_exposure_notify_count) ### 単純合計
    countup(notify_person_q1,"#{tmp_q1},#{tmp_exposure_notify_count}") ### 年代別
    countup(notify_person_q2,"#{tmp_q2},#{tmp_exposure_notify_count}") ### 通勤通学の有無別
    ## 日次通知発生回数
    if tmp_exposure_data then
      tmp_exposure_data.each { |ds|
        if (ds[1] > 0) then
          countup(notify_daily_all,ds[0]) ### 単純合計
        end
      }
    end
    ## 回答者単位の通算接触判定発生回数別回答者数
    countup(detection_person_all,tmp_exposure_data_count) ### 単純合計
    ## 日次接触判定発生発生回数
    if tmp_exposure_data then
      tmp_exposure_data.each { |ds|
        countup(detection_daily_all,ds[0]) ### 単純合計
      }
    end
  }

  # 結果をファイルに出力する
  File.open("result.txt", "w+") do |f|
    f.print("Total records: ", cnt, "\n")
    f.print("年代別回答者数: \nQ1\tcount\n")
    hashprint(f, q1)
    f.print("\n")
    f.print("通勤・通学の有無別回答者数: \nQ2\tcount\n")
    hashprint(f, q2)
    f.print("\n")
    f.print("年代別×通勤・通学の有無別回答者数: \nQ1\tQ2\tcount\n")
    hashprint(f, q1q2)
    f.print("\n")
    f.print("インストール時期別回答者数: \nQ3\tcount\n")
    hashprint(f, q3)
    f.print("\n")
    f.print("回答者単位の通算通知発生回数別回答者数: \nExposure_notify_count\tcount\n")
    hashprint(f, notify_person_all)
    f.print("\n")
    f.print("年代別: \nQ1\tExposure_notify_count\tcount\n")
    hashprint(f, notify_person_q1)
    f.print("\n")
    f.print("通勤通学の有無別: \nQ2\tExposure_notify_count\tcount\n")
    hashprint(f, notify_person_q2)
    f.print("\n")
    f.print("日次通知発生回数: \nExposure_notify_date\tcount\n")
    hashprint(f, notify_daily_all)
    f.print("\n")
    f.print("回答者単位の通算接触判定発生回数別回答者数: \nExposure_detection_count\tcount\n")
    hashprint(f, detection_person_all)
    f.print("\n")
    f.print("日次接触判定発生発生回数: \nExposure_detection_date\tcount\n")
    hashprint(f, detection_daily_all)
    f.print("\n")
  end
end
