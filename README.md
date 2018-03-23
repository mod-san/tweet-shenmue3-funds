# Tweet Shenmue 3 Funds

This script scraps Shenmue 3's [website](https://shenmue.link/order), using [Nokogiri](https://github.com/sparklemotion/nokogiri) and open-uri, for funds data updates. It saves the data to a database, using PostgreSQL via [pg](https://github.com/ged/ruby-pg). It compares the data between the database and the website, and if new data is found, then it creates an image, using [blitline](https://github.com/blitline-dev/blitline) and an image [template](http://i.imgur.com/55r3Fuc.png) (as given with the ENV 'IMG_SRC'). It also creates the text to be tweeted on Twitter (specifically on @ShenmueLegacy), using [twitter](https://github.com/sferik/twitter). The text is tweeted together with the image ([example](https://twitter.com/ShenmueLegacy/status/960958859358736384)).

The code of this project is very expressive and easilly understandable (as self-documented code), using the associative data logic of hashes.

In our case, we are using Heroku to host this project.
***
## Dependencies

Gemfile:
```
# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

gem 'pg'
gem 'nokogiri'
gem 'blitline'
gem 'twitter'
```
***
The ENV references in the code, refer to environment variables.

### Environment Variables:

Database:
* DB_HOST
* DB_PORT
* DB_NAME
* DB_USER
* DB_PASSWORD
* DB_TABLE_NAME

Blitline:
* BLITLINE_APP_ID

Image:
* IMG_SRC

Twitter:
* CONSUMER_KEY
* CONSUMER_SECRET
* ACCESS_TOKEN
* ACCESS_TOKEN_SECRET

To run the script locally, you can use [dotenv](https://github.com/bkeepers/dotenv) to create a .env and set your own values for these environment variables. On Heroku, you can set those in the Settings->Config Variables.

***
### How to Run:

`ruby tweet_funds.rb`
