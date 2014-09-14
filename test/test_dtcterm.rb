require 'test/unit'
require 'dtcterm'
require 'nokogiri'

class DtctermTest < Test::Unit::TestCase

    def test_version
        assert(Dtcterm.version =~ /\d.\d.\d/)
    end

    def test_get_quote_list
        html = <<-eos
        <div class="item-listing">
            <h1>Random things</h1>
            <div class="item item1234">
                <p class="item-content">
                    <a href="useless_link">
                        <span class="decoration">Person1: </span>Hello there !
                        <span class="decoration">Person2: </span>Hello you !
                        <span class="decoration">Person1: </span>How are you ?
                        <span class="decoration">Person2: </span>It's a flesh wound
                        <span class="decoration">Person1: </span>DUCK DUCK !
                        <span class="decoration">Person2: </span>Nice holy grenade !
                        <span class="decoration">Person1: </span>Oh.
                    </a>
                </p>
            </div>
            <div class="item item4567">
                <p class="item-content">
                    <a href="useless_link">
                        <span class="decoration">mew > </span>Groumpf
                        <span class="decoration">two > </span>Some test
                    </a>
                </p>
            </div>
        </div>
        eos

        html = html.gsub(/\n/, '').strip.gsub(/[[:space:]]{2,}/, '')
        quote_list = Dtcterm::get_quote_list(Nokogiri::HTML(html))

        quote = quote_list[0]
        assert_equal quote.id, "1234"
        assert_equal quote.link, "http://danstonchat.com/1234.html"
        
        q = quote.quote[0]
        assert_equal q[0], "Person1:"
        assert_equal q[1], "Hello there !"

        q = quote.quote[1]
        assert_equal q[0], "Person2:"
        assert_equal q[1], "Hello you !"

        q = quote.quote[2]
        assert_equal q[0], "Person1:"
        assert_equal q[1], "How are you ?"
        
        q = quote.quote[3]
        assert_equal q[0], "Person2:"
        assert_equal q[1], "It's a flesh wound"

        q = quote.quote[4]
        assert_equal q[0], "Person1:"
        assert_equal q[1], "DUCK DUCK !"

        q = quote.quote[5]
        assert_equal q[0], "Person2:"
        assert_equal q[1], "Nice holy grenade !"

        q = quote.quote[6]
        assert_equal q[0], "Person1:"
        assert_equal q[1], "Oh."



        quote = quote_list[1]
        assert_equal quote.id, "4567"
        assert_equal quote.link, "http://danstonchat.com/4567.html"
        
        q = quote.quote[0]
        assert_equal q[0], "mew >"
        assert_equal q[1], "Groumpf"

        q = quote.quote[1]
        assert_equal q[0], "two >"
        assert_equal q[1], "Some test"
    end

end
