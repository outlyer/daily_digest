module DailyDigest

  require 'open-uri'

  class ArticleRenderer
    def initialize(number = 10)
      @number = number
    end

    def httpfetch(url,filename)
      unless File.file?(filename) then
        File.open(filename, "wb") do |saved_file|
          # the following "open" is provided by open-uri
          open(url, "rb") do |read_file|
            saved_file.write(read_file.read)
          end
        end
    end
  end

    def render(articles)
      @queue = Queue.new
      articles.each do |article|
        @queue << article
      end
      workers.each(&:join)
    end

    def workers
      (1..@number).to_a.map do |i|
        Thread.new do
          loop do
            break if @queue.empty?
            article = @queue.pop
            print "     Rendering #{article.title}" + "                                                            " + "\r"
            article.content.gsub!(/<img src="\/\//,'<img src="http:\/\/')
            article.content.gsub!(/.jpg.*?\"/,'.jpg"')
            article.content.gsub!(/.png.*?\"/,'.png"')
            if article.content
              article.rendered_content = render_article(article.content)
            end
            print "\n"
          end
        end
      end
    end

    def render_article(content)
      expand_inline_images(content).gsub('<h2', '<h3').gsub('</h2>', '</h3>')
    end

    def expand_inline_images(content)
      content.gsub(/src="(http.*?)"/) {
        begin
          %Q{src="#{expand_image(URI.parse($1))}"}
        rescue
          nil
        end
      }
    end

    def expand_image(url)
      cache = cache_path(url)
      httpfetch(url.to_s,cache)
      cache.sub(/\.[a-zA-Z]+$/, '_r.jpg').tap do |dest|
        system 'convert', '-quiet','-quality', '60', '-colorspace','Gray','-resize', '1072x>', cache, dest
      end
    end

    def cache_path(url)
      cache_dir + "/" + Digest::SHA1.hexdigest(url.to_s) + (File.extname(url.path) || '.png')
    end

    def cache_dir
      begin
        FileUtils.mkdir('_cache')[0]
      rescue Errno::EEXIST
        '_cache'
      end
    end
  end
end
