# WiFi Checker

[![Build status](https://build.appcenter.ms/v0.1/apps/a5c8e261-c39d-4cc9-84af-eb5818f20e06/branches/master/badge)](https://appcenter.ms)

WiFi Checker reads the `com.apple.airport.preferences.plist` and pulls the information out and attempts to present it in a somewhat readable fashion.  It uses `api.macvendor.com` to add the MAC manufacturer name, which is rate limited to 1 request per second, so some WiFi hotspots with a lot of MACs will take a while to load.

A fun little side project that tells you all the places your Mac has been.  Depending on how you have iCloud set up, it does appear that a number of your iOS WiFi connections can show up in this list as well.  

