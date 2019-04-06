# Cs2C ～CLASSの時間割をCSVにするやつ～

## 概要

Cs2C は，東京理科大学の学生向けシステム「[CLASS](https://class.admin.tus.ac.jp)」から時間割データを抽出し，  
[Google Calendar](https://calendar.google.com/calendar/) などのスケジュール管理アプリで利用できるCSV形式で保存する Ruby スクリプトです．

## 使い方

```
$ git clone https://github.com/wiperS200/Cs2C.git
$ ruby Cs2C.rb
```

### 必要なもの

- Ruby 2.5.1 以上
- Firefox  
- [geckodriver](https://github.com/mozilla/geckodriver/releases) 
- gem "selenium-webdriver"

### 注意事項

- CLASS のメンテ期間中は使えません
- CLASS のカレンダーに表示されない授業（試験など）は取得できません
- 休講情報を取得できません（今後対応予定）
- 短時間の間に複数回使うと理科大当局からDoS攻撃と判断されるかもしれません

## License

This code is licensed under AGPL-3.0. See `LICENSE`.

