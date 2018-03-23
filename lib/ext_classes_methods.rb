def delimited_by_number(number)
	parts = number.to_s.split('.')
	parts[0].gsub!(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1,")
	parts.join('.')
end

class Numeric
	@@signs = '++-'
	def sign
		self <=> 0
	end
	def sign_char
		@@signs[sign]
	end
end