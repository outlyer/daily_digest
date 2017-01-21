require 'erb'
require 'fileutils'
require 'digest'
require 'uri'

module DailyDigest
  class OPFWrite
    include ERB::Util

    def x(str)
      str.codepoints.map { |code| code > 127 ? "&##{code};" : code.chr }.join("")
    end

    def render(articles, path)
      output = ERB.new(template).result(binding)
      File.open(path, 'w') {|f| f.write(output) }
    end

    def template
      <<-EOF.gsub /^\s+/, ''
      <?xml version="1.0" encoding="utf-8"?>
<package unique-identifier="uid">
<metadata>
  <dc-metadata 
    xmlns:dc="http://purl.org/metadata/dublin_core"
    xmlns:oebpackage="http://openebook.org/namespaces/oeb-package/1.0/">
    <dc:Title>Daily Digest <%= Time.now.strftime('%Y/%m/%d') %></dc:Title>
    <dc:Publisher>Pocket / Daily Digest</dc:Publisher>
    <dc:Creator>Aubin Paul</dc:Creator>
    <dc:Producer>kindlegen</dc:Producer>
    <dc:Language>en-us</dc:Language>
    <dc:Identifier id="uid">Outlyer</dc:Identifier>
    </dc-metadata>
    <x-metadata>
      <output encoding="utf-8" content-type="text/x-oeb1-document"></output> 
      <EmbeddedCover>pocket-logo.jpg</EmbeddedCover>
    </x-metadata>
</metadata>

<manifest>  
<item id="item2" media-type="text/x-oeb1-document" href="dailydigest-#{Time.now.strftime('%Y%m%d')}.html"></item>
<item id="item1" media-type="text/x-oeb1-document" href="dailydigest-#{Time.now.strftime('%Y%m%d')}toc.html"></item> 
<item id="bookcover" media-type="image/jpeg" href="pocket-logo.jpg"></item>
 <item id="css" href="styles/style.css" media-type="text/css" />
    <item id="font_0" href="fonts/Lato-Light.ttf" media-type="application/x-font-ttf" />

    <item id="font_1" href="fonts/Lato-Regular.ttf" media-type="application/x-font-ttf" />

    <item id="font_2" href="fonts/Merriweather-Bold.ttf" media-type="application/x-font-ttf" />

    <item id="font_3" href="fonts/Merriweather-BoldItalic.ttf" media-type="application/x-font-ttf" />

    <item id="font_4" href="fonts/Merriweather-Italic.ttf" media-type="application/x-font-ttf" />

    <item id="font_5" href="fonts/Merriweather-Regular.ttf" media-type="application/x-font-ttf" />

</manifest>
<spine toc="My_Table_of_Contents" pageList>
<itemref idref="item1"/>
</spine>
<guide>
  <reference type="toc" title="Table of Contents" href="dailydigest-#{Time.now.strftime('%Y%m%d%')}toc.html"></reference>
  <reference type="text" title="start" href="dailydigest-#{Time.now.strftime('%Y%m%d')}.html#chapter01"></reference>
</guide>

</package>
      EOF
    end
  end
end
