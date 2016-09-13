def biz_validate(biz, testname, field, value)

	#puts "============================================================"
	#puts "Validating Testname: " + testname.upcase + "  Field: " + field + "  Value: " + value

	is_valid = true
	null_check = true
	field_checked = false

	i=0
	while !biz[i,0,0].nil? and !field_checked
	
		if biz[i,0,0].upcase == testname.upcase   #Is the testname the same?
			#puts "Inside testing: " + testname.upcase
			
			j=1
			while !biz[i,j,0].nil? and !field_checked
				
				#puts "Comparing field " + biz[i,j,0].upcase + " to " + field
				if biz[i,j,0].upcase == field   # Is the field name the same?
					unless biz[i,j,0].nil? or field_checked

						is_valid = false
						#puts "Inside field: " + field

						if biz[i,j,1].include? "|NOTNULL|" 
							if value.length > 0  #Check for a null value if value is "not nullable"
								null_check = true
								#puts "Null check passed"
							else
								null_check = false
								#puts "Null check failed"
							end
						else
							null_check = true
							#puts "Null check passed - no validation"
						end

						if biz[i,j,1] != "|NOTNULL|" #If there is a set of values we need to test against
							#puts "Checking for specific value for: " + biz[i,j,0]
							if biz[i,j,1].include? ("|" + value + "|")
								is_valid = true
								#puts "Specific value passed"
							else
								is_valid = false
								#puts "Specific value fails: " + value
							end
						else
							is_valid = true
						end

						field_checked = true

					end
				end
				
				j=j+1
			end
		end
		
		i=i+1
	end

	return (is_valid and null_check)

end