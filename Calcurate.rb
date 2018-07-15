#奨学金の月返済金額を算出するプログラムです。

require "rubygems"
require "spreadsheet"
require "date"

#奨学金の返済年数を求めるメソッド
def getHensaiNensu(hensaiSogaku)
    if hensaiSogaku <= 200000 then
        hensaiSogaku / 30000
    elsif hensaiSogaku <= 400000 then
        hensaiSogaku / 40000
    elsif hensaiSogaku <= 500000 then
        hensaiSogaku / 50000
    elsif hensaiSogaku <= 600000 then
        hensaiSogaku / 60000
    elsif hensaiSogaku <= 700000 then
        hensaiSogaku / 70000
    elsif hensaiSogaku <= 900000 then
        hensaiSogaku / 80000
    elsif hensaiSogaku <= 1100000 then
        hensaiSogaku / 90000
    elsif hensaiSogaku <= 1300000 then
        hensaiSogaku / 100000
    elsif hensaiSogaku <= 1500000 then
        hensaiSogaku / 110000
    elsif hensaiSogaku <= 1700000 then
        hensaiSogaku / 120000
    elsif hensaiSogaku <= 1900000 then
        hensaiSogaku / 130000
    elsif hensaiSogaku <= 2100000 then
        hensaiSogaku / 140000
    elsif hensaiSogaku <= 2300000 then
        hensaiSogaku / 150000
    elsif hensaiSogaku <= 2500000 then
        hensaiSogaku / 160000
    elsif hensaiSogaku <= 3400000 then
        hensaiSogaku / 170000
    elsif 3400001 <= hensaiSogaku then
        20
    end
end

#奨学金の据置利息を算出するメソッド
def getTotalSueokiRisoku(hensaiSogaku, nenri)
    #返済総額 * 年利（百分率） * 奨学金の貸与終了から返済開始までの日数 / 1年
    hensaiSogaku * (nenri / 100) * 180.0 / 365
end

#奨学金の月返済額（据置利息以外）を算出するメソッド
def getTukiHensaigaku(hensaiSogaku, getsuri, hensaiKaisu)
    hensaiSogaku * getsuri * (1 + getsuri) ** hensaiKaisu / ((1 + getsuri) ** hensaiKaisu - 1)
end

#奨学金の引き落とし日を算出するメソッド
def getHensaiDate(hensaiDate)
    #奨学金の引き落とし日が日曜日の場合は翌日を奨学金の引き落とし日とする
    if hensaiDate.wday == 0 then
        hensaiDate + 1
    elsif hensaiDate.wday == 6 then #奨学金の引き落とし日がと曜日の場合は２日後を奨学金の引き落とし日とする。
        hensaiDate + 2
    else
        hensaiDate
    end
end

#Excelファイルをインスタンス化する
book = Spreadsheet::Workbook.new

#新規シートを作成する
sheet = book.create_worksheet

#sheetに名前を設定する
sheet.name = "奨学金返済計画表"

#ターミナルより返済総額と年利を入力させる
print "奨学金の返済総額、年利、貸与終了年を入力してください(例：1200000 0.16 2016)\n"
hensaiSogaku, nenri, taiyoEndYear = gets.chomp.split(" ").map(&:to_f)
hensaiSogaku = hensaiSogaku.to_i
taiyoEndYear = taiyoEndYear.to_i

#月利を算出する。
getsuri = nenri / 100 / 12

#返済開始日付を算出する。
hensaiDate = Date.new(taiyoEndYear, 10, 27)

#奨学金の返済年数と返済回数を求める
hensaiNensu = (getHensaiNensu(hensaiSogaku)).to_i
hensaiKaisu = hensaiNensu * 12

#puts "奨学金の返済年数は #{hensaiNensu}年です"
#puts "奨学金の返済回数は #{hensaiKaisu}回です"

#奨学金の据置利息（卒業してから奨学金の返済が開始するまでにかかる利息）を求める
totalSueokiRisoku = (getTotalSueokiRisoku(hensaiSogaku, nenri) + 1).to_i
tukiSueokiRisoku = (totalSueokiRisoku / hensaiKaisu).to_i
amariSueokiRisoku = (totalSueokiRisoku - (tukiSueokiRisoku * hensaiKaisu)).to_i

#hensaiSogaku = hensaiSogaku + totalSueokiRisoku

#奨学金の月返済額（据置利息以外）を求める
wTukiHensaigaku = getTukiHensaigaku(hensaiSogaku, getsuri, hensaiKaisu)
tukiHensaigaku = wTukiHensaigaku.to_i
#月返済額の小数点以下を取り出す
amariTukiHensaigaku = wTukiHensaigaku - tukiHensaigaku
amariTukiHensaigaku = amariTukiHensaigaku * 240

#奨学金の計算に使用できなかった小数点以下を合計する
amariGoukeigaku = (amariTukiHensaigaku + amariSueokiRisoku + 1).to_i

#月に返済する金額を求める
hensaigaku = tukiHensaigaku + tukiSueokiRisoku

#利息を考慮した奨学金の返済総額を算出
hensaiSogaku2 = hensaigaku * 240 + amariGoukeigaku

#puts "奨学金の据置利息は #{tukiSueokiRisoku}円です。"
#puts "奨学金の据置利息のあまりは #{amariSueokiRisoku}円です"
#puts "奨学金の月返済額は #{tukiHensaigaku}円です"
#puts "奨学金の返済で計算不可だった余り金額は #{amariGoukeigaku}円です"

#Excelファイルに返済回数、返済金額、返済金額内訳を出力する
hensaiCount = 0
sheet[0, 0] = "奨学金返済計画"
sheet[1, 0] = "残り回数"
sheet[1, 1] = "奨学金引落日"
sheet[1, 2] = "奨学金残額"
sheet[1, 3] = "返済金額"
sheet[1, 4] = "返済元金"
sheet[1, 5] = "据置利息"
sheet[1, 6] = "利息"
while(1)
    risoku = (hensaiSogaku * getsuri).to_i
    wHensaiDate = getHensaiDate(hensaiDate)
    #奨学金の返済総額が月返済額を下回る（最後の一回）のとき
    if hensaiSogaku <= 0 then
        sheet[hensaiCount + 2, 0] = hensaiKaisu - hensaiCount
        sheet[hensaiCount + 2, 1] = "#{wHensaiDate.year}年#{wHensaiDate.month}月#{wHensaiDate.day}日"
        sheet[hensaiCount + 2, 2] = 0
        sheet[hensaiCount + 2, 3] = 0
        sheet[hensaiCount + 2, 4] = 0
        sheet[hensaiCount + 2, 5] = 0
        sheet[hensaiCount + 2, 6] = 0
        break
    elsif hensaiCount == 0 then
        sheet[hensaiCount + 2, 0] = hensaiKaisu - hensaiCount
        sheet[hensaiCount + 2, 1] = "#{wHensaiDate.year}年#{wHensaiDate.month}月#{wHensaiDate.day}日"
        sheet[hensaiCount + 2, 2] = hensaiSogaku
        sheet[hensaiCount + 2, 3] = (hensaigaku + amariGoukeigaku / 2).to_i
        sheet[hensaiCount + 2, 4] = hensaigaku - tukiSueokiRisoku - risoku
        sheet[hensaiCount + 2, 5] = tukiSueokiRisoku
        sheet[hensaiCount + 2, 6] = risoku
        hensaiSogaku = hensaiSogaku - (hensaigaku - tukiSueokiRisoku - risoku)
        hensaiCount = hensaiCount + 1
        amariGoukeigaku = (amariGoukeigaku / 2) + 1
        hensaiDate = hensaiDate >> 1
    elsif hensaiSogaku <= hensaigaku then
        sheet[hensaiCount + 2, 0] = hensaiKaisu - hensaiCount
        sheet[hensaiCount + 2, 1] = "#{wHensaiDate.year}年#{wHensaiDate.month}月#{wHensaiDate.day}日"
        sheet[hensaiCount + 2, 2] = hensaiSogaku
        sheet[hensaiCount + 2, 3] = hensaigaku + amariGoukeigaku
        sheet[hensaiCount + 2, 4] = hensaigaku - tukiSueokiRisoku - risoku
        sheet[hensaiCount + 2, 5] = tukiSueokiRisoku
        sheet[hensaiCount + 2, 6] = risoku
        hensaiSogaku = 0
        hensaiCount = hensaiCount + 1
        hensaiDate = hensaiDate >> 1
    else
        sheet[hensaiCount + 2, 0] = hensaiKaisu - hensaiCount
        sheet[hensaiCount + 2, 1] = "#{wHensaiDate.year}年#{wHensaiDate.month}月#{wHensaiDate.day}日"
        sheet[hensaiCount + 2, 2] = hensaiSogaku
        sheet[hensaiCount + 2, 3] = hensaigaku
        sheet[hensaiCount + 2, 4] = hensaigaku - tukiSueokiRisoku - risoku
        sheet[hensaiCount + 2, 5] = tukiSueokiRisoku
        sheet[hensaiCount + 2, 6] = risoku
        #返済した金額分、返済総額を減額する。
        hensaiSogaku = hensaiSogaku - (hensaigaku - tukiSueokiRisoku - risoku)
        hensaiCount = hensaiCount + 1
        hensaiDate = hensaiDate >> 1
    end
end

#作成したbookを書き出す
book.write("scholarnet.xls")

