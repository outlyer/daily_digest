require 'erb'
require 'fileutils'
require 'digest'
require 'uri'
require 'kindlegen'
require 'sanitize'

module DailyDigest
  class Mobigen
    include ERB::Util

    def x(str)
      str.codepoints.map { |code| code > 127 ? "&##{code};" : code.chr }.join("")
    end

    def render(articles, path)
      ArticleRenderer.new.render(articles)
      output = ERB.new(template).result(binding)
      output = Sanitize.document(output,
        :elements => ['xml','a', 'address', 'article', 'aside', 'b', 'blockquote', 'body', 'br', 'caption', 'center', 'cite', 'code', 'col', 'dd', 'del', 'dfn', 'div', 'dl', 'dt', 'em', 'figcaption', 'figure', 'footer', 'h1', 'h2', '     h3', 'h4', 'h5', 'h6', 'head', 'header', 'hgroup', 'hr', 'html', 'i', 'img', 'ins', 'kbd', 'li', 'link', 'mark', 'menu', 'ol', 'output', 'p', 'pre', 'q', 'rp', 'rt', 'samp', 'section', 'small', 'source', 'span', 'strong', '   style', 'strike', 'sub', 'sup', 'table', 'tbody', 'td', 'tfoot', 'th', 'thead', 'time', 'title', 'tr', 'u', 'ul', 'var', 'wbr', 'nav', 'summary'],
        :attributes => {
          'a'    => ['href', 'title'],
          'span' => ['class'],
          'img'  => ['alt', 'src', 'title']
        },
        :protocols => {
          'a' => {'href' => ['http', 'https', 'mailto']}
        })
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
          <% if article.item_id %><a href="<%=h article.archive_item %>">&#x1f4be; Archive on Pocket</a><% end %>
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
