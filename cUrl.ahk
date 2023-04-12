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
CURLOPT_SSL_VERIFYPEER := 64 ;USE ONLY IF YOU GET ERROR #60 AND THE SSL CERT ISNT WORKING ANYMORE (SET TO 0)

;PROGRAM DECLARES
cUrl_Location := "libcurl-x64.dll"
SSL_Location := "curl-ca-bundle.crt"

;LOAD DLL FOR PERFORMANCE
hModule := DllCall("LoadLibrary", "Str", cUrl_Location, "Ptr")

;#endregion

;#region FUNCTIONS -----------------------------------------------------------------------------------------------------------------------------

;MAIN FUNCTIONS
cUrl(URL_P, USER_AGENT)
{
    ;BUFFER DECLARES
    URL := Buffer(StrLen(URL_P) + A_PtrSize)
    UserAgent := Buffer(StrLen(USER_AGENT) + A_PtrSize)
    SSL := Buffer(StrLen(SSL_Location) + A_PtrSize)
    SiteSource := Buffer(0) ;UNSED BUT NEEDED

    ;USED TO STORE SITE DATA
    global SiteData := ''
    ccWrite := CallbackCreate(WriteMemoryCallback, , 4)

    ;PUT STRINGS INTO BUFFERS
    StrPut(URL_P, URL, , "CP0")
    StrPut(USER_AGENT, UserAgent, , "CP0")
    StrPut(SSL_Location, SSL, , "CP0")

    ;CURL
    CurlInit := DllCall(cUrl_Location "\curl_easy_init")
    Curl2 := DllCall(cUrl_Location "\curl_easy_setopt", 'Ptr', CurlInit, 'UInt', CURLOPT_URL, 'Ptr', URL)
    Curl2 := DllCall(cUrl_Location "\curl_easy_setopt", 'Ptr', CurlInit, 'UInt', CURLOPT_CAINFO, 'Ptr', SSL)
    Curl2 := DllCall(cUrl_Location "\curl_easy_setopt", 'Ptr', CurlInit, 'UInt', CURLOPT_USERAGENT, 'Ptr', UserAgent)
    Curl2 := DllCall(cUrl_Location "\curl_easy_setopt", 'Ptr', CurlInit, 'UInt', CURLOPT_WRITEFUNCTION, 'Ptr', ccWrite)
    Curl2 := DllCall(cUrl_Location "\curl_easy_setopt", 'Ptr', CurlInit, 'UInt', CURLOPT_WRITEDATA, 'Ptr', SiteSource)
    Res := DllCall(cUrl_Location "\curl_easy_perform", 'Ptr', CurlInit)

    ;GET cURL ERRORS
    if (res != 0)
    {
        MsgBox('Curl Encounter An Error: #' Res)
    }

    ;CLEANUP
    DllCall(cUrl_Location "\curl_easy_cleanup", 'Ptr', CurlInit)
    CurlInit := '', UserAgent := '', URL := '', SSL := ''
    CallbackFree(ccWrite), ccWrite := ''

    return SiteData
}

;WRITEBACK FUNCTION TO GET WEBSITE DATA
WriteMemoryCallback(data, size, nmemb, clientp)
{
    realsize := size * nmemb
    global SiteData := SiteData StrGet(data, , 'CP0')
    return realsize
}

OnExit(RunExit)

RunExit(*) {
    DllCall("FreeLibrary", "Ptr", hModule)
}

;#endregion
