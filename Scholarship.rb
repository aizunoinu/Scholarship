#奨学金の返済をシミュレーションするプログラムです。

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
        @hensaiDate = Date.new(@taiyoEndYear, 10, 27)

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
        #返済総額 * 月利 * (1 + 月利) ^ 返済回数 / ((1 + 月利) ^ 返済回数 - 1)
        @hensaiSogaku * @getsuri * (1 + @getsuri) ** @hensaiKaisu / ((1 + @getsuri) ** @hensaiKaisu - 1)
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

    #奨学金の繰り上げ情報を取得するメソッド
    def getKuriageKingaku(kuriageYearMonth, kuriageKingaku)
        #入力された金額以下の繰り上げ金額を算出する。
        kuriageHensaiSimulationInfomationArray = []

        #繰り上げ返済希望日に一致するまでの配列の情報をコピーする。
        for i in 0..@hensaiSimulationInfomationArray.size - 1
            hensaiSimulationInfomation = @hensaiSimulationInfomationArray[i]
            #puts "#{hensaiSimulationInfomation[2]} と #{kuriageYearMonth}"
            kuriageHensaiSimulationInfomationArray << hensaiSimulationInfomation
            #繰り上げ返済希望日を含む日付になった時、配列のコピーを終了する。
            if hensaiSimulationInfomation[2] =~ /#{kuriageYearMonth}/ then
                break
            end
        end

        #繰り上げ返済シュミレーション結果と通常返済シミュレーション結果が同じ時、奨学金の繰り上げ返済が行われなかった。
        if kuriageHensaiSimulationInfomationArray.size == @hensaiSimulationInfomationArray.size then
        else
            wKuriageKingaku = 0
            wKuriageKaisu = 0
            kuriageStart = i
            #1回分のみ利息を計算して支払う必要がある
            hensaiSimulationInfomation = @hensaiSimulationInfomationArray[i]
            risoku = (hensaiSimulationInfomation[1] * @getsuri).to_i
            #繰り上げ金額から１回分の利息を減算する。
            kuriageKingaku = kuriageKingaku - risoku
            #繰り上げ返済予定金額に加算する。
            wKuriageKingaku = wKuriageKingaku + risoku

            #繰り上げ金額残りで返済できる金額を算出する
            for i in kuriageStart..@hensaiSimulationInfomationArray.size - 1
                hensaiSimulationInfomation = @hensaiSimulationInfomationArray[i]
                #繰り上げ金額が、元金と据置利息の和より小さくなった時、それ以上繰り上げ返済ができなくなったことを意味する
                if kuriageKingaku < hensaiSimulationInfomation[4] + hensaiSimulationInfomation[5]
                    break
                end
                kuriageKingaku = kuriageKingaku - hensaiSimulationInfomation[4] - hensaiSimulationInfomation[5]
                wKuriageKingaku = wKuriageKingaku + hensaiSimulationInfomation[4] + hensaiSimulationInfomation[5]
                wKuriageKaisu = wKuriageKaisu + 1
            end
        end

        #奨学金の繰り上げ返済を消化した後の返済シミュレーション結果を作成する。
        start = i
        for i in start..@hensaiSimulationInfomationArray.size - 1
            hensaiSimulationInfomation = @hensaiSimulationInfomationArray[i]
            kuriageHensaiSimulationInfomationArray << hensaiSimulationInfomation
        end
        #奨学金の繰り上げ返済シミュレーション結果をリターンする。
        return wKuriageKingaku, wKuriageKaisu, kuriageHensaiSimulationInfomationArray
    end

    #繰り上げ返済を実施する場合、繰り上げ情報を入力するメソッド
    def inputKuriageHensaiInfomation
        print "奨学金の繰り上げ返済を行います。\n"

        @kuriageInfomationArray = []
        while(1)
            begin
                print "奨学金の繰り上げ返済を行う年月を入力してください(例：2016年4月)\n"
                kuriageYearMonth = gets.chomp
                kuriageYear, kuriageMonth = kuriageYearMonth.split("年|月").map(&:to_i)
                print "奨学金の繰り上げ返済金額を入力してください(例：1000000)\n"
                kuriageKingaku = gets.chomp.to_i

                #入力された数値が不正な場合はエラーとする
                if kuriageYear =~ /^[0-9]+$/ || kuriageMonth =~ /^[0-9]+$/ || kuriageKingaku =~ /^[0-9]+$/ then
                    puts "入力された値が不正です。もう一度入力してください"
                elsif kuriageKingaku < @hensaigaku * 2 then
                    puts "繰り上げ返済額が2ヶ月分の月返済額より大きくなければなりません。"
                    puts "もう一度入力してください"
                else
                    #入力された日付が既に繰り上げ返済のシミュレーションを実行する前だった場合エラーとする
                    errorFLG = 0
                    for i in 0..@kuriageInfomationArray.size - 1
                        kuriageInfomation = @kuriageInfomationArray[i]
                        if kuriageYearMonth <= kuriageInfomation[0]
                            errorFLG = 1
                            break
                        end
                    end

                    if errorFLG == 1 then
                        puts "繰り上げ返済のシミュレーションを実行できない日付が入力されました。"
                        puts "シミュレーションを実行した日付より後の日付を入力してください。"
                    else
                        #繰り上げ返済金額より繰り上げを実行する金額を算出する。
                        kuriageHensaiKingaku, kuriageHensaiKaisu, kuriageHensaiSimulationInfomationArray
                                            = self.getKuriageKingaku(kuriageYearMonth, kuriageKingaku)
                        print "奨学金の繰り上げ金額は #{kuriageHensaiKingaku}円です\n"
                        print "奨学金の繰り上げ回数は #{kuriageHensaiKaisu}回です\n"
                        while(1)
                            print "よろしければ\"Yes\"、訂正する場合は\"No\"を入力してください： "
                            sel = gets.chomp.to_s
                            if sel == "Yes" then
                                #繰り上げ情報を配列に保存する
                                kuriageInfomation = []
                                kuriageInfomation << kuriageYearMonth
                                kuriageInfomation << kuriageKingaku
                                @kuriageInfomationArray << kuriageInfomation
                                @hensaiSimulationInfomationArray = kuriageHensaiSimulationInfomationArray
                            elsif sel == "No" then
                                print "Noが入力されたので、入力を取り消します。\n"
                            else
                                print "入力できる文字列は\"Yes\"と\"No\"のみです。\n"
                            end

                            #入力された文字列がYesかNoのときは次の入力へ移動する。
                            if sel == "Yes" || sel == "No" then
                                break
                            end
                        end
                    end
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

        #配列の中身をファイルに出力する
        for i in 0..@hensaiSimulationInfomationArray.size - 1
            #インスタンス変数hensaiSimulationInfomationArrayから返済情報を一つ取り出す
            hensaiSimulationInfomation = @hensaiSimulationInfomationArray[i]
            sheet[i + 2, 0] = hensaiSimulationInfomation[0]
            sheet[i + 2, 1] = hensaiSimulationInfomation[1]
            sheet[i + 2, 2] = hensaiSimulationInfomation[2]
            sheet[i + 2, 3] = hensaiSimulationInfomation[3]
            sheet[i + 2, 4] = hensaiSimulationInfomation[4]
            sheet[i + 2, 5] = hensaiSimulationInfomation[5]
            sheet[i + 2, 6] = hensaiSimulationInfomation[6]
            sheet[i + 2, 7] = hensaiSimulationInfomation[7]
            sheet[i + 2, 8] = hensaiSimulationInfomation[8]
        end

        #作成したbookを書き出す
        book.write("Scholarship.xls")
    end

    #奨学金の通常返済シミュレーション結果を作成するメソッド
    def hensaiSimulation
        #Excelファイルに返済回数、返済金額、返済金額内訳を出力する
        hensaiCount = 0
        #インスタンス変数からローカル変数に値をコピーする
        hensaiKaisu = @hensaiKaisu
        hensaiSogaku = @hensaiSogaku
        amariGoukeigaku = @amariGoukeigaku
        hensaiDate = @hensaiDate

        @hensaiSimulationInfomationArray = []
        #シミュレーション結果を作成する
        while(1)
            #月返済額の利息を計算する。
            risoku = (hensaiSogaku * @getsuri).to_i
            #27日が休日かどうか判定し、休日のときはよく月曜日を返済日として返す
            whensaiDate = self.getHensaiDate(hensaiDate)
            hensaiSimulationInfomation = []
            if hensaiCount == 0 then
                hensaiSimulationInfomation << hensaiKaisu - hensaiCount
                hensaiSimulationInfomation << hensaiSogaku
                hensaiSimulationInfomation << "#{whensaiDate.year}年#{whensaiDate.month}月#{whensaiDate.day}日"
                hensaiSimulationInfomation << (@hensaigaku + amariGoukeigaku / 2).to_i
                hensaiSimulationInfomation << @hensaigaku - @tukiSueokiRisoku - risoku
                hensaiSimulationInfomation << @tukiSueokiRisoku
                hensaiSimulationInfomation << risoku
                hensaiSimulationInfomation << (amariGoukeigaku / 2).to_i
                hensaiSimulationInfomation << hensaiSogaku - (@hensaigaku - @tukiSueokiRisoku - risoku)
                @hensaiSimulationInfomationArray << hensaiSimulationInfomation
                hensaiSogaku = hensaiSogaku - (@hensaigaku - @tukiSueokiRisoku - risoku)
                hensaiCount = hensaiCount + 1
                amariGoukeigaku = (amariGoukeigaku / 2).to_i + 1
                hensaiDate = hensaiDate >> 1
            elsif hensaiSogaku <= @hensaigaku then
                hensaiSimulationInfomation << hensaiKaisu - hensaiCount
                hensaiSimulationInfomation << hensaiSogaku
                hensaiSimulationInfomation << "#{whensaiDate.year}年#{whensaiDate.month}月#{whensaiDate.day}日"
                hensaiSimulationInfomation << @hensaigaku + amariGoukeigaku
                hensaiSimulationInfomation << @hensaigaku - @tukiSueokiRisoku - risoku
                hensaiSimulationInfomation << @tukiSueokiRisoku
                hensaiSimulationInfomation << risoku
                hensaiSimulationInfomation << amariGoukeigaku
                hensaiSimulationInfomation << 0
                @hensaiSimulationInfomationArray << hensaiSimulationInfomation
                hensaiSogaku = 0
                hensaiCount = hensaiCount + 1
                hensaiDate = hensaiDate >> 1
                break
            else
                hensaiSimulationInfomation << hensaiKaisu - hensaiCount
                hensaiSimulationInfomation << hensaiSogaku
                hensaiSimulationInfomation << "#{whensaiDate.year}年#{whensaiDate.month}月#{whensaiDate.day}日"
                hensaiSimulationInfomation << @hensaigaku
                hensaiSimulationInfomation << @hensaigaku - @tukiSueokiRisoku - risoku
                hensaiSimulationInfomation << @tukiSueokiRisoku
                hensaiSimulationInfomation << risoku
                hensaiSimulationInfomation << 0
                hensaiSimulationInfomation << hensaiSogaku - (@hensaigaku - @tukiSueokiRisoku - risoku)
                @hensaiSimulationInfomationArray << hensaiSimulationInfomation
                #返済した金額分、返済総額を減額する。
                hensaiSogaku = hensaiSogaku - (@hensaigaku - @tukiSueokiRisoku - risoku)
                hensaiCount = hensaiCount + 1
                hensaiDate = hensaiDate >> 1
            end
        end
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

#奨学金の返済シミュレーションに使用するアイテムを算出する
scholarship.calcurateItems

#奨学金の通常の返済シミュレーション結果を作成する
scholarship.hensaiSimulation

puts "*****************************************************"
print "奨学金の繰り上げ返済を希望しますか？(Yes / No)： "
sel = gets.chomp
puts "*****************************************************"

#奨学金を繰り上げ返済する場合は、繰り上げ返済情報を入力する。
if sel == "Yes" then
    scholarship.inputKuriageHensaiInfomation
end

#奨学金のシミュレーション結果を出力する。
scholarship.outputWrite
