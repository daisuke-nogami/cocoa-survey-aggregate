# cocoa-survey-aggregate
接触確認アプリCOCOA 最終アップデート版で行った調査結果の集計に使うスクリプト

## これはなに？
接触確認アプリCOCOA 最終アップデート版では、接触通知発生回数を把握するための調査を行いました。
集計結果を格納するサーバでは、接触通知発生回数はJSON形式で格納されていること、そもそも回収された回答は100万行を超えることから、Excelでの処理は行えないため、サーバに負荷を掛けずにローカルで処理が行えるよう、スクリプトを用いて集計を行うものです。

## スクリプトのテスト
sample.txtに作ったサンプルデータは、以下の6件の回答を含みます。

1. Q1=1, Q2=1, start_date=2022/11/01, exposure_data={2022/11/01 接触なし,11/05 接触あり,11/15 接触無し}
2. Q1=2, Q2=2, start_date=2022/11/01, exposure_data={無し}
3. Q1=無回答, Q2=3, start_date=2022/11/01, exposure_data={無し}
4. Q1=3, Q2=無回答, start_date=2022/11/01, exposure_data={無し}
5. Q1=4, Q2=1, start_date=無回答, exposure_data={無し}
6. 回答データ無し

このファイルを処理した時の結果が、以下のような出力になれば正しい挙動であるといえます。

```
Total records: 6
年代別回答者数:
Q1	count
1	1
2	1
N/A	2
3	1
4	1

通勤・通学の有無別回答者数:
Q2	count
1	2
2	1
3	1
N/A	2

年代別×通勤・通学の有無別回答者数:
Q1	Q2	count
1	1	1
2	2	1
N/A	3	1
3	N/A	1
4	1	1
N/A	N/A	1

インストール時期別回答者数:
Q3	count
2022/11/01	4
	2

回答者単位の通算通知発生回数別回答者数:
Exposure_notify_count	count
1	1
N/A	5

年代別:
Q1	Exposure_notify_count	count
1	1	1
2	N/A	1
N/A	N/A	2
3	N/A	1
4	N/A	1

通勤通学の有無別:
Q2	Exposure_notify_count	count
1	1	1
2	N/A	1
3	N/A	1
N/A	N/A	2
1	N/A	1

日次通知発生回数:
Exposure_notify_date	count
2022/11/05	1

回答者単位の通算接触判定発生回数別回答者数:
Exposure_detection_count	count
3	1
N/A	5

日次接触判定発生発生回数:
Exposure_detection_date	count
2022/11/01	1
2022/11/05	1
2022/11/15	1
```
