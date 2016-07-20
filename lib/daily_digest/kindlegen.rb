require 'erb'
require 'fileutils'
require 'digest'
require 'uri'

module DailyDigest
  class Kindlegen
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
        <meta http-equiv="content-type" content="text/html; charset=UTF-8">
        <meta charset="utf-8"/>
        <meta name="Author" content="daily_digest">
        <title>Daily Digest <%= Time.now.strftime('%Y/%m/%d') %></title>
        </head>
        <body>
          <% articles.each.with_index(1) do |article, index| %>
             <div id="chapter<%= '%02i' %index%>"></div>
          <h2 class="chapter"><%=x article.title %></h2>
          <img src="<%h article.leadimage %>">
          <div style="text-align:right"><% if article.author %><%=h article.author %> | <% end %><a href="<%=h article.url %>"><%=h article.domain %></a></div>
          <hr>
          <% if article.content %><%= article.rendered_content %><% end %>
          <mbp:pagebreak />
          <% end %>
        </body>
        </html>
      EOF
    end

    def convert(html, mobi)
      system "kindlegen",'-donotaddsource',html
    end
  end
end
