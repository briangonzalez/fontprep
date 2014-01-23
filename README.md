<img src='https://rawgithub.com/briangonzalez/fontprep/master/fontprep/server/application/assets/images/logo.svg' height='30'> FontPrep 
========
The missing font generator for Mac OSX.

About
-----
FontPrep takes your TTF and OTF font files and generates all of the respective font-formats for the web: WOFF, EOT, and SVG.

How it works
----------
FontPrep uses a slightly modified version of cocoa-rack (https://github.com/briangonzalez/cocoa-rack). In essence, when you start FontPrep, you're starting a little Sinata app on port 7500 then instantiating a webview point at that server. 

Commands are sent from the webview back down to the Sinatra server as you interact with FontPrep, and commands are piped to stdout (be it FontForge, ttf2eot, etc.) to complete the given taks. We use a little Applescript magic when necessary.

The main Sinatra logic lives inside of `fontprep/server`. The sinatra server is daemonized, meanings its process will persist across closing and opening of FontPrep. To kill FontPrep's server outright, visit `http://127.0.0.1:7500/kill` in your browser.   

Building FontPrep
-----------------
Simply open up `FontPrep.xcodeproj` with the latest version of XCode, go to `Product -> Clean` then `Product -> Run`.

A word of caution
-----------------
This code has not been incredibly well maintained over the years. Tread lightly and have fun breaking FontPrep.

Demo
----
Watch a demo [here](http://www.youtube.com/watch?feature=player_embedded&v=4nF3GHHOw-E).

Author
------
| ![twitter/brianmgonzalez](http://gravatar.com/avatar/f6363fe1d9aadb1c3f07ba7867f0e854?s=70](http://twitter.com/brianmgonzalez "Follow @brianmgonzalez on Twitter") |
|---|
| [Brian Gonzalez](http://briangonzalez.org) |

