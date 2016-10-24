$:.push File.expand_path("../lib", __FILE__)
require 'dotenv'
require 'daily_digest'
require 'tempfile'
require 'pathname'
require 'fileutils'

Dotenv.load

task :deliver do
  puts "🌎  Getting unread items from Pocket"
  pocket = DailyDigest::Pocket.new(ENV['POCKET_ACCESS_TOKEN'], ENV['POCKET_CONSUMER_KEY'], ENV['POCKET_FAVORITES'])
  items = pocket.list

  puts "📰  Parsing items with Readability"
  reader = DailyDigest::Reader.new(ENV['READABILITY_PARSER_KEY'])
  articles = items.map { |item|
    print "     Parsing #{item.title}" + "                                                            " + "\r"
    reader.get(item.url)
  }.select(&:valid?)
  print "\n"

  basename = "dailydigest-#{Time.now.strftime('%Y%m%d%H%M')}"
  tempfile = basename + ".html"
  opffile = basename + ".opf"
  tocfile = basename + "toc.html"
  mobi = basename + ".mobi"

  puts "📖  Generating TOC"
  tocwrite = DailyDigest::TOCWrite.new
  tocwrite.render(articles, tocfile)

  puts "📖  Generating OPF Index file"
  opfwrite = DailyDigest::OPFWrite.new
  opfwrite.render(tempfile,opffile)

  puts "📚  Rendering pages in HTML"
  kindlegen = DailyDigest::Kindlegen.new
  kindlegen.render(articles, tempfile)

  puts "📘  Converting rendered pages to Mobi with Kindlegen"
  kindlegen.convert(opffile, mobi)

  puts "🗑  Cleaning up temporary files"
  #File.delete(tempfile)
  File.delete(tocfile)
  File.delete(opffile)

  puts "📘  Generated #{mobi} (#{File.size(mobi)} bytes)"

  if ENV['KINDLE_MAILTO']
    puts "✉️    Sending #{mobi} to Kindle Personal Document"
    delivery = DailyDigest::Delivery.new
    delivery.deliver(mobi)
  end

  outbox = ENV['DESTDIR']
  if ENV['DESTDIR'] and File.exists?(outbox)
    puts "🚚  Moving #{mobi} to your destination directory"
    FileUtils.move(mobi, outbox)
  end
end

