def biz_validate(biz, testname, field, value)

	puts "Validating property value"

	puts "Testname: " + testname
	puts "Field: " + field
	puts "Value: " + value

is_valid = true

	for i in 0..1
		unless !is_valid
			is_valid = true
			puts "Comparing test " + biz[i,0,0].upcase + " to " + testname.upcase
			if biz[i,0,0].upcase == testname.upcase   #Is the testname the same?
				for j in 0..2				
					unless biz[i,j,0].nil? or !is_valid
						puts "Comparing field " + biz[i,j,0].upcase + " to " + field
						if biz[i,j,0].upcase == field   # Is the field name the same?
							unless biz[i,j,0].nil? or !is_valid
								is_valid = false
								puts "Defaulting is_valid to false"
								if biz[i,j,1].include? ("|" + value + "|")
									is_valid = true
									puts "Setting is_valid to true (1)"
								elsif biz[i,j,1].include? "|NOTNULL|" and biz[i,j,1].length > 0
									is_valid = true
									puts "Setting is_valid to true (2)"
								end
							end
						end
					end
				end
			end
		end
	end

	# puts "Field valid (" + biz[i,1,0] + "): " + is_valid
	puts is_valid

	return is_valid

end