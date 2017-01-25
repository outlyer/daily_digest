require 'uri'
require 'mercury_parser'
require 'dotenv'
require 'json'

module DailyDigest
  class Reader
    include Client
    include MercuryParser

    attr_reader :token
    Dotenv.load

    def initialize(token)
      @token = token
      MercuryParser.api_key = token
    end

    def get(url, item_id)
      Article.new(MercuryParser.parse(url), item_id)
    end

    class Article
      attr_accessor :rendered_content
      @@item_id = 0

      def initialize(data, pocket_item_id)
        @data = data
        @@item_id = pocket_item_id
      end

      def valid?
        title && content
      end

      def item_id
        @@item_id
      end

      def archive_item
        archive_command = JSON.generate({ :action =>'archive', :item_id => @@item_id })
        archive_url = URI.escape("[#{archive_command}]").gsub("[","%5B").gsub("]","%5D").gsub(',','%2C').gsub(':','%3A')
        archive_link = "https://getpocket.com/v3/send?actions=#{archive_url}&access_token=#{ENV['POCKET_ACCESS_TOKEN']}&consumer_key=#{ENV['POCKET_CONSUMER_KEY']}"
        archive_link
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
