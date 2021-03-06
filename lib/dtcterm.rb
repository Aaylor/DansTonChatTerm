module Dtcterm
  begin
    require 'Win32/Console/ANSI' if RUBY_PLATFORM =~ /win32/
  rescue LoadError
    raise 'win32console is needed to use color on Windows. Try `gem install win32console`'
  end

  require 'htmlentities'
  require 'optparse'
  require 'open-uri'
  require 'nokogiri'
  require 'rubygems'


  class << self

    $using_color = true
    $dtc_choice  = ""
    $page        = 1

    BASE_QUOTE_LINK = "http://danstonchat.com/id.html"

    DTC_FLOP_URL            = "http://danstonchat.com/flop50.html"
    DTC_CHRONOLOGICAL_ORDER = "http://danstonchat.com/browse.html"
    DTC_LATEST_URL          = "http://danstonchat.com/latest.html"
    DTC_RANDOM_URL          = "http://danstonchat.com/random.html"
    DTC_RANDOM_POSITIVE_URL = "http://danstonchat.com/random0.html"
    DTC_TOP_URL             = "http://danstonchat.com/top50.html"

    DEFAULT_COLOR = "37"


    def version
      '0.3.2'
    end


    # Class that contains every usefull information for a quote
    class Quote

      # Quote id.
      attr_accessor :id

      # Link to the quote.
      attr_accessor :link

      # The text as an array of [user, text]
      attr_accessor :quote

      # Usernames existing in the quote
      attr_accessor :usernames


      def initialize
        @id = 0
        @link = ""
        @quote = Array.new { Array.new(2) }
        @usernames = {}

        @colors = {
          "red"     => { :syn => "31", :set => false },
          "green"   => { :syn => "32", :set => false },
          "yellow"  => { :syn => "33", :set => false },
          "blue"    => { :syn => "34", :set => false },
          "purple"  => { :syn => "35", :set => false },
          "cyan"    => { :syn => "36", :set => false }
        }
      end

      # Return the first color non set.
      # If no colors available, then it returns the default one.
      def get_color
        @colors.each {
          |key, val| 
          (val[:set] = true; return val[:syn]) unless val[:set]
        }
        DEFAULT_COLOR
      end

      # Add the user to the usernames list.
      # 
      # Arguments:
      #   colors: (string)
      def add_user(user)
        @usernames[user] = get_color unless @usernames.has_key?(user)
      end

      # Colorize the text from the given color
      # 
      # Arguments:
      #   colors: (string)
      #   text: (string)
      def colorize(color, text)
        "\e[#{color}m#{text}\e[0m"
      end

      # Display the quote to stdout
      def display
        print "Quote ##{id}\n"
        print "Link: #{link}\n"
        @quote.each do |item|
          add_user(item[0])
          print "#{$using_color \
                   ? colorize(@usernames[item[0]], item[0]) \
                   : item[0]} #{item[1]}\n"
        end
      end
    end



    # Open the html page. Exit the script if it can't reach the server.
    # 
    # Arguments:
    #   url: (string)
    def get_page_html(url)
      begin
        Nokogiri::HTML(open(url))
      rescue
        puts "Can't reach the server."
        exit 1
      end
    end

    # Give the quote list from the html page.
    #
    # Arguments:
    #   html: (string)
    def get_quote_list(html)
      quote_list = Array.new

      html.css('div.item-listing').css('div.item').each do |item|
        quote = Quote.new
        quote.id = item["class"].gsub(/[^\d]/, '')
        quote.link = BASE_QUOTE_LINK.gsub("id", quote.id)

        quote_item = item.children()[0].children()[0]

        quote_item.children().each do |i|
          if i["class"] == "decoration"
            i.content = "|newline|" + i.content + "|decorationclass|"
          end
        end

        while quote_item
          str = HTMLEntities.new.decode quote_item.content.gsub(/\|newline\|/, "\n")

          str.each_line do |line|
            unless line =~ /^[[:space:]]+$/
              first, second = line.split(/\|decorationclass\|/)
              quote.quote << [first.strip(), second ? second.strip() : second]
            end
          end

          quote_list << quote
          if (quote_item != nil)
            quote_item = quote_item.next()
          end
        end

      end

      quote_list
    end

    # Display a list of quote
    #
    # Arguments:
    #   quote_list: (array)
    def display_quote_list(quote_list)
      quote_list.each do |quote|
        quote.display
        print "\n\n"
      end
    end

    def main(options)
      # Exit the program if a choice has already been made.
      def self.quote_already_set
        unless $dtc_choice.empty?
          puts("Un choix de quote a déjà été fait.")
          exit 1
        end
      end

      OptionParser.new do |opts|

        opts.banner = "Usage: dtcterm one_quote_option [color_option]"

        opts.version = version

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

        opts.on("-o", "--order", "Rubrique `Ordre chronologique`.") do
          quote_already_set
          $dtc_choice = DTC_CHRONOLOGICAL_ORDER
        end

        opts.on("-p", "--page PAGE", "Page choisie") do |p|
          begin
            $page = Integer(p)
            if $page < 1
              raise ArgumentError
            end
          rescue
            puts("L'argument page n'est pas un entier correct (doit être >= 1).")
            exit 1
          end
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

      if $page > 1
        if $dtc != DTC_LATEST_URL and $dtc_choice != DTC_CHRONOLOGICAL_ORDER
          puts("Impossible de choisir une page pour cette catégorie.")
          exit 1
        else
          fp = $dtc_choice.split(/\.html/,)
          $dtc_choice = fp[0] + "/" + $page.to_s + ".html"
        end
      end

      html = get_page_html($dtc_choice)
      quote_list = get_quote_list(html)
      display_quote_list(quote_list)
    end
  end
end
