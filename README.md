[![Code Climate](https://codeclimate.com/github/outlyer/daily_digest/badges/gpa.svg)](https://codeclimate.com/github/outlyer/daily_digest)
[![Dependency Status](https://gemnasium.com/badges/github.com/outlyer/daily_digest.svg)](https://gemnasium.com/github.com/outlyer/daily_digest)


# Kindle Daily Digest

Generates Daily Digest from Pocket 

## Screenshot

![daily_digest_sample](https://cloud.githubusercontent.com/assets/1550429/17079840/347a2d6a-50ea-11e6-85f5-6d177daa707e.jpg)

## Prerequisite

* [Ruby](https://www.ruby-lang.org) >= 2.x
* [Bundler](http://bundler.io) >= 1.x
* [Mercury Web Parser API Key](https://mercury.postlight.com/web-parser/)
* [Pocket API Key and authorized token](http://getpocket.com/developer/docs/authentication)
* [Kindlegen](https://www.amazon.com/gp/feature.html?docId=1000765211)
* [ImageMagick](https://www.imagemagick.org/script/index.php) (Build with [librsvg](http://live.gnome.org/LibRsvg) for SVG support)

## Workflow

`rake deliver` will run the following tasks:

* Fetch unread items from [Pocket](http://getpocket.com)
* Parse content with [Mercury](https://mercury.postlight.com/web-parser/)
* Create table of contents and `.opf` file
* Create mobi file with Kindlegen

Depending on your configuration, `daily_digest` will deliver the generated MOBI file to your destination in either:

* Copy the mobi to an arbitrary folder called `DESTDIR` in your `.env` file for further processing
* Send the mobi file as an email attachment if SMTP server authentication is configured (see below)

You can let IFTTT watch `/Kindle` subfolder to send to your Kindle personal document free email address.

## How To

(On Mac, you'll need to configure `bundle` to use `/usr/local/bin` with: `bundle config --global system_bindir /usr/local/bin`)

```
bundle install
$EDITOR .env
bundle exec rake deliver
```

## Environment

You will have `.env` file that looks like:

```
POCKET_CONSUMER_KEY=1234-abcd
POCKET_ACCESS_TOKEN=a2aa5caa-c000-6ecb-b589-f7daea
MERCURY_API_KEY=2caeae6676796adada6967a5cddcd6a2292
CLEANUP=true
```

You have to manually authenticate against [Pocket OAuth endpoint](http://getpocket.com/developer/docs/authentication) to get the tokens. I used [Pocket-CLI](https://github.com/rakanalh/pocket-cli) but you can use `curl` if you want to avoid the dependency. 

If you want to directly send email to your Kindle Personal Document, you'll need the following environment variables as well:

```
KINDLE_MAILTO=YOU@free.kindle.com
KINDLE_MAILFROM=you@example.com
SMTP_SERVER=smtp.example.com:587
SMTP_USERNAME=you@example.com
SMTP_PASSWORD=43829f4cchRRY8
```

If you want to use Gmail to send the mail, you'll probably need an App Password which you can get from [Google Security | App Passwords](https://security.google.com/settings/security/apppasswords)

## Changes from original/upstream project [miyagawa/daily_digest](https://github.com/miyagawa/daily_digest)

* Removed dependency on Calibre and ImageMagick
* Added generated table of contents, cover image, `opf` "manifest"
* Added note about dependency on ImageMagick (also in upstream, but not mentioned)
* Removed dependency on Readability (defunct) and switched to Mercury Web Parser

## Copyright

Tatsuhiko Miyagawa, Aubin Paul

## License

This software is licensed under the MIT License.
