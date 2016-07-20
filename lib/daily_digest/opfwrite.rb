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
    </x-metadata>
</metadata>

<manifest>  /*  this is a list of the files included in the ebook */
   /* there are two html files here, they are in the ebook in the order shown
      by the item numbers. OatMealFudgeTOC.html comes before OatMealFudge.html
      They could have easily been combined into one html file */
   <item id="item2" media-type="text/x-oeb1-document" href="OatMealFudge.html"></item>
   <item id="item1" media-type="text/x-oeb1-document" href="OatMealFudgeTOC.html"></item> 
   <item id="My_Table_of_Contents" media-type="application/x-dtbncx+xml" href="OatMealFudge.ncx"/>
   <item id="bookcover" media-type="image/jpeg" href="ScoutCover.jpg"></item>
</manifest>

<spine toc="My_Table_of_Contents" pageList>
  <itemref idref="item1"/>
</spine>

<tours>
</tours>

<guide>
  <reference type="toc" title="Table of Contents" href="OatMealFudgeTOC.html#toc"></reference>
  <reference type="text" title="start" href="OatMealFudge.html#start"></reference>
</guide>

</package>
      EOF
    end

    def convert(html, mobi)
      system "ebook-convert", html, mobi, "--mobi-file-type", "old"
    end
  end
end
