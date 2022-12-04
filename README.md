# cocoa-survey-aggregate
接触確認アプリCOCOA 最終アップデート版で行った調査結果の集計に使うスクリプト

## これはなに？
接触確認アプリCOCOA 最終アップデート版では、接触通知発生回数を把握するための調査を行いました。
集計結果を格納するサーバでは、接触通知発生回数はJSON形式で格納されていること、そもそも回収された回答は100万行を超えることから、Excelでの処理は行えないため、サーバに負荷を掛けずにローカルで処理が行えるよう、スクリプトを用いて集計を行うものです。

## スクリプトのテスト
sample.txtに作ったサンプルデータは、以下の6件の回答を含みます。

1. Q1=1, Q2=1, start_date=2022/11/01, exposure_data={2022/11/01 接触なし,11/05 接触あり,11/15 接触無し}
2. Q1=2, Q2=2, start_date=2022/11/01, exposure_data={無し}
3. Q1=無回答, Q2=3, start_date=2022/11/05, exposure_data={無し}
4. Q1=3, Q2=無回答, start_date=2022/11/01, exposure_data={無し}
5. Q1=4, Q2=1, start_date=無回答, exposure_data={2022/11/01 接触なし,11/05 接触あり,11/15 接触無}
6. 回答データ無し

このファイルを処理した時の結果が、以下のような出力になれば正しい挙動であるといえます。

```
Total records: 6
年代別回答者数:
LABEL	Q1	count
Q1	1	1
Q1	2	1
Q1	N/A	2
Q1	3	1
Q1	4	1

通勤・通学の有無別回答者数:
LABEL	Q2	count
Q2	1	2
Q2	2	1
Q2	3	1
Q2	N/A	2

年代別×通勤・通学の有無別回答者数:
LABEL	Q1	Q2	count
Q1xQ2	1	1	1
Q1xQ2	2	2	1
Q1xQ2	N/A	3	1
Q1xQ2	3	N/A	1
Q1xQ2	4	1	1
Q1xQ2	N/A	N/A	1

インストール時期別回答者数:
LABEL	Q3	count
start_date	2022/11/01	3
start_date	2022/11/05	1
start_date		2

日次回答者数(インストール日回答者のみ):
LABEL	date	count
ans_bydate	2022-11-01	3
ans_bydate	2022-11-02	3
ans_bydate	2022-11-03	3
ans_bydate	2022-11-04	3
ans_bydate	2022-11-05	4
ans_bydate	2022-11-06	4
ans_bydate	2022-11-07	4
ans_bydate	2022-11-08	4
ans_bydate	2022-11-09	4
ans_bydate	2022-11-10	4
ans_bydate	2022-11-11	4
ans_bydate	2022-11-12	4
ans_bydate	2022-11-13	4
ans_bydate	2022-11-14	4
ans_bydate	2022-11-15	4
ans_bydate	2022-11-16	4

年代別:
LABEL	Q1	date	count
ans_bydate_q1	1	2022-11-01	1
ans_bydate_q1	1	2022-11-02	1
ans_bydate_q1	1	2022-11-03	1
ans_bydate_q1	1	2022-11-04	1
ans_bydate_q1	1	2022-11-05	1
ans_bydate_q1	1	2022-11-06	1
ans_bydate_q1	1	2022-11-07	1
ans_bydate_q1	1	2022-11-08	1
ans_bydate_q1	1	2022-11-09	1
ans_bydate_q1	1	2022-11-10	1
ans_bydate_q1	1	2022-11-11	1
ans_bydate_q1	1	2022-11-12	1
ans_bydate_q1	1	2022-11-13	1
ans_bydate_q1	1	2022-11-14	1
ans_bydate_q1	1	2022-11-15	1
ans_bydate_q1	1	2022-11-16	1
ans_bydate_q1	2	2022-11-01	1
ans_bydate_q1	2	2022-11-02	1
ans_bydate_q1	2	2022-11-03	1
ans_bydate_q1	2	2022-11-04	1
ans_bydate_q1	2	2022-11-05	1
ans_bydate_q1	2	2022-11-06	1
ans_bydate_q1	2	2022-11-07	1
ans_bydate_q1	2	2022-11-08	1
ans_bydate_q1	2	2022-11-09	1
ans_bydate_q1	2	2022-11-10	1
ans_bydate_q1	2	2022-11-11	1
ans_bydate_q1	2	2022-11-12	1
ans_bydate_q1	2	2022-11-13	1
ans_bydate_q1	2	2022-11-14	1
ans_bydate_q1	2	2022-11-15	1
ans_bydate_q1	2	2022-11-16	1
ans_bydate_q1	N/A	2022-11-05	1
ans_bydate_q1	N/A	2022-11-06	1
ans_bydate_q1	N/A	2022-11-07	1
ans_bydate_q1	N/A	2022-11-08	1
ans_bydate_q1	N/A	2022-11-09	1
ans_bydate_q1	N/A	2022-11-10	1
ans_bydate_q1	N/A	2022-11-11	1
ans_bydate_q1	N/A	2022-11-12	1
ans_bydate_q1	N/A	2022-11-13	1
ans_bydate_q1	N/A	2022-11-14	1
ans_bydate_q1	N/A	2022-11-15	1
ans_bydate_q1	N/A	2022-11-16	1
ans_bydate_q1	3	2022-11-01	1
ans_bydate_q1	3	2022-11-02	1
ans_bydate_q1	3	2022-11-03	1
ans_bydate_q1	3	2022-11-04	1
ans_bydate_q1	3	2022-11-05	1
ans_bydate_q1	3	2022-11-06	1
ans_bydate_q1	3	2022-11-07	1
ans_bydate_q1	3	2022-11-08	1
ans_bydate_q1	3	2022-11-09	1
ans_bydate_q1	3	2022-11-10	1
ans_bydate_q1	3	2022-11-11	1
ans_bydate_q1	3	2022-11-12	1
ans_bydate_q1	3	2022-11-13	1
ans_bydate_q1	3	2022-11-14	1
ans_bydate_q1	3	2022-11-15	1
ans_bydate_q1	3	2022-11-16	1

通勤通学の有無別:
LABEL	Q2	date	count
ans_bydate_q2	1	2022-11-01	1
ans_bydate_q2	1	2022-11-02	1
ans_bydate_q2	1	2022-11-03	1
ans_bydate_q2	1	2022-11-04	1
ans_bydate_q2	1	2022-11-05	1
ans_bydate_q2	1	2022-11-06	1
ans_bydate_q2	1	2022-11-07	1
ans_bydate_q2	1	2022-11-08	1
ans_bydate_q2	1	2022-11-09	1
ans_bydate_q2	1	2022-11-10	1
ans_bydate_q2	1	2022-11-11	1
ans_bydate_q2	1	2022-11-12	1
ans_bydate_q2	1	2022-11-13	1
ans_bydate_q2	1	2022-11-14	1
ans_bydate_q2	1	2022-11-15	1
ans_bydate_q2	1	2022-11-16	1
ans_bydate_q2	2	2022-11-01	1
ans_bydate_q2	2	2022-11-02	1
ans_bydate_q2	2	2022-11-03	1
ans_bydate_q2	2	2022-11-04	1
ans_bydate_q2	2	2022-11-05	1
ans_bydate_q2	2	2022-11-06	1
ans_bydate_q2	2	2022-11-07	1
ans_bydate_q2	2	2022-11-08	1
ans_bydate_q2	2	2022-11-09	1
ans_bydate_q2	2	2022-11-10	1
ans_bydate_q2	2	2022-11-11	1
ans_bydate_q2	2	2022-11-12	1
ans_bydate_q2	2	2022-11-13	1
ans_bydate_q2	2	2022-11-14	1
ans_bydate_q2	2	2022-11-15	1
ans_bydate_q2	2	2022-11-16	1
ans_bydate_q2	3	2022-11-05	1
ans_bydate_q2	3	2022-11-06	1
ans_bydate_q2	3	2022-11-07	1
ans_bydate_q2	3	2022-11-08	1
ans_bydate_q2	3	2022-11-09	1
ans_bydate_q2	3	2022-11-10	1
ans_bydate_q2	3	2022-11-11	1
ans_bydate_q2	3	2022-11-12	1
ans_bydate_q2	3	2022-11-13	1
ans_bydate_q2	3	2022-11-14	1
ans_bydate_q2	3	2022-11-15	1
ans_bydate_q2	3	2022-11-16	1
ans_bydate_q2	N/A	2022-11-01	1
ans_bydate_q2	N/A	2022-11-02	1
ans_bydate_q2	N/A	2022-11-03	1
ans_bydate_q2	N/A	2022-11-04	1
ans_bydate_q2	N/A	2022-11-05	1
ans_bydate_q2	N/A	2022-11-06	1
ans_bydate_q2	N/A	2022-11-07	1
ans_bydate_q2	N/A	2022-11-08	1
ans_bydate_q2	N/A	2022-11-09	1
ans_bydate_q2	N/A	2022-11-10	1
ans_bydate_q2	N/A	2022-11-11	1
ans_bydate_q2	N/A	2022-11-12	1
ans_bydate_q2	N/A	2022-11-13	1
ans_bydate_q2	N/A	2022-11-14	1
ans_bydate_q2	N/A	2022-11-15	1
ans_bydate_q2	N/A	2022-11-16	1

年代×通勤通学の有無別:
LABEL	Q1	Q2	date	count
ans_bydate_q1q2	1	1	2022-11-01	1
ans_bydate_q1q2	1	1	2022-11-02	1
ans_bydate_q1q2	1	1	2022-11-03	1
ans_bydate_q1q2	1	1	2022-11-04	1
ans_bydate_q1q2	1	1	2022-11-05	1
ans_bydate_q1q2	1	1	2022-11-06	1
ans_bydate_q1q2	1	1	2022-11-07	1
ans_bydate_q1q2	1	1	2022-11-08	1
ans_bydate_q1q2	1	1	2022-11-09	1
ans_bydate_q1q2	1	1	2022-11-10	1
ans_bydate_q1q2	1	1	2022-11-11	1
ans_bydate_q1q2	1	1	2022-11-12	1
ans_bydate_q1q2	1	1	2022-11-13	1
ans_bydate_q1q2	1	1	2022-11-14	1
ans_bydate_q1q2	1	1	2022-11-15	1
ans_bydate_q1q2	1	1	2022-11-16	1
ans_bydate_q1q2	2	2	2022-11-01	1
ans_bydate_q1q2	2	2	2022-11-02	1
ans_bydate_q1q2	2	2	2022-11-03	1
ans_bydate_q1q2	2	2	2022-11-04	1
ans_bydate_q1q2	2	2	2022-11-05	1
ans_bydate_q1q2	2	2	2022-11-06	1
ans_bydate_q1q2	2	2	2022-11-07	1
ans_bydate_q1q2	2	2	2022-11-08	1
ans_bydate_q1q2	2	2	2022-11-09	1
ans_bydate_q1q2	2	2	2022-11-10	1
ans_bydate_q1q2	2	2	2022-11-11	1
ans_bydate_q1q2	2	2	2022-11-12	1
ans_bydate_q1q2	2	2	2022-11-13	1
ans_bydate_q1q2	2	2	2022-11-14	1
ans_bydate_q1q2	2	2	2022-11-15	1
ans_bydate_q1q2	2	2	2022-11-16	1
ans_bydate_q1q2	N/A	3	2022-11-05	1
ans_bydate_q1q2	N/A	3	2022-11-06	1
ans_bydate_q1q2	N/A	3	2022-11-07	1
ans_bydate_q1q2	N/A	3	2022-11-08	1
ans_bydate_q1q2	N/A	3	2022-11-09	1
ans_bydate_q1q2	N/A	3	2022-11-10	1
ans_bydate_q1q2	N/A	3	2022-11-11	1
ans_bydate_q1q2	N/A	3	2022-11-12	1
ans_bydate_q1q2	N/A	3	2022-11-13	1
ans_bydate_q1q2	N/A	3	2022-11-14	1
ans_bydate_q1q2	N/A	3	2022-11-15	1
ans_bydate_q1q2	N/A	3	2022-11-16	1
ans_bydate_q1q2	3	N/A	2022-11-01	1
ans_bydate_q1q2	3	N/A	2022-11-02	1
ans_bydate_q1q2	3	N/A	2022-11-03	1
ans_bydate_q1q2	3	N/A	2022-11-04	1
ans_bydate_q1q2	3	N/A	2022-11-05	1
ans_bydate_q1q2	3	N/A	2022-11-06	1
ans_bydate_q1q2	3	N/A	2022-11-07	1
ans_bydate_q1q2	3	N/A	2022-11-08	1
ans_bydate_q1q2	3	N/A	2022-11-09	1
ans_bydate_q1q2	3	N/A	2022-11-10	1
ans_bydate_q1q2	3	N/A	2022-11-11	1
ans_bydate_q1q2	3	N/A	2022-11-12	1
ans_bydate_q1q2	3	N/A	2022-11-13	1
ans_bydate_q1q2	3	N/A	2022-11-14	1
ans_bydate_q1q2	3	N/A	2022-11-15	1
ans_bydate_q1q2	3	N/A	2022-11-16	1

インストール時期別:
LABEL	Q3	date	count
ans_bydate_q3	2022/11/01	2022-11-01	3
ans_bydate_q3	2022/11/01	2022-11-02	3
ans_bydate_q3	2022/11/01	2022-11-03	3
ans_bydate_q3	2022/11/01	2022-11-04	3
ans_bydate_q3	2022/11/01	2022-11-05	3
ans_bydate_q3	2022/11/01	2022-11-06	3
ans_bydate_q3	2022/11/01	2022-11-07	3
ans_bydate_q3	2022/11/01	2022-11-08	3
ans_bydate_q3	2022/11/01	2022-11-09	3
ans_bydate_q3	2022/11/01	2022-11-10	3
ans_bydate_q3	2022/11/01	2022-11-11	3
ans_bydate_q3	2022/11/01	2022-11-12	3
ans_bydate_q3	2022/11/01	2022-11-13	3
ans_bydate_q3	2022/11/01	2022-11-14	3
ans_bydate_q3	2022/11/01	2022-11-15	3
ans_bydate_q3	2022/11/01	2022-11-16	3
ans_bydate_q3	2022/11/05	2022-11-05	1
ans_bydate_q3	2022/11/05	2022-11-06	1
ans_bydate_q3	2022/11/05	2022-11-07	1
ans_bydate_q3	2022/11/05	2022-11-08	1
ans_bydate_q3	2022/11/05	2022-11-09	1
ans_bydate_q3	2022/11/05	2022-11-10	1
ans_bydate_q3	2022/11/05	2022-11-11	1
ans_bydate_q3	2022/11/05	2022-11-12	1
ans_bydate_q3	2022/11/05	2022-11-13	1
ans_bydate_q3	2022/11/05	2022-11-14	1
ans_bydate_q3	2022/11/05	2022-11-15	1
ans_bydate_q3	2022/11/05	2022-11-16	1

回答者単位の通算通知発生回数別回答者数:
LABEL	Exposure_notify_count	count
notify_person_all	1	1
notify_person_all	N/A	3

年代別:
LABEL	Q1	Exposure_notify_count	count
notify_person_q1	1	1	1
notify_person_q1	2	N/A	1
notify_person_q1	N/A	N/A	1
notify_person_q1	3	N/A	1

通勤通学の有無別:
LABEL	Q2	Exposure_notify_count	count
notify_person_q2	1	1	1
notify_person_q2	2	N/A	1
notify_person_q2	3	N/A	1
notify_person_q2	N/A	N/A	1

年代×通勤通学の有無別:
LABEL	Q1	Q2	Exposure_notify_count	count
notify_person_q1q2	1	1	1	1
notify_person_q1q2	2	2	N/A	1
notify_person_q1q2	N/A	3	N/A	1
notify_person_q1q2	3	N/A	N/A	1

日次通知発生回数:
LABEL	Exposure_notify_date	count
notify_daily_all	2022/11/05	1

年代別:
LABEL	Q1	Exposure_notify_date	count
notify_daily_q1	1	2022/11/05	1

通勤通学の有無別:
LABEL	Q2	Exposure_notify_date	count
notify_daily_q2	1	2022/11/05	1

年代×通勤通学の有無別:
LABEL	Q1	Q2	Exposure_notify_date	count
notify_daily_q1q2	1	1	2022/11/05	1

回答者単位の通算陽性者信号受信日数別回答者数:
LABEL	Exposure_detection_count	count
detection_person_all	3	1
detection_person_all	N/A	3

日次陽性者信号受信日数:
LABEL	Exposure_detection_date	count
detection_daily_all	2022/11/01	1
detection_daily_all	2022/11/05	1
detection_daily_all	2022/11/15	1
```
