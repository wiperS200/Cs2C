require 'selenium-webdriver'
require 'csv'
require 'date'

# Selenium::WebDriver::Firefox.driver_path = "geckodriver/geckodriver.exe" neriでコンパイルの時にコメントアウトを取る

d = Date.today
p d.month
endDay = Date.new(d.year, d.month+1, -1)

# csv作成
CSV.open("#{Dir.home}/Documents/Cs2C_#{d}.csv", "w") do |header|
  header << ["件名","開始日","開始時刻","終了日","終了時刻","終日イベント","アラーム オン/オフ","アラーム日付","アラーム時刻","場所","内容"]
end

print "Cs2C ～CLASSのスケジュールをCSVにするやつ～ \n\n"

print "CLASSのログインに使う情報が必要です ※入力された情報は処理終了後に破棄されます\n"

options = Selenium::WebDriver::Firefox::Options.new(args: ['-headless'])
driver = Selenium::WebDriver.for(:firefox , options: options)

driver.get "https://class.admin.tus.ac.jp/up/faces/login/Com00501A.jsp"

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
  driver.find_element(:id, 'form1:Poa00101A:htmlDate_month').enabled?
rescue
  driver.find_element(:name, 'form1:htmlUserId'  ).clear
  driver.find_element(:name, 'form1:htmlPassword').clear
  print "\nログインできませんでした.再度入力してください\n"
  retry
end

m = driver.find_element(:id, 'form1:Poa00101A:htmlDate_month').text.to_i
p m

until d == endDay
  
  plain = driver.find_element(:xpath, "/html/body/div/div/form[3]/table[2]/tbody/tr/td[2]/table/tbody/tr[3]/td/div/div/table/tbody/tr[2]/td/table/tbody/tr[2]/td/table/tbody").text

  t = plain.tr('０-９ａ-ｚＡ-Ｚ．（）　－','0-9a-zA-Z.() -').split("\n\n")
  p t

  thedayT  = t[0].split(/\(.\)\n|神楽坂\(昼間\)\n|葛飾\(昼間\)\n|野田\n|長万部\n|諏訪\n/)
  thedayTJ = thedayT[1].split(/\n/)
  theday = Date.strptime(thedayT[0],"%m月%d日")
  nextdayT = t[1].split(/\(.\)\n|神楽坂\(昼間\)\n|葛飾\(昼間\)\n|野田\n|長万部\n|諏訪\n/)

p thedayT
p thedayTJ.length
p thedayTJ
p theday.strftime("%Y/%m/%d")


#  CSV.open("#{Dir.home}/Documents/Cs2C_#{d}.csv", "a") do
#  end

  d = d+2
  driver.find_element(link_text: "#{d.day}").click
  sleep 3
end
driver.quit

print "時間割は #{Dir.home}/Documents/Cs2C_#{d}.csv に保存されました\n\n"
print "Google カレンダーにインポートするページを開きますか？ y/n [Enter]で決定\n"
importYN = gets.chomp

if importYN == "y" 
  driver = Selenium::WebDriver.for firefox 
  driver.get "https://accounts.google.com/signin/v2/identifier?service=cl&passive=1209600&osid=1&continue=https%3A%2F%2Fcalendar.google.com%2Fcalendar%2Fr%2Fsettings%2Fexport%3Fhl%3Dja%26pli%3D1%26t%3DAKUaPmYIRBe3_yaaGlejZty0zA2lbUaPkI_6HELntaaPTRigqhwXXeokgrIYjbVOINuuYdVw_riL9vtUI_U1cgxMSlXPG5u9IA%253D%253D&followup=https%3A%2F%2Fcalendar.google.com%2Fcalendar%2Fr%2Fsettings%2Fexport%3Fhl%3Dja%26pli%3D1%26t%3DAKUaPmYIRBe3_yaaGlejZty0zA2lbUaPkI_6HELntaaPTRigqhwXXeokgrIYjbVOINuuYdVw_riL9vtUI_U1cgxMSlXPG5u9IA%253D%253D&hl=ja&scc=1&flowName=GlifWebSignIn&flowEntry=ServiceLogin"
else
  exit
end
