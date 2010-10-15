InodeUsage
http://github.com/sambler/InodeUsage

Shane Ambler
Develop@ShaneWare.Biz


InodeUsage is a small Mac OSX project that will show your usage history from your
Internode ADSL account.

(Internode is an Australian ISP)



***** NOTE ABOUT CERTS *****
You may find that this stops working for no apparent reason.
This appears to be from an outdated cert file used by curl.

After updating this file I no longer had problems.

In keychain Access I selected the System Roots keychain and selected all in the list.
Then File->Export Items (as .pem format)
Move or copy the exported file to /usr/share/curl/curl-ca-bundle.crt
You may wish to backup the old file.
