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
Q1 answers:
N/A     2
1       1
2       1
3       1
4       1
5       0
6       0
7       0
8       0
9       0
Q2 answers:
N/A     2
1       2
2       1
3       1
Start_date answers:
N/A     1
2022/11/01      4
Exposure_data counts:
N/A     4
3       1
Exposure_notify counts:
N/A     0
1       1
```
