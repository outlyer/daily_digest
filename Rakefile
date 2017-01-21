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

  maxlength = 0
  puts "📰  Parsing items with Mercury Web Parser"
  reader = DailyDigest::Reader.new(ENV['MERCURY_API_KEY'])
  articles = items.map { |item|
    if item.title.length > maxlength
      maxlength = item.title.length
    end
    padding = " " * (maxlength-14)
    print "     Parsing #{item.title}" + padding + "\r"
    reader.get(item.url)
  }.select(&:valid?)
  print "\n"

  basename = "dailydigest-#{Time.now.strftime('%Y%m%d')}"
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

  print "\n"
  puts "📚  Rendering pages in HTML"
  mobigen = DailyDigest::Mobigen.new
  mobigen.render(articles, tempfile)

  puts "📘  Converting rendered pages to Mobi with Kindlegen"
  mobigen.convert(opffile, mobi)


  if ENV['CLEANUP']
    puts "🗑  Cleaning up temporary files"
    File.delete(tempfile)
    File.delete(tocfile)
    File.delete(opffile)
  end

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

