require 'uri'
require 'mercury_parser'

module DailyDigest
  class Reader
    include Client
    include MercuryParser

    attr_reader :token

    def initialize(token)
      @token = token
      MercuryParser.api_key = token
    end

    def get(url)
      Article.new(MercuryParser.parse(url))
    end

    class Article
      attr_accessor :rendered_content

      def initialize(data)
        @data = data
      end

      def valid?
        title && content
      end

      def title
        @data['title']
      end

      def domain
        @data['domain']
      end

      def lead_image_url
        @data['lead_image_url']
      end

      def url
        @data['url']
      end

      def author
        @data['author']
      end

      def content
        @data['content']
      end

      def date
        Time.parse(@data['date_published'])
      end
    end
  end
end
