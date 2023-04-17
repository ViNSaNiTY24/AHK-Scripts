/*
    Uses cUrl to make web request
    Written on: 04/12/2023
*/

;#region DECLARES ------------------------------------------------------------------------------------------------------------------------------

;DECLARES CONSTANTS CURL
CURLOPT_URL := 10002
CURLOPT_WRITEDATA := 10001
CURLOPT_WRITEFUNCTION := 20011
CURLOPT_USERAGENT := 10018
CURLOPT_CAINFO := 10065
CURLOPT_HTTPHEADER := 10023
CURLOPT_ACCEPT_ENCODING := 10102
CURLOPT_SSL_VERIFYPEER := 64 ;USE ONLY IF YOU GET ERROR #60 AND THE SSL CERT ISNT WORKING ANYMORE (SET TO 0)

;PROGRAM DECLARES
cUrl_Location := ""
SSL_Location := ""

;LOAD DLL FOR PERFORMANCE
hModule := DllCall("LoadLibrary", "Str", cUrl_Location, "Ptr")

;#endregion

;#region FUNCTIONS -----------------------------------------------------------------------------------------------------------------------------

;MAIN FUNCTIONS
cUrl(URL_P, HEADERS*)
{
    ;BUFFER DECLARES
    URL := Buffer(StrLen(URL_P) + A_PtrSize)
    SSL := Buffer(StrLen(SSL_Location) + A_PtrSize)
    AcceptEncoding := Buffer(2), StrPut("", AcceptEncoding, , 'CP0')
    SiteSource := Buffer(0) ;UNSED BUT NEEDED

    ;USED TO STORE SITE DATA
    global SiteData := ''
    ccWrite := CallbackCreate(WriteMemoryCallback, , 4)

    ;PUT STRINGS INTO BUFFERS
    StrPut(URL_P, URL, , "CP0")
    StrPut(SSL_Location, SSL, , "CP0")

    ;HEADERS
    HeaderList := 0
    for HEAD in HEADERS
    {
        HeaderList := AddHeaders(HeaderList, HEAD)
    }

    ;CURL
    CurlInit := DllCall(cUrl_Location "\curl_easy_init")
    DllCall(cUrl_Location "\curl_easy_setopt", 'Ptr', CurlInit, 'UInt', CURLOPT_URL, 'Ptr', URL)
    DllCall(cUrl_Location "\curl_easy_setopt", 'Ptr', CurlInit, 'UInt', CURLOPT_CAINFO, 'Ptr', SSL)
    DllCall(cUrl_Location "\curl_easy_setopt", 'Ptr', CurlInit, 'UInt', CURLOPT_HTTPHEADER, 'Ptr', HeaderList)
    DllCall(cUrl_Location "\curl_easy_setopt", 'Ptr', CurlInit, 'UInt', CURLOPT_ACCEPT_ENCODING, 'Ptr', AcceptEncoding)
    DllCall(cUrl_Location "\curl_easy_setopt", 'Ptr', CurlInit, 'UInt', CURLOPT_WRITEFUNCTION, 'Ptr', ccWrite)
    DllCall(cUrl_Location "\curl_easy_setopt", 'Ptr', CurlInit, 'UInt', CURLOPT_WRITEDATA, 'Ptr', SiteSource)
    Res := DllCall(cUrl_Location "\curl_easy_perform", 'Ptr', CurlInit)

    ;GET cURL ERRORS
    if (res != 0)
    {
        MsgBox('Curl Encounter An Error: #' Res)
    }

    ;CLEANUP
    DllCall(cUrl_Location "\curl_slist_free_all", "Ptr", HeaderList)
    DllCall(cUrl_Location "\curl_easy_cleanup", 'Ptr', CurlInit)
    CallbackFree(ccWrite)

    return SiteData
}

AddHeaders(HeaderList, string) {
    StrPut(string, stringA := Buffer(StrLen(string) + A_PtrSize), "CP0")
    return HeaderList := DllCall(cUrl_Location "\curl_slist_append", "Ptr", HeaderList, "Ptr", stringA, "Ptr")
}

;WRITEBACK FUNCTION TO GET WEBSITE DATA
WriteMemoryCallback(data, size, nmemb, clientp)
{
    realsize := size * nmemb
    global SiteData := SiteData StrGet(data, realsize, 'CP0')
    return realsize
}

OnExit(RunExit)

RunExit(*) {
    DllCall("FreeLibrary", "Ptr", hModule)
}

;#endregion
