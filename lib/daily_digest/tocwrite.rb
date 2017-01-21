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
        <?xml version="1.0" encoding="UTF-8"?>
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2007/ops" xml:lang="en" lang="en">
<head>
        <meta http-equiv="Content-Type" content="text/html;charset=utf-8">
        <meta name="Author" content="daily_digest">
        <title>Table of Contents <%= Time.now.strftime('%Y/%m/%d') %></title>
        <meta charset="UTF-8" />
        <link rel="stylesheet" type="text/css" href="styles/style.css" />
        </head>
        <body>
<nav id="toc" epub:type="toc">
 <h1 class="chapter-title">Contents</h1>
<ol>
 <% articles.each.with_index(1) do |article, index| %>
  <li class="toc-1"><a href="dailydigest-#{Time.now.strftime('%Y%m%d')}.html#chapter<%= '%02i' %index%>"><%=x article.title %></a></li>
          <% end %>
          </ol>
          </nav>
          <mbp:pagebreak />
        </body>
        </html>
      EOF
    end
  end
end
