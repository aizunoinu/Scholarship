#奨学金の月返済金額を算出するプログラムです。

require "rubygems"
require "spreadsheet"
require "date"

#奨学金クラス
class Scholarship
    #コンストラクタ
    def initialize(sogaku, riritsu, endYear)
        @hensaiSogaku = sogaku
        @nenri = riritsu
        @taiyoEndYear = endYear
    end

    #奨学金の返済シミュレーションに使用する変数を算出するメソッド
    def calcurateItems
        #月利を算出する。
        @getsuri = @nenri / 100 / 12

        #返済開始日付を算出する。
        @hensaiKaishiDate = Date.new(@taiyoEndYear, 10, 27)

        #奨学金の返済年数と返済回数を求める
        @hensaiNensu = self.getHensaiNensu.to_i
        @hensaiKaisu = @hensaiNensu * 12

        #奨学金の据置利息（卒業してから奨学金の返済が開始するまでにかかる利息）を求める
        @totalSueokiRisoku = (self.getTotalSueokiRisoku + 1).to_i
        @tukiSueokiRisoku = (@totalSueokiRisoku / @hensaiKaisu).to_i
        @amariSueokiRisoku = (@totalSueokiRisoku - (@tukiSueokiRisoku * @hensaiKaisu)).to_i

        #奨学金の月返済額（据置利息以外）を求める
        @wTukiHensaigaku = self.getTukiHensaigaku
        @tukiHensaigaku = @wTukiHensaigaku.to_i
        #月返済額の小数点以下を取り出す
        @amariTukiHensaigaku = @wTukiHensaigaku - @tukiHensaigaku
        @amariTukiHensaigaku = @amariTukiHensaigaku * 240

        #奨学金の計算に使用できなかった小数点以下を合計する
        @amariGoukeigaku = (@amariTukiHensaigaku + @amariSueokiRisoku + 1).to_i

        #月に返済する金額を求める
        @hensaigaku = @tukiHensaigaku + @tukiSueokiRisoku

        #毎月奨学金を返済していった場合最終的に支払う奨学金の総額を算出する。
        @hensaiSogaku2 = @hensaigaku * 240 + @amariGoukeigaku
    end

    #奨学金の返済年数を求めるメソッド
    def getHensaiNensu
        if @hensaiSogaku <= 200000 then
            @hensaiSogaku / 30000
        elsif @hensaiSogaku <= 400000 then
            @hensaiSogaku / 40000
        elsif @hensaiSogaku <= 500000 then
            @hensaiSogaku / 50000
        elsif @hensaiSogaku <= 600000 then
            @hensaiSogaku / 60000
        elsif @hensaiSogaku <= 700000 then
            @hensaiSogaku / 70000
        elsif @hensaiSogaku <= 900000 then
            @hensaiSogaku / 80000
        elsif @hensaiSogaku <= 1100000 then
            @hensaiSogaku / 90000
        elsif @hensaiSogaku <= 1300000 then
            @hensaiSogaku / 100000
        elsif @hensaiSogaku <= 1500000 then
            @hensaiSogaku / 110000
        elsif @hensaiSogaku <= 1700000 then
            @hensaiSogaku / 120000
        elsif @hensaiSogaku <= 1900000 then
            @hensaiSogaku / 130000
        elsif @hensaiSogaku <= 2100000 then
            @hensaiSogaku / 140000
        elsif @hensaiSogaku <= 2300000 then
            @hensaiSogaku / 150000
        elsif @hensaiSogaku <= 2500000 then
            @hensaiSogaku / 160000
        elsif @hensaiSogaku <= 3400000 then
            @hensaiSogaku / 170000
        elsif 3400001 <= @hensaiSogaku then
            20
        end
    end

    #奨学金の据置利息を算出するメソッド
    def getTotalSueokiRisoku
        #返済総額 * 年利（百分率） * 奨学金の貸与終了から返済開始までの日数 / 1年
        @hensaiSogaku * (@nenri / 100) * 180.0 / 365
    end

    #奨学金の月返済額（据置利息以外）を算出するメソッド
    def getTukiHensaigaku
        @hensaiSogaku * @getsuri * (1 + @getsuri) ** @hensaiKaisu / ((1 + @getsuri) ** @hensaiKaisu - 1)
    end

    #奨学金の引き落とし日を算出するメソッド
    def getHensaiKaishiDate
        #奨学金の引き落とし日が日曜日の場合は翌日を奨学金の引き落とし日とする
        if @hensaiKaishiDate.wday == 0 then
            @hensaiKaishiDate + 1
        elsif @hensaiKaishiDate.wday == 6 then #奨学金の引き落とし日がと曜日の場合は２日後を奨学金の引き落とし日とする。
            @hensaiKaishiDate + 2
        else
            @hensaiKaishiDate
        end
    end

    #奨学金の繰り上げ情報を取得するメソッド
    def getKuriageKingaku
        hensaiCount = 0
        while(1)
            if @kuriageYear == @hensaiKaishiDate.year && @kuriageMonth == @hensaiKaishiDate.month then
                if hensaiCount == 0 then
                    hensaiSogaku = hensaiSogaku - (hensaigaku - tukiSueokiRisoku - risoku)
                    hensaiCount = hensaiCount + 1
                    amariGoukeigaku = (amariGoukeigaku / 2) + 1
                    hensaiKaishiDate = hensaiKaishiDate >> 1
                elsif hensaiSogaku <= hensaigaku then
                    hensaiSogaku = 0
                    hensaiCount = hensaiCount + 1
                    hensaiKaishiDate = hensaiKaishiDate >> 1
                    break
                else
                    #返済した金額分、返済総額を減額する。
                    hensaiSogaku = hensaiSogaku - (hensaigaku - tukiSueokiRisoku - risoku)
                    hensaiCount = hensaiCount + 1
                    hensaiKaishiDate = hensaiKaishiDate >> 1
                end
            end
        end
    end

    #繰り上げ返済を実施する場合、繰り上げ情報を入力するメソッド
    def inputKuriageHensaiInfomation
        print "奨学金の繰り上げ返済を行います。\n"
        while(1)
            begin
                print "奨学金の繰り上げ返済を行う年月を入力してください(例：2016年4月)\n"
                @kuriageYear, @kuriageMonth = gets.chomp.split(/年 || 月/).map(&:to_i)
                print "奨学金の繰り上げ返済金額を入力してください(例：1000000)\n"
                @kuriageKingaku = gets.chomp.to_i
                if @kuriageYear =~ /^[0-9]+$/ || @kuriageMonth =~ /^[0-9]+$/ || @kuriageKingaku =~ /^[0-9]+$/ then
                    puts "入力された値が不正です。もう一度入力してください"
                else
                    #繰り上げ返済金額より繰り上げを実行する金額を算出する。
                    #繰り上げ情報を配列に保存する
                    @kuriageInfomation << @kuriageYear
                    @kuriageInfomation << @kuriageMonth
                    @kuriageInfomation << @kuriageKingaku
                    @kuriageInfomationArray << @kuriageInfomation
                end
            rescue Interrupt #Control + Cが入力されたときの処理
                puts
                break
            end
        end
    end

    #奨学金の返済シミュレーション結果を出力するメソッド
    def outputWrite
        #Excelファイルをインスタンス化する
        book = Spreadsheet::Workbook.new

        #新規シートを作成する
        sheet = book.create_worksheet

        #sheetに名前を設定する
        sheet.name = "奨学金返済計画表"

        #Excelファイルに返済回数、返済金額、返済金額内訳を出力する
        hensaiCount = 0
        sheet[0, 0] = "奨学金返済計画"
        sheet[1, 0] = "残り回数"
        sheet[1, 1] = "奨学金残額"
        sheet[1, 2] = "奨学金引落日"
        sheet[1, 3] = "返済金額"
        sheet[1, 4] = "返済元金"
        sheet[1, 5] = "据置利息"
        sheet[1, 6] = "利息"
        sheet[1, 7] = "端数金額"
        sheet[1, 8] = "奨学金引落後残額"
        while(1)
            #月返済額の利息を計算する。
            risoku = (@hensaiSogaku * @getsuri).to_i
            #27日が休日かどうか判定し、休日のときはよく月曜日を返済日として返す
            whensaiKaishiDate = self.getHensaiKaishiDate
            if hensaiCount == 0 then
                sheet[hensaiCount + 2, 0] = @hensaiKaisu - hensaiCount
                sheet[hensaiCount + 2, 1] = @hensaiSogaku
                sheet[hensaiCount + 2, 2] = "#{whensaiKaishiDate.year}年#{whensaiKaishiDate.month}月#{whensaiKaishiDate.day}日"
                sheet[hensaiCount + 2, 3] = (@hensaigaku + @amariGoukeigaku / 2).to_i
                sheet[hensaiCount + 2, 4] = @hensaigaku - @tukiSueokiRisoku - risoku
                sheet[hensaiCount + 2, 5] = @tukiSueokiRisoku
                sheet[hensaiCount + 2, 6] = risoku
                sheet[hensaiCount + 2, 7] = (@amariGoukeigaku / 2).to_i
                sheet[hensaiCount + 2, 8] = @hensaiSogaku - (@hensaigaku - @tukiSueokiRisoku - risoku)
                @hensaiSogaku = @hensaiSogaku - (@hensaigaku - @tukiSueokiRisoku - risoku)
                hensaiCount = hensaiCount + 1
                @amariGoukeigaku = (@amariGoukeigaku / 2).to_i + 1
                @hensaiKaishiDate = @hensaiKaishiDate >> 1
            elsif @hensaiSogaku <= @hensaigaku then
                sheet[hensaiCount + 2, 0] = @hensaiKaisu - hensaiCount
                sheet[hensaiCount + 2, 1] = @hensaiSogaku
                sheet[hensaiCount + 2, 2] = "#{whensaiKaishiDate.year}年#{whensaiKaishiDate.month}月#{whensaiKaishiDate.day}日"
                sheet[hensaiCount + 2, 3] = @hensaigaku + @amariGoukeigaku
                sheet[hensaiCount + 2, 4] = @hensaigaku - @tukiSueokiRisoku - risoku
                sheet[hensaiCount + 2, 5] = @tukiSueokiRisoku
                sheet[hensaiCount + 2, 6] = risoku
                sheet[hensaiCount + 2, 7] = @amariGoukeigaku
                sheet[hensaiCount + 2, 8] = 0
                @hensaiSogaku = 0
                hensaiCount = hensaiCount + 1
                @hensaiKaishiDate = @hensaiKaishiDate >> 1
                break
            else
                sheet[hensaiCount + 2, 0] = @hensaiKaisu - hensaiCount
                sheet[hensaiCount + 2, 1] = @hensaiSogaku
                sheet[hensaiCount + 2, 2] = "#{whensaiKaishiDate.year}年#{whensaiKaishiDate.month}月#{whensaiKaishiDate.day}日"
                sheet[hensaiCount + 2, 3] = @hensaigaku
                sheet[hensaiCount + 2, 4] = @hensaigaku - @tukiSueokiRisoku - risoku
                sheet[hensaiCount + 2, 5] = @tukiSueokiRisoku
                sheet[hensaiCount + 2, 6] = risoku
                sheet[hensaiCount + 2, 7] = 0
                sheet[hensaiCount + 2, 8] = @hensaiSogaku - (@hensaigaku - @tukiSueokiRisoku - risoku)
                #返済した金額分、返済総額を減額する。
                @hensaiSogaku = @hensaiSogaku - (@hensaigaku - @tukiSueokiRisoku - risoku)
                hensaiCount = hensaiCount + 1
                @hensaiKaishiDate = @hensaiKaishiDate >> 1
            end
        end

        #作成したbookを書き出す
        book.write("scholarnet.xls")
    end
end


#ターミナルより奨学金情報を入力
print "奨学金の返済総額を入力してください(例：3840000)\n"
hensaiSogaku = gets.chomp.to_i
print "奨学金の年利を入力してください(例：0.16)\n"
nenri = gets.chomp.to_f
print "奨学金の貸与終了年を入力してください(例：2016)\n"
taiyoEndYear = gets.chomp.to_i

#Scholarshipクラスをインスタンス化する
scholarship = Scholarship.new(hensaiSogaku, nenri, taiyoEndYear)

puts "*****************************************************"
print "奨学金の繰り上げ返済を希望しますか？(Yes / No)： "
sel = gets.chomp
puts "*****************************************************"
if sel == "Yes" then
    scholarship.inputKuriageHensaiInfomation
end

scholarship.calcurateItems
scholarship.outputWrite
