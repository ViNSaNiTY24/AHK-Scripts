#Include "E:\Misc. Stuff\AutoHotkey\Lib\cUrl\cUrl.ahk"
#Include "E:\Misc. Stuff\AutoHotkey\Lib\JSON\JXON.ahk"

CheckStocks(symbol, priceCheck)
{
    try {
        TimeString := FormatTime(A_Now, "HHmm")

        StartTime := 0930
        EndTime := 1600

        STOCKS := cUrl('https://quote.cnbc.com/quote-html-webservice/restQuote/symbolType/symbol?symbols=' symbol '&requestMethod=itv&noform=1&partnerId=2&fund=1&exthrs=1&output=json&events=1')
        obj := jxon_load(&STOCKS)

        if (TimeString >= StartTime && TimeString < EndTime) {
            price := obj['FormattedQuoteResult']['FormattedQuote'][1]['last']
            TimeDate := obj["FormattedQuoteResult"]["FormattedQuote"][1]["last_timedate"]
        } else {
            price := obj['FormattedQuoteResult']['FormattedQuote'][1]['ExtendedMktQuote']['last']
            TimeDate := obj["FormattedQuoteResult"]["FormattedQuote"][1]['ExtendedMktQuote']["last_timedate"]
        }

        return symbol ':' Round(price, 2) ' [' TimeDate ']'
    } catch Error as e {
        return symbol ':' 'Error'
    }
}

tmeCheck()
{
    AEMD := CheckStocks('AEMD', 1.00)
    Sleep(100)
    GDHG := CheckStocks('GDHG', 4.00)

    MsgBox(AEMD '`n' GDHG)
}

tmeCheck()