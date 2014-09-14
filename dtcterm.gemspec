require './lib/dtcterm'

Gem::Specification.new do |s|
    s.name          = 'dtcterm'
    s.version       = Dtcterm.version
    s.date          = Time.now
    s.executables   << 'dtcterm'

    s.summary       = 'DansTonChat viewer in terminal application'
    s.description   = 'DansTonChar viewer in terminal application.\
        Can display different categories from the website. \
        http://www.danstonchat.com'

    s.authors       = ["Loïc Runarvot"]
    s.email         = 'loic.runarvot@gmail.com'
    s.homepage      = 'https://github.com/Aaylor/DansTonChatTerm'
    s.license       = 'MIT'

    s.files         = ['lib/dtcterm.rb']
    s.test_files    = ['test/test_dtcterm.rb']

    s.add_runtime_dependency 'nokogiri', [">= 1.5.6"]
    s.add_runtime_dependency 'htmlentities', [">= 4.3.0"]
    
    s.add_development_dependency 'nokogiri', '>=1.5.6'
end
