require 'erb'
require 'fileutils'
require 'digest'
require 'uri'

module DailyDigest
  class TOCWrite
    include ERB::Util

    def x(str)
      str.codepoints.map { |code| code > 127 ? "&##{code};" : code.chr }.join("")
    end

    def render(articles, path)
      ArticleRenderer.new.render(articles)
      output = ERB.new(template).result(binding)
      File.open(path, 'w') {|f| f.write(output) }
    end

    def template
      <<-EOF.gsub /^\s+/, ''
        <html>
        <head>
        <meta http-requiv="Content-Type" content="text/html;charset=utf-8">
        <meta name="Author" content="daily_digest">
        <title>Table of Contents <%= Time.now.strftime('%Y/%m/%d') %></title>
        </head>
        <body>
<div>
<a id="toc"></a>
 <h1><b>Table of Contents</b></h1>
 <br />
<div>
 <% articles.each.with_index(1) do |article, index| %>
  <p><a href="dailydigest-#{Time.now.strftime('%Y%m%d%H%M')}.html#chapter<%= '%02i' %index%>"><%=x article.title %></a></p>
</div>
          <% end %>
          <mbp:pagebreak />
        </body>
        </html>
      EOF
    end
  end
end
