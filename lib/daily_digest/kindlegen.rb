require 'erb'
require 'fileutils'
require 'digest'
require 'uri'
require 'kindlegen'

module DailyDigest
  class Mobigen
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
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE html>
        <html xmlns="http://www.w3.org/1999/xhtml" lang="en">
        <head>
        <meta http-equiv="content-type" content="text/html; charset=UTF-8">
        <meta charset="utf-8"/>
        <link rel="stylesheet" type="text/css" href="styles/style.css" />
        <meta name="Author" content="daily_digest">
        <title>Daily Digest <%= Time.now.strftime('%Y/%m/%d') %></title>
        </head>
        <body>
          <% articles.each.with_index(1) do |article, index| %>
             <div id="chapter<%= '%02i' %index%>"></div>
          <h1 class="chapter-title"><%=x article.title %></h1>
          <div class="byline"><% if article.author %><%=h article.author %> | <% end %><a href="<%=h article.url %>"><%=h article.domain %></a></div>
          <div class="chapter-content">
          <% if article.content %><%= article.rendered_content %><% end %>
          </div>
          <mbp:pagebreak />
          <% end %>
        </body>
        </html>
      EOF
    end

    def convert(html, mobi)
      stdout, stderr, status = Kindlegen.run(html, '-o', mobi)
      if status == 0
        puts stdout
      else
        $stderr.puts stderr
      end
    end
  end
end
