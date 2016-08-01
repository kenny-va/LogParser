def check_duplicate(duplicate_array, duplicate_count, testname)

	is_duplicate = false

	puts "Duplicate array count #{duplicate_count}"

	for idx in 0 .. duplicate_count
		unless is_duplicate
			puts "idx=#{idx}, Compare *#{duplicate_array[idx]}*"
			puts "*#{testname}*"
			
			if duplicate_array[idx] == testname
				is_duplicate = true
				puts "DUPLICATE WAS FOUND"
			end
		end
	end

	return is_duplicate

end
