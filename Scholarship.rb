#奨学金の返済をシミュレーションするプログラムです。

require "rubygems"
require "spreadsheet"
require "rubyxl"
require "date"
require "bigdecimal"

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
        @kuriageHensaiDate = @hensaiDate.clone

        #奨学金の返済年数と返済回数を求める
        @hensaiNensu = self.getHensaiNensu.to_i
        @hensaiKaisu = @hensaiNensu * 12

        #奨学金の据置利息（卒業してから奨学金の返済が開始するまでにかかる利息）を求める
        wTotalSueokiRisoku = self.getTotalSueokiRisoku
        wTukiSueokiRisoku = wTotalSueokiRisoku / @hensaiKaisu

        #小数点付きの月据え置き利息から小数点以下を切り捨てしたものを月据え置き利息とする
        @tukiSueokiRisoku = wTukiSueokiRisoku.to_i

        #小数点付きの月据え置き利息から、小数点以下を切り捨てた月据え置き利息 * 返済回数を減算したものを据え置き利息の余りとする。
        @amariGoukeigaku = (wTotalSueokiRisoku - (@tukiSueokiRisoku * @hensaiKaisu)).to_i

        #奨学金の月返済額（据置利息以外）を求める
        @tukiHensaigaku = self.getTukiHensaigaku.to_i

        #月に返済する金額を求める
        @hensaigaku = @tukiHensaigaku + @tukiSueokiRisoku

        #毎月奨学金を返済していった場合最終的に支払う奨学金の総額を算出する。
        @nomalHensaiSogaku = @hensaigaku * @hensaiKaisu + @amariGoukeigaku
    end

    #奨学金の返済年数を求めるメソッド
    def getHensaiNensu
        #奨学金の公式サイト参照
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
        #返済総額 * 年利（百分率） * 奨学金の貸与終了から返済開始までの日数180日 / 1年
        @hensaiSogaku * (@nenri / 100) * 180 / 365
        #@hensaiSogaku * BigDecimal((@nenri / 100).to_s).floor(4).to_f * 180 / 365
        #puts "年利(100分率) = #{@nenri / 100}"
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
        elsif hensaiDate.wday == 6 then #奨学金の引き落とし日が日曜日の場合は２日後を奨学金の引き落とし日とする。
            hensaiDate + 2
        else #奨学金の引き落とし日が平日の場合はその日を引き落とし日とする。
            hensaiDate
        end
    end

    #奨学金の繰り上げ金額、繰り上げ回数、繰り上げシミュレーション結果を取得するメソッド
    def kuriageHensaiSimulation(kuriageYearMonth, kuriageKingaku)
        #繰り上げシミュレーション結果を格納する配列を初期化する。
        kuriageHensaiSimulationInfomationArray = []
        hensaiSimulationInfomationArray = @hensaiSimulationInfomationArray.clone
        kuriageHensaiDate = @kuriageHensaiDate.clone
        findFLG = 0

        #繰り上げ返済希望日までの配列の情報をコピーする。
        for i in 0..hensaiSimulationInfomationArray.size - 1
            hensaiSimulationInfomation = hensaiSimulationInfomationArray[i].clone
            #入力された繰り上げ返済希望日が、繰り上げ可能かどうかチェックする。
            if hensaiSimulationInfomation[2] =~ /#{kuriageYearMonth}/  && hensaiSimulationInfomation[9] == 0 then
                #puts "i:  #{i}"
                findFLG = 1
                break
            end

            #繰り上げ返済対象から除外するフラグを立てる
            hensaiSimulationInfomation[9] = 1
            kuriageHensaiSimulationInfomationArray << hensaiSimulationInfomation
            kuriageHensaiDate = kuriageHensaiDate >> 1
        end

        #繰り上げ希望対象年月に繰り上げができない時、-1（エラー）を返す。
        if findFLG == 0 then
            return -1, -1, -1, kuriageHensaiSimulationInfomationArray
        else
            #繰り上げ可能情報の算出に使用するローカル変数を0に初期化する。
            wKuriageKingaku = 0
            wKuriageKaisu = 0
            wKuriageSueokiRisoku = 0
            wKuriageMotoKingaku = 0
            wKuriageAmariKingaku = 0

            #繰り上げ月の利息を算出する。
            risoku = (hensaiSimulationInfomation[1] * @getsuri).to_i

            #繰り上げ金額から繰り上げ月の利息を減算する。
            kuriageKingaku = kuriageKingaku - risoku

            #繰り上げ可能金額に繰り上げ月の利息を加算する。
            wKuriageKingaku = wKuriageKingaku + risoku

            #繰り上げ月の添字を退避する。
            kuriageTaisyoIndex = i

            #繰り上げ開始の添字を設定する。
            kuriageStart = i
            endFLG = 0

            #繰り上げ返済できる金額と、回数を算出する。
            for i in kuriageStart..hensaiSimulationInfomationArray.size - 1
                #繰り上げ返済対象の返済情報を１件取得する。
                hensaiSimulationInfomation = hensaiSimulationInfomationArray[i].clone
                #繰り上げ返済が不可能になった時、繰り上げ返済可能金額の算出を終了する。
                if kuriageKingaku < hensaiSimulationInfomation[4] + hensaiSimulationInfomation[5]
                                    + hensaiSimulationInfomation[7]
                    endFLG = 1
                    break
                end

                #入力された繰り上げ返済金額の残金を求める
                kuriageKingaku = kuriageKingaku\
                        -  (hensaiSimulationInfomation[4] + hensaiSimulationInfomation[5] + hensaiSimulationInfomation[7])
                #いくら繰り上げ返済可能であるか算出する。
                wKuriageKingaku = wKuriageKingaku\
                        + hensaiSimulationInfomation[4] + hensaiSimulationInfomation[5] + hensaiSimulationInfomation[7]
                wKuriageKaisu = wKuriageKaisu + 1
                wKuriageMotoKingaku = wKuriageMotoKingaku + hensaiSimulationInfomation[4]
                wKuriageSueokiRisoku = wKuriageSueokiRisoku + hensaiSimulationInfomation[5]
                wKuriageAmariKingaku = wKuriageAmariKingaku + hensaiSimulationInfomation[7]
            end

            #繰り上げ返済が不可能になってループを抜けた時
            if endFLG == 1 then
                nextHensaiSogaku = hensaiSimulationInfomation[1]
            else
                nextHensaiSogaku = 0
            end

            #繰り上げ返済が実行される月の返済情報を編集する。
            hensaiSimulationInfomation = hensaiSimulationInfomationArray[kuriageTaisyoIndex].clone
            hensaiSimulationInfomation[3] = wKuriageKingaku
            hensaiSimulationInfomation[4] = wKuriageMotoKingaku
            hensaiSimulationInfomation[5] = wKuriageSueokiRisoku
            hensaiSimulationInfomation[6] = risoku
            hensaiSimulationInfomation[7] = wKuriageAmariKingaku
            hensaiSimulationInfomation[8] = nextHensaiSogaku
            hensaiSimulationInfomation[9] = 1
            #繰り上げ返済希望年月のシミュレーション結果を格納する。
            kuriageHensaiSimulationInfomationArray << hensaiSimulationInfomation
            kuriageHensaiDate = kuriageHensaiDate >> 1
        end

        #完済したときはこの処理を実施しないように条件で判定する。
        if endFLG == 1 then
            start = i
            #奨学金の繰り上げ返済を消化した後の返済シミュレーション結果を作成する。
            for i in start..hensaiSimulationInfomationArray.size - 1
                hensaiSimulationInfomation = hensaiSimulationInfomationArray[i].clone
                #27日が休日かどうか判定し、休日のときは翌月曜日を返済日として返す
                whensaiDate = self.getHensaiDate(kuriageHensaiDate)
                hensaiSimulationInfomation[2] = "#{whensaiDate.year}年#{whensaiDate.month}月#{whensaiDate.day}日"
                kuriageHensaiSimulationInfomationArray << hensaiSimulationInfomation
                kuriageHensaiDate = kuriageHensaiDate >> 1
            end
        end

        #奨学金の繰り上げ返済シミュレーション結果をリターンする。
        return wKuriageKingaku, wKuriageKaisu, nextHensaiSogaku, kuriageHensaiSimulationInfomationArray
    end

    #繰り上げ返済を実施する場合、繰り上げ情報を入力するメソッド
    def inputKuriageHensaiInfomation
        puts "*********************************"
        puts "奨学金の繰り上げ返済を行います。"
        puts "*********************************"

        #繰り上げ返済の回数をカウントする。
        inputKuriageCount = 1
        #初回時の返済総額を返済残金とする
        hensaiZankin = @hensaiSogaku
        errorFLG = 0
        while(1) do
            begin
                #奨学金の繰り上げ可能金額（２ヶ月分）を繰り上げできなくなったら、終了
                if hensaiZankin <= @hensaigaku * 2 && errorFLG == 0 then
                    puts
                    puts "**********************************************************"
                    puts "奨学金の繰り上げ可能金額（２ヶ月分の返済額）を下回りました。"
                    puts "繰り上げシミュレーションを終了します。"
                    puts "**********************************************************"
                    puts
                    break
                end

                #繰り上げ返済の情報が２回めのときは入力終了の選択肢を一つ追加する
                if inputKuriageCount >= 2 && errorFLG == 0 then
                    while(1) do
                        puts
                        print "続けて繰り上げ返済をする場合は【Yes】、しない場合は【No】を入力してください： "
                        sel = gets.chomp
                        if sel == "Yes" || sel == "No" then
                            break
                        else
                            puts "********************************"
                            puts "YesとNo以外が入力されました。"
                            puts "入力をやり直してください。"
                            puts "********************************"
                        end
                    end

                    #Noが入力されたときは繰り上げ返済を終了する。
                    if sel == "No" then
                        break
                    end
                end

                puts
                puts "奨学金の残額は #{hensaiZankin}円です。"
                puts
                print "#{inputKuriageCount}回目の繰り上げ返済情報を入力してください\n"
                print "奨学金の繰り上げ返済を行う年を入力してください(例：2016)\n"
                kuriageYear = gets.chomp
                print "奨学金の繰り上げ返済を行う月を入力してください(例：4)\n"
                kuriageMonth = gets.chomp

                #入力された年と月を『yyyy年mm月』形式にする。
                kuriageYearMonth = "#{kuriageYear}年#{kuriageMonth}月"

                print "奨学金の繰り上げ返済金額を入力してください(例：1000000)\n"
                kuriageKingaku = gets.chomp

                #エラーフラグを0に初期化する。
                errorFLG = 0

                #入力された年と月と金額が数字以外の場合はエラーとする。
                if kuriageYear =~ /^[0-9]+$/ && kuriageMonth =~ /^[0-9]+$/ && kuriageKingaku =~ /^[0-9]+$/ then
                    kuriageYear = kuriageYear.to_i
                    kuriageMonth = kuriageMonth.to_i
                    kuriageKingaku = kuriageKingaku.to_i

                    if kuriageKingaku < @hensaigaku * 2 then
                        puts
                        puts "*******************************************************"
                        puts "繰り上げ返済金額は最低でも２ヶ月分の月返済額が必要です。"
                        puts "もう一度入力してください"
                        puts "*******************************************************"
                        errorFLG = 1
                    end
                else
                    puts
                    puts "*************************************************"
                    puts "入力された値が不正です。もう一度入力してください"
                    puts "*************************************************"
                    errorFLG = 1
                end

                if errorFLG == 0 then
                    #「繰り上げ金額」「繰り上げ回数」「繰り上げ後の残額」「繰り上げ返済シミュレーション結果」を求める
                    kuriageHensaiKingaku, kuriageHensaiKaisu, nokoriHensaiSogaku, kuriageHensaiSimulationInfomationArray\
                                        = self.kuriageHensaiSimulation(kuriageYearMonth, kuriageKingaku)

                    #入力された繰り上げ年月が無効の場合はエラーとする
                    if kuriageHensaiKingaku < 0 then
                        puts
                        puts "************************************************************"
                        puts "入力された繰り上げ年月と金額で繰り上げ返済シミュレーションを"
                        puts "実行することができません。もう一度入力してください。"
                        puts "************************************************************"
                        errorFLG = 1
                    else
                        #繰り上げ返済可能金額と回数を表示する。
                        puts
                        print "奨学金の繰り上げ金額は #{kuriageHensaiKingaku}円です\n"
                        print "奨学金の繰り上げ回数は #{kuriageHensaiKaisu}回です\n"
                        while(1) do
                            puts
                            print "よろしければ【Yes】、訂正する場合は【No】を入力してください： "
                            sel = gets.chomp

                            #入力された文字列が"Yes"の時、繰り上げ返済シミュレーション結果を反映する。
                            if sel == "Yes" then
                                hensaiZankin = nokoriHensaiSogaku
                                #繰り上げ返済シミュレーション結果を反映する。
                                @hensaiSimulationInfomationArray = kuriageHensaiSimulationInfomationArray
                                #繰り上げ返済回数をカウントアップする。
                                inputKuriageCount = inputKuriageCount + 1
                                break
                            elsif sel == "No" then
                                puts "********************************************"
                                print "Noが入力されたので、入力を取り消します。\n"
                                puts "********************************************"
                                errorFLG = 1
                                break
                            else
                                puts "***********************************************"
                                print "入力できる文字列は【Yes】と【No】のみです。\n"
                                print "もう一度入力してください。\n"
                                puts "***********************************************"
                            end
                        end
                    end
                end
            rescue Interrupt #Control + Cが入力されたときの処理
                puts
                puts "**************************************************"
                puts "繰り上げ返済シミュレーションが強制終了しました。"
                puts "**************************************************"
                break
            end
        end
    end

    #繰り上げ返済シミュレーション後の合計返済金額を算出するメソッド
    def getKuriageTotalKingaku
        @kuriageTotalKingaku = 0
        for i in 0..@hensaiSimulationInfomationArray.size - 1
            @kuriageTotalKingaku = @kuriageTotalKingaku + @hensaiSimulationInfomationArray[i][3]
        end
    end

    #奨学金の返済シミュレーション結果をxlsx形式で出力するメソッド
    def outputWrite2
        book = RubyXL::Workbook.new
        sheet = book[0]
        sheet.sheet_name = "奨学金返済計画表"
        hyodaiArray = ["残り回数","奨学金残額","奨学金引落日","返済金額","返済元金","据置利息","利息","端数金額","奨学金引落後残額"]

        #(0,0)セルから(0,8)セルまで結合する
        sheet.merge_cells 0, 0, 0, 8
        cell = sheet.add_cell(0, 0, "奨学金返済計画")
        cell.change_horizontal_alignment
        #cell.change_border(:bottom, 'thin')

        #表題の編集
        for i in 0..hyodaiArray.size - 1
            cell = sheet.add_cell(1, i, hyodaiArray[i])
            cell.change_horizontal_alignment
            cell.change_border(:bottom, 'thin')
            cell.change_border(:top, 'thin')
            cell.change_border(:right, 'thin')
            cell.change_border(:left, 'thin')
            cell.change_fill("AFEEEE")
        end

        #繰り上げフラグ
        kuriageFLG = 0

        for i in 0..@hensaiSimulationInfomationArray.size - 1
            for j in 0..8
                cell = sheet.add_cell(i + 2, j, @hensaiSimulationInfomationArray[i][j])
                cell.change_border(:bottom, 'thin')
                cell.change_border(:top, 'thin')
                cell.change_border(:right, 'thin')
                cell.change_border(:left, 'thin')
                if j == 1 || j  == 3 || j == 4 || j == 5 || j == 6 || j == 7 || j == 8 then
                    cell.set_number_format "#,##0円"
                elsif j == 0 then
                    cell.set_number_format "#,##0回"
                end
            end
            kuriageFLG = kuriageFLG + @hensaiSimulationInfomationArray[i][9]
        end

        cell = sheet.add_cell(i + 3, 2, "返済総額")
        cell.change_horizontal_alignment
        cell = sheet.add_cell(i + 3, 3, @kuriageTotalKingaku)
        cell.set_number_format "#,##0円"
        cell.change_border(:bottom, 'thin')
        cell.change_border(:top, 'thin')
        cell.change_border(:right, 'thin')
        cell.change_border(:left, 'thin')

        #繰り上げが実行されている時
        if kuriageFLG != 0 then
            cell = sheet.add_cell(i + 4, 2, "繰り上げ差額")
            cell.change_horizontal_alignment
            cell = sheet.add_cell(i + 4, 3, @nomalHensaiSogaku - @kuriageTotalKingaku)
            cell.set_number_format "#,##0円"
            cell.change_border(:bottom, 'thin')
            cell.change_border(:top, 'thin')
            cell.change_border(:right, 'thin')
            cell.change_border(:left, 'thin')
        end

        #引数で指定したファイルへの書き出しを実施する。
        book.write('Scholarship.xlsx')
    end

    #奨学金の返済シミュレーション結果をxls形式で出力するメソッド（非推奨）
    def outputWrite
        #Excelファイルをインスタンス化する
        book = Spreadsheet::Workbook.new

        #新規シートを作成する
        sheet = book.create_worksheet

        #sheetに名前を設定する
        sheet.name = "奨学金返済計画表"

        #表題を配列に保存する。
        hyodaiArray = ["残り回数","奨学金残額","奨学金引落日","返済金額","返済元金","据置利息","利息","端数金額","奨学金引落後残額"]

        #Excelファイルに表題を出力する。
        sheet[0, 0] = "奨学金返済計画"

        #表題の編集
        for i in 0..hyodaiArray.size - 1
            sheet[1, i] = hyodaiArray[i]
        end

        #繰り上げフラグ
        kuriageFLG = 0

        #配列の中身をファイルに出力する
        for i in 0..@hensaiSimulationInfomationArray.size - 1
            for j in 0..8
                sheet[i + 2, j] = @hensaiSimulationInfomationArray[i][j]
            end
            kuriageFLG = kuriageFlg + @hensaiSimulationInfomationArray[i][9]
        end

        #繰り上げが実行されている時
        if kuriageFLG != 0 then
            sheet[i + 3, 2] = "返済総額"
            sheet[i + 3, 3] = "#{@kuriageTotalKingaku}円"
            sheet[i + 4, 2] = "繰り上げ差額"
            sheet[i + 4, 3] = "#{@nomalHensaiSogaku - @kuriageTotalKingaku}円"
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
        hensaiDate = @hensaiDate.clone

        #奨学金の返済シミュレーション結果を格納する配列を初期化する
        @hensaiSimulationInfomationArray = []
        #シミュレーション結果を作成する
        while(1) do
            #月返済額の利息を計算する。
            risoku = (hensaiSogaku * @getsuri).to_i

            #27日が休日かどうか判定し、休日のときは翌月曜日を返済日として返す
            whensaiDate = self.getHensaiDate(hensaiDate)

            #Excelファイルに出力する情報を１行分編集する。
            hensaiSimulationInfomation = []
            if hensaiSogaku <= @hensaigaku then
                hensaiSimulationInfomation << hensaiKaisu - hensaiCount
                hensaiSimulationInfomation << hensaiSogaku
                hensaiSimulationInfomation << "#{whensaiDate.year}年#{whensaiDate.month}月#{whensaiDate.day}日"
                hensaiSimulationInfomation << hensaiSogaku + amariGoukeigaku
                hensaiSimulationInfomation << hensaiSogaku
                hensaiSimulationInfomation << @tukiSueokiRisoku
                hensaiSimulationInfomation << risoku
                hensaiSimulationInfomation << amariGoukeigaku - @tukiSueokiRisoku - risoku
                hensaiSimulationInfomation << 0
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
                hensaiSimulationInfomation << 0
                @hensaiSimulationInfomationArray << hensaiSimulationInfomation
                #返済した金額分、返済総額を減額する。
                hensaiSogaku = hensaiSogaku - (@hensaigaku - @tukiSueokiRisoku - risoku)
                hensaiCount = hensaiCount + 1
                hensaiDate = hensaiDate >> 1
            end
        end
    end
end


#奨学金シミュレーションツールのスタート
begin
    #数値が入力されるまで、再度入力させる。
    while(1) do
        #ターミナルより奨学金情報を入力
        print "奨学金の返済総額を入力してください(例：3840000)\n"
        hensaiSogaku = gets.chomp
        print "奨学金の年利を入力してください(例：0.16)\n"
        nenri = gets.chomp
        print "奨学金の貸与終了年を入力してください(例：2016)\n"
        taiyoEndYear = gets.chomp

        #入力された返済総額、年利、貸与終了年が数字以外の場合エラーとし、再度入力させる
        if hensaiSogaku =~ /^[0-9]+$/ && nenri =~ /^([0-9]|\.)+$/ && taiyoEndYear =~ /^[0-9]+$/ then
            hensaiSogaku = hensaiSogaku.to_i
            nenri = nenri.to_f
            taiyoEndYear = taiyoEndYear.to_i
            break
        else
            puts
            puts "************************************************"
            puts "入力された値が不正です。もう一度入力してください。"
            puts "************************************************"
            puts
        end
    end

    #Scholarshipクラスをインスタンス化する
    scholarship = Scholarship.new(hensaiSogaku, nenri, taiyoEndYear)

    #奨学金の返済シミュレーションに使用するアイテムを算出する
    scholarship.calcurateItems

    #奨学金の通常の返済シミュレーション結果を作成する
    scholarship.hensaiSimulation

    #【Yes】、【No】が入力されるまで、入力を続けさせる
    while(1) do
        puts
        print "繰り上げ返済をする場合は【Yes】、しない場合は【No】を入力してください：  "
        sel = gets.chomp
        #奨学金を繰り上げ返済する場合は、繰り上げ返済情報を入力する。
        if sel == "Yes" then
            scholarship.inputKuriageHensaiInfomation
            scholarship.getKuriageTotalKingaku
            break
        elsif sel == "No" then
            scholarship.getKuriageTotalKingaku
            break
        else
            puts
            puts "*******************************"
            puts "入力された文字列が不正です。"
            puts "*******************************"
        end
    end

    #奨学金のシミュレーション結果を出力する。
    scholarship.outputWrite2
rescue Interrupt #Control + Cが入力されたときの処理
    puts
    puts "**************************************************"
    puts "奨学金返済シミュレーションプログラムを終了します。"
    puts "**************************************************"
end
