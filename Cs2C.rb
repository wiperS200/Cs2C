require 'selenium-webdriver'
require 'csv'
require 'date'

# Selenium::WebDriver::Firefox.driver_path = "geckodriver/geckodriver.exe" neriでコンパイルの時にコメントアウトを取る

d = Date.today
p d.month

# csv作成
CSV.open("#{Dir.home}/Documents/Cs2C_#{d}.csv", "w") do |header|
  header << ["件名","開始日","開始時刻","終了日","終了時刻","終日イベント","アラーム オン/オフ","アラーム日付","アラーム時刻","場所","内容"]
end

print "Cs2C ～CLASSのスケジュールをCSVにするやつ～ \n\n"
# driver = Selenium::WebDriver.for :firefox# , options: options) (つけよ

class Scrape
  # CLASSにログイン
  def importIdPw
    print "CLASSのログインに使う情報が必要です ※入力された情報は処理終了後に破棄されます\n"
    print "\n学籍番号を入力してください [Enter]で決定: "
    @id = gets.chomp
    print "\nパスワードを入力してください [Enter]で決定: "
    @pw = gets.chomp
  end
  
  def open
    # Selenium::WebDriver::Firefox.driver_path = "geckodriver/geckodriver.exe" neriでコンパイルの時にコメントアウトを取る
    options = Selenium::WebDriver::Firefox::Options.new(args: ['-headless'])
    @driver = Selenium::WebDriver.for(:firefox , options: options)
    @driver.get "https://class.admin.tus.ac.jp/up/faces/login/Com00501A.jsp"
    @driver.find_element(:name, 'form1:htmlUserId'  ).send_key @id
    @driver.find_element(:name, 'form1:htmlPassword').send_key @pw
    @driver.find_element(:name, 'form1:login'       ).click
    sleep 3
  end

  def checkMD
    m = @driver.find_element(:id, 'form1:Poa00101A:htmlDate_month').text.to_i
    p m
  end
  # 時間割を取得して二日分CSVに出力 今日から来月末までループ

  def getTimetable(day)
    @driver.find_element(link_text: "#{day}").click
    @plain = @driver.find_element(:xpath, "/html/body/div/div/form[3]/table[2]/tbody/tr/td[2]/table/tbody/tr[3]/td/div/div/table/tbody/tr[2]/td/table/tbody/tr[2]/td/table/tbody").text
  end

  def splitTimetable
    require 'date'
    t = @plain.tr('０-９ａ-ｚＡ-Ｚ．（）　－','0-9a-zA-Z.() -').split("\n\n")
    p t

    thedayT  = t[0].split(/\(.\)\n|神楽坂\(昼間\)\n|葛飾\(昼間\)\n|野田\n|長万部\n|諏訪\n/)
    thedayTJ = thedayT[1].split(/\n/)
    theday = thedayT[0].strptime("%m月%d日")
    nextdayT = t[1].split(/\(.\)\n|神楽坂\(昼間\)\n|葛飾\(昼間\)\n|野田\n|長万部\n|諏訪\n/)

  end
 
  def exportToCSV
    CSV.open("#{Dir.home}/Documents/Cs2C_#{d}.csv", "a") do

    end
  end

end

doing = Scrape.new
doing.importIdPw
doing.open
doing.getTimetable(12)
doing.splitTimetable
#  p thedayT
#  p thedayTJ.length
#  p theday.strftime("%Y/%m/%d")

# until m == d.month do 
#   driver.find_element(:id, "from1:Poa00101A:nextmonth").click
# end
