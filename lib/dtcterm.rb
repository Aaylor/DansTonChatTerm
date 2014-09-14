module Dtcterm
    begin
        require 'Win32/Console/ANSI' if RUBY_PLATFORM =~ /win32/
    rescue LoadError
        raise 'win32console is needed to use color on Windows. Try `gem install win32console`'
    end

    require 'optparse'
    require 'nokogiri'
    require 'open-uri'
    require 'rubygems'

    class << self

        $using_color = true
        $dtc_choice  = ""

        BASE_QUOTE_LINK = "http://danstonchat.com/id.html"

        DTC_FLOP_URL            = "http://danstonchat.com/flop50.html"
        DTC_LATEST_URL          = "http://danstonchat.com/latest.html"
        DTC_RANDOM_URL          = "http://danstonchat.com/random.html"
        DTC_RANDOM_POSITIVE_URL = "http://danstonchat.com/random0.html"
        DTC_TOP_URL             = "http://danstonchat.com/top50.html"

        def version
            '0.1.0'
        end



        class Quote
            attr_accessor :id
            attr_accessor :link
            attr_accessor :quote

            def initialize
                @id = 0
                @link = ""
                @quote = Array.new { Array.new(2) }
            end

            def colorize(text)
                "\e[32m#{text}\e[0m"
            end

            def display
                print "Quote ##{id}\n"
                print "Link: #{link}\n"
                @quote.each do |item|
                    print "#{$using_color ? colorize(item[0]) : item[0]} #{item[1]}\n"
                end
            end
        end



        def get_page_html(url)
            begin
                Nokogiri::HTML(open(url))
            rescue
                puts "Can't reach the server."
                exit 1
            end
        end

        def get_quote_list(html)
            quote_list = Array.new

            html.css('div.item-listing').css('div.item').each do |item|
                quote = Quote.new
                quote.id = item["class"].gsub(/[^\d]/, '')
                quote.link = BASE_QUOTE_LINK.gsub("id", quote.id)

                quote_item = item.children()[0].children()[0].children()[0]
                while quote_item
                    # A quote is always like : <span class="decoration">text</span> text
                    # The "decoration" class means the username

                    # Getting the span text.
                    first = quote_item.text.sub(/\<br>/, '').strip()

                    # Getting the rest of text
                    quote_item = quote_item.next()
                    if (quote_item != nil)
                        second = quote_item.text.sub(/'\<br>/, '').strip()
                        quote_item = quote_item.next()
                    end

                    quote.quote << [first, second]
                end

                quote_list << quote
            end

            quote_list
        end

        def display_quote_list(quote_list)
            quote_list.each do |quote|
                quote.display
                print "\n\n"
            end
        end



        def main(options)
            def self.quote_already_set
                unless $dtc_choice.empty?
                    puts("Un choix de quote a déjà été fait.")
                    exit 1
                end
            end

            OptionParser.new do |opts|

                opts.banner = "Usage: dtcterm one_quote_option [color_option]"

                opts.version = VERSION

                opts.on("-c", "--no-color", "Enlève la couleur.") do
                    $using_color = false
                end

                opts.on("-f", "--flop", "Rubrique `flop50`.") do
                    quote_already_set
                    $dtc_choice = DTC_FLOP_URL
                end

                opts.on("-l", "--latest", "Rubrique `Derniers ajours`.") do
                    quote_already_set
                    $dtc_choice = DTC_LATEST_URL
                end

                opts.on("-r",  "--random", "Rubrique `random`.") do
                    quote_already_set
                    $dtc_choice = DTC_RANDOM_URL
                end

                opts.on("-R", "--random0", "Rubrique `random > 0`") do
                    quote_already_set
                    $dtc_choice = DTC_RANDOM_POSITIVE_URL
                end

                opts.on("-t", "--top", "Rubrique `top50`") do
                    quote_already_set
                    $dtc_choice = DTC_TOP_URL
                end

            end.parse!(options)

            if $dtc_choice.empty?
                puts("Il faut choisir une rubrique.")
                exit 1
            end

            unless options.empty?
                puts("Liste d'argument incorrects.")
                exit 1
            end

            html = get_page_html(DTC_RANDOM_POSITIVE_URL)
            quote_list = get_quote_list(html)
            display_quote_list(quote_list)
        end
    end
end
