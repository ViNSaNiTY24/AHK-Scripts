# AHK (AutoHotkey) Scripts

## cUrl.ahk<br>
-Used to make web request via cURL <br>
-Download cURL for windows here https://curl.se/windows/ <br>
-Set the "cUrl_Location" & "SSL_Location" in the cUrl.ahk to the location of "libcurl-x64.dll" (libcurl.dll for 32-bit) & "curl-ca-bundle.crt" <br>
-Make sure to put #Include cUrl.ahk in your script and to send a GET request use MyVar := cUrl('URL') OR MyVar := cUrl('Url', 'User-Agent: My User Agent', 'Header2: My Header 2') to use with headers.
