DansTonChatTerm
===============

DansTonCharTerm is a utility to read quotes from [DansTonChat](http://danstonchat.com/) website, using a terminal.  
It's wrote in Ruby, using [Nokogiri](http://nokogiri.org/) library to parse html and [HTMLEntities](https://rubygems.org/gems/htmlentities).  


###Installation

Installation need [gem](https://rubygems.org/)
And just execute in a terminal
```
gem install dtcterm
```


###Usage

The script need one (and only one) argument to chose a category from the website.  

Execute
```
dtcterm -h
dtcterm --help
````
to get further informations about those categories (or check the website itself).  


By default, the program will display colors output.  
It's possible remove color by executing
```
dtcterm -a_quote_category -c
dtcterm -a_quote_category --no-color
```

