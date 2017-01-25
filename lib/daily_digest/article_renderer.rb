module DailyDigest

  require 'open-uri'
  require 'mini_magick'

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
      maxlength = 0
      (1..@number).to_a.map do |i|
        Thread.new do
          loop do
            break if @queue.empty?
            article = @queue.pop
            if article.title.length > maxlength
              maxlength = article.title.length
            end
            padding = " " * (maxlength-16)
            print "     Rendering #{article.title}" + padding + "\r"
            article.content.gsub!(/<img src="\/\//,'<img src="http:\/\/')
            article.content.gsub!(/.jpg%20.*?\"/,'.jpg"')
            article.content.gsub!(/.png%20.*?\"/,'.png"')
            if article.content
              article.rendered_content = render_article(article.content)
            end
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
      httpfetch(url.to_s,cache) # I guess we could remove this completely and just do it via mini_magick directly
     cache.sub(/\.[a-zA-Z]+$/, '_r.jpg').tap do |dest|
        imgsrc =  cache
        imgsrc.gsub!(/.gif/,'.gif[0]') # Make sure we don't expand the multiple frames of a gif, just grab the first frame
        image = MiniMagick::Image.open(imgsrc)
        image.combine_options do |b|
          b.resize '1072x>'
          b.colorspace 'Gray'
          #b.contrast
        end
        image.format 'JPEG'
        image.write(dest)
      end
    end

    def cache_path(url)
      cache_dir + '/' + Digest::SHA1.hexdigest(url.to_s) + (File.extname(url.path) || '.png')
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
