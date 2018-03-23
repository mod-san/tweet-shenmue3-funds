# Tweet Shenmue 3 Funds

This script scraps Shenmue 3's [website](https://shenmue.link/order), using [Nokogiri](https://github.com/sparklemotion/nokogiri) and open-uri, for funds data updates. It saves the data to a database, using PostgreSQL via [pg](https://github.com/ged/ruby-pg). It compares the data between the database and the website, and if new data is found, then it creates an image, using [blitline](https://github.com/blitline-dev/blitline) and an image template (as given with the ENV 'IMG_SRC'). It also creates the text to be tweeted on Twitter (specifically on @ShenmueLegacy), using [twitter](https://github.com/sferik/twitter). The text is tweeted together with the image ([example](https://twitter.com/ShenmueLegacy/status/960958859358736384)).

This is hosted on Heroku.

The ENV references in the code, refer to environment variables.

### List of environment variables

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

On Heroku, you can set those in the settings.
