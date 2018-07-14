#奨学金の月返済金額を算出するプログラムです。

require "rubygems"
require "spreadsheet"

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

#Excelファイルをインスタンス化する
book = Spreadsheet::WorkBook.new

#新規シートを作成する
sheet = book.crate_worksheet

#sheetに名前を設定する
sheet.name = "奨学金返済計画表"

#ターミナルより返済総額と年利を入力させる
print "奨学金の返済総額と年利を入力してください(例：1200000 0.16)\n"
hensaiSogaku, nenri = gets.chomp.split(" ").map(&:to_i)
nenri = nenri.to_f
getsuri = nenri / 100 / 12

#奨学金の返済年数と返済回数を求める
hensaiNensu = getHensaiNensu(hensaiSogaku)
hensaiKaisu = hensaiNensu * 12

puts "奨学金の返済年数は #{hensaiNensu}年です"
puts "奨学金の返済回数は #{hensaiKaisu}回です"

#奨学金の据置利息（卒業してから奨学金の返済が開始するまでにかかる利息）を求める
totalSueokiRisoku = getTotalSueokiRisoku(hensaiSogaku, nenri)
sueokiRisoku = (totalSueokiRisoku / hensaiKaisu).to_i
amariSueokiRisoku = (totalSueokiRisoku - (sueokiRisoku * hensaiKaisu)).to_i

#奨学金の月返済額（据置利息以外）を求める
wTukiHensaigaku = getTukiHensaigaku(hensaiSogaku, getsuri, hensaiKaisu)
tukiHensaigaku = wTukiHensaigaku.to_i
amariTukiHensaigaku = wTukiHensaigaku - tukiHensaigaku
amariTukiHensaigaku = amariTukiHensaigaku * 240

amariGoukeigaku = (amariTukiHensaigaku + amariSueokiRisoku + 1).to_i

puts "奨学金の据置利息は #{sueokiRisoku}円です。"
puts "奨学金の据置利息のあまりは #{amariSueokiRisoku}円です"
puts "奨学金の月返済額は #{tukiHensaigaku}円です"
puts "奨学金の返済で計算不可だった余り金額は #{amariGoukeigaku}円です"

#作成したbookを書き出す
book.write("scholarnet.xls")

