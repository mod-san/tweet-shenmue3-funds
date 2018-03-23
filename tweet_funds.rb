require 'pg'
require 'open-uri'
require 'nokogiri'
require 'date'
require 'time'
require 'blitline'
require 'twitter'
require_relative 'lib/deep_dup'
require_relative 'lib/ext_classes_methods'

#ACTION: Get data from the database.

connection = PGconn.connect(
	:host 		=> ENV['DB_HOST'],
	:port 		=> ENV['DB_PORT'],
	:dbname 	=> ENV['DB_NAME'],
	:user 		=> ENV['DB_USER'],
	:password => ENV['DB_PASSWORD']
)
table_name = ENV['DB_TABLE_NAME']

data_from = {:database => {}, :website => {} }
data_from_database = data_from[:database]
data_from_website = data_from[:website]

rows = connection.exec("SELECT * FROM #{table_name} ORDER BY date_and_time_as_int_id DESC LIMIT 1")
fields = rows.fields
rows.each {|row|
	fields.each {|field|
		data_from_database[field.to_sym] = row[field]
	}
}

#ACTION: Database's data's elements formation.

elements_symbols = [:date_and_time_as_int_id, :money_amount, :backers_number]
elements_symbols.each {|element_symbol|
	data_from_database[element_symbol] = data_from_database[element_symbol].to_i
}

#ACTION: Get data from the website.

shenmue3_url = 'https://shenmue.link/order'
html_file = open(shenmue3_url)
html_doc = Nokogiri::HTML(html_file)

key_by_index = {
	0 => :money_amount,
	1 => :backers_number,
	2 => :date_phrase
}

html_doc.css('dd, .date').each_with_index {|element, index|
  data_from_website[key_by_index[index]] = element.text
}

#ACTION: Website's data's elements formation.

non_digit_regex = /\D/
empty_string = ''
elements_symbols.shift; stats_symbols = elements_symbols
stats_symbols.each {|stat_symbol|
	data_from_website[stat_symbol] = data_from_website[stat_symbol].gsub!(non_digit_regex, empty_string).to_i
}

date_phrase = data_from_website[:date_phrase]
parsed_date = Date.parse(date_phrase)
parsed_time = Time.parse(date_phrase)

form_string = '%02d'

year = parsed_date.year
month = parsed_date.month; formed_month = form_string % month
day = parsed_date.day; formed_day = form_string % day
hour = parsed_time.hour; formed_hour = form_string % hour
min = parsed_time.min; formed_min = form_string % min

data_from_website[:date_and_time_as_int_id] =
	"#{year}#{formed_month}#{formed_day}#{formed_hour}#{formed_min}".to_i
data_from_website[:date] =
	"#{year}/#{formed_month}/#{day}"

#ACTION: Check if website's data has been updated. If not, then exit (else continue).

exit if data_from_website[:date_and_time_as_int_id] == data_from_database[:date_and_time_as_int_id]

#ACTION: Insert website's data in the database.

connection.prepare(
	'statement',
	"INSERT INTO #{table_name} (date_and_time_as_int_id, money_amount, backers_number, date) VALUES ($1, $2, $3, $4)"
)

connection.exec_prepared(
	'statement',
	[
		data_from_website[:date_and_time_as_int_id],
		data_from_website[:money_amount],
		data_from_website[:backers_number],
		data_from_website[:date]
	]
)

#ACTION: 	Calculate the differences between stats of the database and of the website.
# 				Also, the difference between dates, that is, how many days have passed.

difference_on = {}
sign_char_of_difference_on = {}
stats_symbols.each {|stat_symbol|
	difference_on[stat_symbol] = data_from_website[stat_symbol] - data_from_database[stat_symbol]
	sign_char_of_difference_on[stat_symbol] = difference_on[stat_symbol].sign_char
	difference_on[stat_symbol] = difference_on[stat_symbol].abs
}
difference_on[:date] = Date.parse(data_from_website[:date]).mjd - Date.parse(data_from_database[:date]).mjd

#ACTION: Create delimited strings (with commas every 3 digits) of the respective numbers.

elements_symbols.push(:date)
delimited_stat_from = {}
[:database, :website].each {|source_symbol|
	delimited_stat_from[source_symbol] = {}
	elements_symbols.each {|element_symbol|
		delimited_stat_from[source_symbol][element_symbol] = delimited_by_number( data_from[source_symbol][element_symbol])
	}
}
delimited_stat_from_database = delimited_stat_from[:database]
delimited_stat_from_website = delimited_stat_from[:website]

delimited_difference_on = {}
elements_symbols.each {|element_symbol|
	delimited_difference_on[element_symbol] = delimited_by_number( difference_on[element_symbol])
}

#ACTION: Create an image, based on an image prototype and the previously calculated values.

arrow1_char = '►'
fast_forward_char = '»'

date_text = "#{data_from_database[:date]} #{arrow1_char} #{data_from_website[:date]} (#{fast_forward_char}#{delimited_difference_on[:date]})"

money_amount_text =
	"$#{delimited_stat_from_database[:money_amount]} #{arrow1_char} $#{delimited_stat_from_website[:money_amount]} (#{sign_char_of_difference_on[:money_amount]}$#{delimited_difference_on[:money_amount]})"

money_per_backer = difference_on[:money_amount]/difference_on[:backers_number]
sign_char_of_money_per_backer = money_per_backer.sign_char
money_per_backer = money_per_backer.abs
delimited_money_per_backer = delimited_by_number(money_per_backer)

backers_number_text = 
	"#{delimited_stat_from_database[:backers_number]} #{arrow1_char} #{delimited_stat_from_website[:backers_number]} (#{sign_char_of_difference_on[:backers_number]}#{delimited_difference_on[:backers_number]}) backers (#{sign_char_of_money_per_backer}$#{delimited_money_per_backer}/backer)"

functions_word = 'functions'
name_word = 'name'
annotate_word = 'annotate'
params_word = 'params'
text_word = 'text'
color_word = 'color'
point_size_phrase = 'point_size'
x_word = 'x'
y_word = 'y'
gravity_word = 'gravity'
dropshadow_color_phrase = 'dropshadow_color'
dropshadow_offset_phrase = 'dropshadow_offset'
font_family_phrase = 'font_family'

text_colour = '#434343'
text_gravity = 'NorthGravity'
text_font = 'Work Sans'
dropshadow_colour = '#e5e5e5'

functions_data = [{
	name_word => annotate_word,
	params_word => {
		text_word => nil,
		color_word => text_colour,
		point_size_phrase => nil,
		x_word => 0,
		y_word => nil,
		gravity_word => text_gravity,
		dropshadow_color_phrase => dropshadow_colour,
		dropshadow_offset_phrase => 2,
		font_family_phrase => text_font
	}
}]

functions_data_for_date = functions_data
functions_hash_for_date = functions_data_for_date[0]
params = functions_hash_for_date[params_word]
params[text_word] = date_text
params[point_size_phrase] = '16'
params[y_word] = 71

functions_data_for_money_amount = functions_data_for_date.deep_dup
functions_hash_for_money_amount = functions_data_for_money_amount[0]
params = functions_hash_for_money_amount[params_word]
params[text_word] = money_amount_text
params[point_size_phrase] = '20'
params[y_word] = 112
functions_hash_for_date[functions_word] = functions_data_for_money_amount

functions_data_for_backers_number = functions_data_for_money_amount.deep_dup
functions_hash_for_backers_number = functions_data_for_backers_number[0]
params = functions_hash_for_backers_number[params_word]
params[text_word] = backers_number_text
params[point_size_phrase] = '14'
params[y_word] = 160
functions_hash_for_backers_number['save'] = {
	'image_identifier' => 'shenmue3_img_data',
	'quality' => 100,
	'extension' => '.png'
}
functions_hash_for_money_amount[functions_word] = functions_data_for_backers_number

job_hash = {
  'application_id' 	=> ENV['BLITLINE_APP_ID'],
  'src' 						=> ENV['IMG_SRC'],
  functions_word => functions_data
}

img_url = nil
begin
	blitline_service = Blitline.new
	blitline_service.add_job_via_hash(job_hash)
	json_hash = blitline_service.post_job_and_wait_for_poll

	img_url = json_hash['images'][0]['s3_url'] unless json_hash.key?('error')
	puts json_hash['error']
rescue
	puts 'Blitline service fails.'
end
img_file = img_url.nil? ? img_url : open(img_url)

#ACTION: Create a text to be sent as a tweet.

client = Twitter::REST::Client.new do |config|
  config.consumer_key 				= ENV['CONSUMER_KEY']
  config.consumer_secret 			= ENV['CONSUMER_SECRET']
  config.access_token 				= ENV['ACCESS_TOKEN']
  config.access_token_secret 	= ENV['ACCESS_TOKEN_SECRET']
end

arrow2_char = '➡'
calendar_icon_char_code = '🗓'
pouch_icon_char_code = '💰'
duck_icon_char_code = '🦆'
hashtag = '#Shenmue3'

[date_text, money_amount_text, backers_number_text].each {|text|
	text.gsub!(arrow1_char, arrow2_char)
}
backers_number_text.gsub!(/\s{1}backers/, empty_string).gsub!(/backer/, duck_icon_char_code)

tweet_prim_text =
"#{calendar_icon_char_code} #{date_text}
#{pouch_icon_char_code} #{money_amount_text}
#{duck_icon_char_code} #{backers_number_text}
#{hashtag}"
tweet_prim_text_size = tweet_prim_text.size

shenmue3_url.gsub!(/https:\/\//, empty_string)

tweet_scnd_text =
"#{calendar_icon_char_code} #{data_from_website[:date]} (#{fast_forward_char}#{delimited_difference_on[:date]})
#{pouch_icon_char_code} $#{delimited_stat_from_website[:money_amount]} (#{sign_char_of_difference_on[:money_amount]}$#{delimited_difference_on[:money_amount]})
#{duck_icon_char_code} $#{delimited_stat_from_website[:backers_number]} (#{sign_char_of_difference_on[:backers_number]}#{delimited_difference_on[:backers_number]})
#{hashtag} #{shenmue3_url}"
tweet_scnd_text_size = tweet_scnd_text.size

tweet_text, img_file = 
	if tweet_prim_text_size > 140
		if tweet_scnd_text_size > 117 then ["#{hashtag} #{shenmue3_url}", img_file]
		elsif tweet_scnd_text_size > 93 then [tweet_scnd_text, nil]
		else
			[tweet_scnd_text, img_file]
		end
	elsif tweet_prim_text_size > 116 then [tweet_prim_text, nil]
	else
		[tweet_prim_text, img_file]
	end
# max text size:
# 140	: (w/o an img &/or a url)
# 117	: w/ a url (& w/o an img)
# 93	: w/ a url & an img
# 116	: w/ an img (& w/o a url) 

case img_file
when nil
	client.update(tweet_text)
else
	client.update_with_media(tweet_text, img_file)
end
