require 'json'
require 'date'
require 'time'

# 結果を格納する変数群
q1 = {}   ## 年代別回答者数
q2 = {}   ## 通勤・通学の有無別回答者数
q1q2 = {} ## 年代別×通勤・通学の有無別回答者数
q3 = {}   ## インストール時期別回答者数
## 日次回答者数(インストール日回答者のみ)
ans_bydate = {}      ## 単純合計
ans_bydate_q1 = {}   ## 年代別
ans_bydate_q2 = {}   ## 通勤・通学の有無別
ans_bydate_q1q2 = {} ## 年代別×通勤・通学の有無別
ans_bydate_q3 = {}   ## インストール時期別
ans_bydate_q2q3m = {}   ## 通勤・通学の有無xインストール月別

## 回答者単位の通算通知発生回数別回答者数
notify_person_all = {} ### 単純合計
notify_person_q1 = {}  ### 年代別
notify_person_q2 = {}  ### 通勤・通学の有無別
notify_person_q1q2 = {}  ### 年代×通勤・通学の有無別
notify_person_q2q3m = {}  ### 通勤・通学の有無xインストール月別
### インストール時期(年月)別
## 日次通知発生回数
notify_daily_all = {} ### 単純合計
notify_daily_q1 = {}   ### 年代別
notify_daily_q2 = {}   ### 通勤・通学の有無別
notify_daily_q1q2 = {} ### 年代×通勤・通学の有無別
notify_daily_q2q3m = {}   ### 通勤・通学の有無xインストール月別

## 回答者単位の通算陽性者信号受信日数別回答者数
detection_person_all = {} ### 単純合計
detection_person_q1 = {} ### 年代別
detection_person_q2 = {} ### 通勤・通学の有無別
detection_person_q1q2 = {} ### 年代×通勤・通学の有無別
detection_person_q2q3m = {} ### 通勤・通学の有無xインストール月別
## 日次陽性者信号受信日数
detection_daily_all = {} ### 単純合計
detection_daily_q1 = {} ### 年代別
detection_daily_q2 = {} ### 通勤・通学の有無別
detection_daily_q1q2 = {} ### 年代×通勤・通学の有無別
detection_daily_q2q3m = {} ### 通勤・通学の有無xインストール月別

# 開始時刻を表示する
print "Start time: #{Time.now}\n"

# ハッシュを使ってカウントするための関数(keyが無いときに+=1が出来ないので)
def countup(var, key)
  if (var.has_key?(key)) then
    var[key] += 1
  else
    var[key] = 1
  end
end

# ハッシュ変数を展開してファイル出力する関数
def hashprint(label, f, hash)
  hash.each { |x|
    f.print(label, "\t", x[0].to_s.split(',').join("\t"), "\t", x[1], "\n")
  }
end

# 画面出力のバッファリングを止める
STDOUT.sync = true

# 引数にファイル名が指定されていたら
if ( ARGV.size ) then
  # 処理した行数を示す変数をクリア
  total_aggregate_lines = 0
  # 何個のファイルを処理するかを表示し
  print "Target: #{ARGV.size} file(s)...\n"
  # 何個目のファイルを処理しているかを保持する変数
  tgt_file_cnt = 0
  ARGV.each { | tgt |
    # 進捗を画面表示するための変数をクリアし
    total_lines = 0
    last_percent = 0
    cnt = 0
    # ファイルの行数を確認し
    tgt_file_cnt += 1
    print "Checking source file #{tgt} (#{tgt_file_cnt}/#{ARGV.size}) size...\n"
    total_lines = `wc #{tgt}`.split(/ +/)[1].to_i
    # 処理開始直前の時刻を保存しておき
    file_start_time = Time.now
    print "#{tgt} aggregation start time: #{file_start_time}\n"
    # 1行ずつ読み込んで処理する
    IO.foreach(tgt) { |x|
      # 処理行数をカウントし
      cnt += 1
      # 進捗を画面表示する（1%ごとに表示）
      if ( cnt*100/total_lines > last_percent ) then
        last_percent = cnt*100/total_lines
        print "Line: #{cnt} ( #{cnt*100/total_lines}% ), elapsed #{(Time.now - file_start_time).round} sec., estimate #{((Time.now - file_start_time)/last_percent*(100-last_percent)).round} sec. remain.\n"
      end
      # 余分な文字を取り除いてJSONとして成立するようにしてから
      ans_raw = x.gsub(/^\u{FEFF}\[/,'').gsub(/^\[/,'').gsub(/(\]$)/,'').gsub(/(^,)/,'').gsub(/\n/,'')
      next if (ans_raw == '')
      # JSONをHashに変換
      ans = JSON.parse(ans_raw)
      # 処理行数をカウント
      total_aggregate_lines += 1
      # 1個のレコードの回答を一時的な変数に格納する
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
      tmp_start_month = nil
      if (ans.has_key?('Content') && ans['Content'].has_key?('start_date') && ans['Content']['start_date']) then
        if (Time.at(ans['Content']['start_date']) < Time.at(Time.parse('2020/06/19'))) then
          tmp_start_date = '2020/06/19' # アプリ利用開始日が2020/06/18以前の場合は、初回リリース日を利用開始日とする
          tmp_start_month = '2020/06'   # アプリ利用開始日が2020/06/18以前の場合は、初回リリース日を利用開始日とする
        elsif (Time.at(ans['Content']['start_date']) > Time.at(Time.parse('2022/11/16'))) then
          tmp_start_date = "ERROR(After_register_stop)"  # アプリ利用開始日が陽性登録終了日以降の場合はエラー回答とする
          tmp_start_month = "ERROR(After_register_stop)" # アプリ利用開始日が陽性登録終了日以降の場合はエラー回答とする
        else
          tmp_start_date = Time.at(ans['Content']['start_date']).strftime("%Y/%m/%d") # インストール日
          tmp_start_month = Time.at(ans['Content']['start_date']).strftime("%Y/%m")   # インストール月
        end
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
      ## exposure_data_count (回答者の陽性者信号受信日数合計)
      if (tmp_exposure_data) then
        tmp_exposure_data_count = tmp_exposure_data.size
      else
        tmp_exposure_data_count = "N/A"
      end
      ## exposure_notify_count (回答者の接触通知発生回数合計)
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
      ## これ以降はアプリの利用開始日を回答した人に絞って集計
      if( tmp_start_date && tmp_start_date != 'ERROR(After_register_stop)') then
        ## インストール期間を展開
        if ( tmp_start_date > '2022/04/07' ) then
          tmp_first_date = tmp_start_date
        else
          tmp_first_date = "2022/04/07"
        end
        Date.parse(tmp_first_date).step(Date.parse('2022/11/16'),1) { |d|
          ## 日次回答者数(インストール日回答者のみ)
          countup(ans_bydate,d) ## 単純合計
          countup(ans_bydate_q1,"#{tmp_q1},#{d}")             ## 年代別
          countup(ans_bydate_q2,"#{tmp_q2},#{d}")             ## 通勤・通学の有無別
          countup(ans_bydate_q1q2,"#{tmp_q1},#{tmp_q2},#{d}") ## 年代別×通勤・通学の有無別
          countup(ans_bydate_q3,"#{tmp_start_date},#{d}")     ## インストール時期別
          countup(ans_bydate_q2q3m,"#{tmp_q2},#{tmp_start_month},#{d}") ## 通勤・通学の有無xインストール月別
        }
        ## 回答者単位の通算通知発生回数別回答者数
        countup(notify_person_all,tmp_exposure_notify_count) ### 単純合計
        countup(notify_person_q1,"#{tmp_q1},#{tmp_exposure_notify_count}") ### 年代別
        countup(notify_person_q2,"#{tmp_q2},#{tmp_exposure_notify_count}") ### 通勤通学の有無別
        countup(notify_person_q1q2,"#{tmp_q1},#{tmp_q2},#{tmp_exposure_notify_count}") ### 通勤通学の有無別
        countup(notify_person_q2q3m,"#{tmp_q2},#{tmp_start_month},#{tmp_exposure_notify_count}") ### 通勤通学の有無xインストール月別
        ## 日次通知発生回数
        if tmp_exposure_data then
          tmp_exposure_data.each { |ds|
            if (ds[1] > 0) then
              countup(notify_daily_all,ds[0]) ### 単純合計
              countup(notify_daily_q1,"#{tmp_q1},#{ds[0]}")             ## 年代別
              countup(notify_daily_q2,"#{tmp_q2},#{ds[0]}")             ## 通勤・通学の有無別
              countup(notify_daily_q1q2,"#{tmp_q1},#{tmp_q2},#{ds[0]}") ## 年代別×通勤・通学の有無別
              countup(notify_daily_q2q3m,"#{tmp_q2},#{tmp_start_month},#{ds[0]}")             ## 通勤・通学の有無xインストール月別
            end
          }
        end
        ## 回答者単位の通算陽性者信号受信日数別回答者数
        countup(detection_person_all,tmp_exposure_data_count) ### 単純合計
        countup(detection_person_q1,"#{tmp_q1},#{tmp_exposure_data_count}") ### 年代別
        countup(detection_person_q2,"#{tmp_q2},#{tmp_exposure_data_count}") ### 通勤通学の有無別
        countup(detection_person_q1q2,"#{tmp_q1},#{tmp_q2},#{tmp_exposure_data_count}") ### 通勤通学の有無別
        countup(detection_person_q2q3m,"#{tmp_q2},#{tmp_start_month},#{tmp_exposure_data_count}") ### 通勤通学の有無xインストール月別
        ## 陽性者信号受信日数
        if tmp_exposure_data then
          tmp_exposure_data.each { |ds|
            countup(detection_daily_all,ds[0]) ### 単純合計
            countup(detection_daily_q1,"#{tmp_q1},#{ds[0]}")             ## 年代別
            countup(detection_daily_q2,"#{tmp_q2},#{ds[0]}")             ## 通勤・通学の有無別
            countup(detection_daily_q1q2,"#{tmp_q1},#{tmp_q2},#{ds[0]}") ## 年代別×通勤・通学の有無別
            countup(detection_daily_q2q3m,"#{tmp_q2},#{tmp_start_month},#{ds[0]}")             ## 通勤・通学の有無xインストール月別
          }
        end
      end
    }
  }
  # 結果をファイルに出力する
  File.open("result.txt", "w+") do |f|
    f.print("Total records: ", total_aggregate_lines, "\n")
    f.print("年代別回答者数: \nLABEL\tQ1\tcount\n")
    hashprint("Q1", f, q1)
    f.print("\n")
    f.print("通勤・通学の有無別回答者数: \nLABEL\tQ2\tcount\n")
    hashprint("Q2", f, q2)
    f.print("\n")
    f.print("年代別×通勤・通学の有無別回答者数: \nLABEL\tQ1\tQ2\tcount\n")
    hashprint("Q1xQ2", f, q1q2)
    f.print("\n")
    f.print("インストール時期別回答者数: \nLABEL\tQ3\tcount\n")
    hashprint("start_date", f, q3)
    f.print("\n")
    f.print("日次回答者数(インストール日回答者のみ): \nLABEL\tdate\tcount\n")
    hashprint("ans_bydate", f, ans_bydate)
    f.print("\n")
    f.print("年代別: \nLABEL\tQ1\tdate\tcount\n")
    hashprint("ans_bydate_q1", f, ans_bydate_q1)
    f.print("\n")
    f.print("通勤通学の有無別: \nLABEL\tQ2\tdate\tcount\n")
    hashprint("ans_bydate_q2", f, ans_bydate_q2)
    f.print("\n")
    f.print("年代×通勤通学の有無別: \nLABEL\tQ1\tQ2\tdate\tcount\n")
    hashprint("ans_bydate_q1q2", f, ans_bydate_q1q2)
    f.print("\n")
    f.print("インストール時期別: \nLABEL\tQ3\tdate\tcount\n")
    hashprint("ans_bydate_q3", f, ans_bydate_q3)
    f.print("\n")
    f.print("通勤通学の有無xインストール月別: \nLABEL\tQ2\tQ3\tdate\tcount\n")
    hashprint("ans_bydate_q2q3m", f, ans_bydate_q2q3m)
    f.print("\n")
    f.print("回答者単位の通算通知発生回数別回答者数: \nLABEL\tExposure_notify_count\tcount\n")
    hashprint("notify_person_all", f, notify_person_all)
    f.print("\n")
    f.print("年代別: \nLABEL\tQ1\tExposure_notify_count\tcount\n")
    hashprint("notify_person_q1", f, notify_person_q1)
    f.print("\n")
    f.print("通勤通学の有無別: \nLABEL\tQ2\tExposure_notify_count\tcount\n")
    hashprint("notify_person_q2", f, notify_person_q2)
    f.print("\n")
    f.print("年代×通勤通学の有無別: \nLABEL\tQ1\tQ2\tExposure_notify_count\tcount\n")
    hashprint("notify_person_q1q2", f, notify_person_q1q2)
    f.print("\n")
    f.print("通勤通学の有無xインストール月別: \nLABEL\tQ2\tQ3\tExposure_notify_count\tcount\n")
    hashprint("notify_person_q2q3m", f, notify_person_q2q3m)
    f.print("\n")
    f.print("日次通知発生回数: \nLABEL\tExposure_notify_date\tcount\n")
    hashprint("notify_daily_all", f, notify_daily_all)
    f.print("\n")
    f.print("年代別: \nLABEL\tQ1\tExposure_notify_date\tcount\n")
    hashprint("notify_daily_q1", f, notify_daily_q1)
    f.print("\n")
    f.print("通勤通学の有無別: \nLABEL\tQ2\tExposure_notify_date\tcount\n")
    hashprint("notify_daily_q2", f, notify_daily_q2)
    f.print("\n")
    f.print("年代×通勤通学の有無別: \nLABEL\tQ1\tQ2\tExposure_notify_date\tcount\n")
    hashprint("notify_daily_q1q2", f, notify_daily_q1q2)
    f.print("\n")
    f.print("通勤通学の有無xインストール月別: \nLABEL\tQ2\tQ3\tExposure_notify_date\tcount\n")
    hashprint("notify_daily_q2q3m", f, notify_daily_q2q3m)
    f.print("\n")
    f.print("回答者単位の通算陽性者信号受信日数別回答者数: \nLABEL\tExposure_detection_count\tcount\n")
    hashprint("detection_person_all", f, detection_person_all)
    f.print("\n")
    f.print("年代別: \nLABEL\tQ1\tExposure_detection_count\tcount\n")
    hashprint("detection_person_q1", f, detection_person_q1)
    f.print("\n")
    f.print("通勤通学の有無別: \nLABEL\tQ2\tExposure_detection_count\tcount\n")
    hashprint("detection_person_q2", f, detection_person_q2)
    f.print("\n")
    f.print("年代×通勤通学の有無別: \nLABEL\tQ1\tQ2\tExposure_detection_count\tcount\n")
    hashprint("detection_person_q1q2", f, detection_person_q1q2)
    f.print("\n")
    f.print("通勤通学の有無xインストール月別: \nLABEL\tQ2\tQ3\tExposure_detection_count\tcount\n")
    hashprint("detection_person_q2q3m", f, detection_person_q2q3m)
    f.print("\n")
    f.print("日次陽性者信号受信日数: \nLABEL\tExposure_detection_date\tcount\n")
    hashprint("detection_daily_all", f, detection_daily_all)
    f.print("\n")
    f.print("年代別: \nLABEL\tQ1\tExposure_detection_date\tcount\n")
    hashprint("detection_daily_q1", f, detection_daily_q1)
    f.print("\n")
    f.print("通勤通学の有無別: \nLABEL\tQ2\tExposure_detection_date\tcount\n")
    hashprint("detection_daily_q2", f, detection_daily_q2)
    f.print("\n")
    f.print("年代×通勤通学の有無別: \nLABEL\tQ1\tQ2\tExposure_detection_date\tcount\n")
    hashprint("detection_daily_q1q2", f, detection_daily_q1q2)
    f.print("\n")
    f.print("通勤通学の有無xインストール月別: \nLABEL\tQ2\tQ3\tExposure_detection_date\tcount\n")
    hashprint("detection_daily_q2q3m", f, detection_daily_q2q3m)
    f.print("\n")
  end
end
