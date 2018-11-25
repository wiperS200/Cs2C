require 'selenium-webdriver'
require 'csv'
require 'date'

# Selenium::WebDriver::Firefox.driver_path = "geckodriver/geckodriver.exe" neriでコンパイルの際はコメントアウトを取る

# 時間いろいろ
today = Date.today
limitMonths = 2
nMonthDate = today >> limitMonths-1
nMonthFirstDay = Date.new(nMonthDate.year, nMonthDate.month,  1)
nMonthEndDay   = Date.new(nMonthDate.year, nMonthDate.month, -1)
_1gen = [ "8:50:00", "10:30:00",  "0:00:00"]
_2gen = ["10:30:00", "12:00:00", "10:20:00"]
_3gen = ["12:50:00", "14:20:00", "12:40:00"]
_4gen = ["14:30:00", "16:00:00", "14:20:00"]
_5gen = ["16:10:00", "17:40:00", "16:00:00"]
_6gen = ["18:00:00", "19:30:00", "17:50:00"]
_7gen = ["19:40:00", "21:10:00", "19:30:00"]

# csv作成
CSV.open("#{Dir.home}/Documents/Cs2C_#{today}.csv", "w") do |header|
  header << ["件名","開始日","開始時刻","終了日","終了時刻","終日イベント","アラーム オン/オフ","アラーム日付","アラーム時刻","内容"]
end

print "Cs2C ～CLASSのスケジュールをCSVにするやつ～ \n\n"

options = Selenium::WebDriver::Firefox::Options.new(args: ['-headless'])
driver = Selenium::WebDriver.for(:firefox , options: options)

driver.get "https://class.admin.tus.ac.jp/up/faces/login/Com00501A.jsp"

print "CLASSのログインに使う情報が必要です ※入力された情報は処理終了後に破棄されます\n"

begin
  print "\n学籍番号を入力してください [Enter]で決定: "
  id = gets.chomp
  print "\nパスワードを入力してください [Enter]で決定: "
  pw = gets.chomp
  driver.find_element(:name, 'form1:htmlUserId'  ).send_key id
  driver.find_element(:name, 'form1:htmlPassword').send_key pw
  driver.find_element(:name, 'form1:login'       ).click
  sleep 3

# ログインできなかった場合例外が出るようにしてやり直させる処理
  check = driver.find_element(:id, 'form1:Poa00101A:htmlDate_month')
rescue
  driver.find_element(:name, 'form1:htmlUserId'  ).clear
  driver.find_element(:name, 'form1:htmlPassword').clear
  print "\nログインできませんでした.再度入力してください\n"
  retry
end

if driver.find_element(:id, "form1:Poa00201A:htmlParentTable:3:htmlHeaderTbl:0:htmlHeaderCol").text == "休講"
  5.times do |i|
    begin
      kyuko = driver.find_element(:id, "form1:Poa00201A:htmlParentTable:3:htmlDetailTbl:#{i}:htmlTitleCol1").text.split(/　/)
    rescue
      break
    end
    p kyuko
  end
else
  print "休講情報はありません"
end


countD = today

until countD == nMonthEndDay + 1 || countD == nMonthEndDay + 2
  print "\n#{countD.month}月#{countD.day}日とその翌日の時間割を取得\n"
  plainT = driver.find_element(:xpath, "/html/body/div/div/form[3]/table[2]/tbody/tr/td[2]/table/tbody/tr[3]/td/div/div/table/tbody/tr[2]/td/table/tbody/tr[2]/td/table/tbody").text
  t = plainT.tr('０-９ａ-ｚＡ-Ｚ．（）　－','0-9a-zA-Z.() -').split("\n\n")
  finalOutputs = Array.new(2)

  2.times do |i|
    timetable  = t[i].split(/\(.\)\n|神楽坂\(昼間\)\n|葛飾\(昼間\)\n|野田\n|長万部\n|諏訪\n/)
    numOfClasses = timetable.length-1
    theday = Date.strptime(timetable[0],"%m月%d日")
    thedayYmd = theday.strftime("%Y/%m/%d")
    outputArr = Array.new

    numOfClasses.times do |j|

      classes = Array.new(10)
      jugyo = timetable[j+1].split(/\n/)

      case jugyo[0]
      when "1限目"
        classes[2], classes[4], classes[8] = _1gen
      when "2限目"
        classes[2], classes[4], classes[8] = _2gen
      when "3限目"
        classes[2], classes[4], classes[8] = _3gen
      when "4限目"
        classes[2], classes[4], classes[8] = _4gen
      when "5限目"
        classes[2], classes[4], classes[8] = _5gen
      when "6限目"
        classes[2], classes[4], classes[8] = _6gen
      when "7限目"
        classes[2], classes[4], classes[8] = _7gen
      else
        jugyo[1] = "授業なし"
      end

      classes[0] = jugyo[1]
      classes[1], classes[3], classes[7] = thedayYmd, thedayYmd, thedayYmd
      
      if classes[0].include?("授業なし")
        classes[2] = "00:00:00"
        classes[5] = "true"
        classes[6] = "false"
      else
        classes[5] = "false"
        classes[6] = "true"
        classes[9] = jugyo[2]
      end
      outputArr[j] = classes

      finalOutputs[i] = outputArr
    end
  end
    
  CSV.open("#{Dir.home}/Documents/Cs2C_#{today}.csv", "a") do |csv|
    finalOutputs.each do |days|
      days.each do |classes|
        csv << classes
      end
    end
  end

  countD += 2

  if countD == nMonthFirstDay || countD == nMonthFirstDay + 1
    driver.find_element(:id, 'form1:Poa00101A:nextMonth').click
    sleep 3
  end
  
  driver.find_element(link_text: "#{countD.day}").click
  sleep 3
end

driver.quit

print "時間割は #{Dir.home}/Documents/Cs2C_#{today}.csv に保存されました\n\n"
print "Googleカレンダーにインポートするページを開きますか？(Google アカウントが必要です) y/n [Enter]で決定\n"
importYN = gets.chomp

if importYN == "y"
  driver = Selenium::WebDriver.for :firefox
  driver.get "https://accounts.google.com/signin/v2/identifier?service=cl&passive=1209600&osid=1&continue=https%3A%2F%2Fcalendar.google.com%2Fcalendar%2Fr%2Fsettings%2Fexport%3Fhl%3Dja%26pli%3D1%26t%3DAKUaPmYIRBe3_yaaGlejZty0zA2lbUaPkI_6HELntaaPTRigqhwXXeokgrIYjbVOINuuYdVw_riL9vtUI_U1cgxMSlXPG5u9IA%253D%253D&followup=https%3A%2F%2Fcalendar.google.com%2Fcalendar%2Fr%2Fsettings%2Fexport%3Fhl%3Dja%26pli%3D1%26t%3DAKUaPmYIRBe3_yaaGlejZty0zA2lbUaPkI_6HELntaaPTRigqhwXXeokgrIYjbVOINuuYdVw_riL9vtUI_U1cgxMSlXPG5u9IA%253D%253D&hl=ja&scc=1&flowName=GlifWebSignIn&flowEntry=ServiceLogin"
else
  print "プログラムを終了します\n"
  sleep 2
  exit
end
