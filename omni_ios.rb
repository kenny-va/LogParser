require 'uri'
require "./mobile-automation-values.rb"
#require "pry"

#TO DO'S

#This means your script should also look for this
#Log.d("OMNITURE_TEST", "---SAVED ARTICLES FUNCTIONALITY IS NOT TOGGLED ON---");

if ARGV[0].nil?
    filename = "./data-ios/ios-omniture2.txt"
else
    filename = ARGV[0]
end
puts "Filename: " + filename

content_type_passing_test = 0
content_type_failing_test = 0
content_type_passes = "<p>"    #Holds test names which pass the content type test
content_type_errors = "<p>"  # store the cumulative error list for content types

action_passing_test = 0
action_failing_test = 0
action_passes = "<p>"    #Holds test names which pass the content type test
action_errors = "<p>"  # store the cumulative error list for content types

article_style = "style='font-weight: bold;font-size: xx-large; background-color:yellow'"
business_rule_style = "style='font-weight: bold;font-size: xx-large; background-color:silver'"
ad_style = "style='font-weight: bold;font-size: xx-large; background-color:orange;'"
product_name_style = "style='font-weight: bold;font-size: xx-large; background-color:green'"
gnt_style = "style='background-color: lightblue; '"
omni_style = "style='background-color: PaleGoldenRod; '"

id = 1 #rolling id # to make unique api call divs
product_name = ""  #Product being tested
current_test = ""
ad_parms = ""

module_cnt = 0  #track the number of API calls for display purposes per test
in_test = true #tracks if we are currently within a test when parsing the log

ad_data = Array.new(1000) { Array.new(5) }   #array for ad calls.  1000 is upper bound.
ad_index = 0  #counter for ad call array

#omni_data = Array.new(1000, Array.new(200, Array.new(2))) 
omni_data = My3Array.new
omni_testname = Array.new(100,"")  #Stores the name of the automated test
omni_url = Array.new(100,"")

omni_index = 0  #counter for omniture calls
omni_row = 0 #counter for # of parameters per omniture call

#Create and open HTML file for output
html_filename = filename.slice(0,filename.rindex(".")) + ".html"
hf = File.open(html_filename, "w")

hf.write("<script type='text/javascript'>")
hf.write("   function ReverseDisplay(id) {")
hf.write("       var e = document.getElementById(id);")
hf.write("      if(e.style.display == 'block')")
hf.write("          e.style.display = 'none';")
hf.write("       else")
hf.write("          e.style.display = 'block';")
hf.write("    }") 
hf.write("</script><br><br>")

hf.write("<script src='sorttable.js'></script>")

#Build the html table casing
hf.write("<html><body>")
hf.write("<a name='top_of_page'></a>")

hf.write("<style>");
hf.write(".odd{background-color: white;} ");
hf.write(".even{background-color: silver;} ");
hf.write("</style>");

File.open(filename) do |file|       #LOOP THROUGH THE FILE TO PROCESS SPECIFIC LINES
 
    file.each do |line|

        if line.include? "---TESTNAME:"

            #Get test name
            j = line.index("---TESTNAME:")  

            # This will strip off the text prior to and after the TEST NAME
            omni_testname[omni_index] = line.slice(j+12,line.length-(j+12+4))

            in_test = true
            module_cnt = 0

            puts "Start of " + omni_testname[omni_index]
        
        
        elsif line.include? "END_OF_TEST"
            in_test = false
            puts "End of test"

#        elsif line.include? "THE_PRODUCT_NAME_IS:"
#
#            product_name = line.slice(line.index("THE_PRODUCT_NAME_IS")+20,line.length)
#            product_name = product_name.slice(0,product_name.length-5)
        

        elsif line.include? "THE_PRODUCT_NAME_IS"

            product_name = line.slice(line.index("THE_PRODUCT_NAME_IS") + 20,line.length)
            puts "Product name is: #{product_name}"


        elsif line.include? "Ads: Params:"     
            ad_parms = line.slice(32,line.length)   
            #puts "AD_Parms located: #{ad_parms}"

        elsif line.include? "/gampad/"
        
            puts "Ad_Request: #{line}"
            ad_values = line.split("&")

            
            ad_values.each do |value|
                puts "Value comparing: " + value
                if value.start_with? ("iu") 
                    puts "found the &iu parameter"
                    ad_data[ad_index][0] = URI.decode(value.slice(value.index("iu=")+3,value.length))
                    puts "AD Data stored: " + ad_data[ad_index][0]
                 
                elsif value.start_with? ("sz") 
                    puts "found the &sz parameter"
                    ad_data[ad_index][1] = URI.decode(value.slice(value.index("sz=")+3,value.length))
                    puts "AD Data stored: " + ad_data[ad_index][1]
                end                
            end
            
            #puts "Added ad_parms to ad_data: #{ad_data[ad_index][4]}"
            #ad_parms = ""   #Clear out the ad_parms to ensure we don't duplicate if not found in the log

            ad_index = ad_index + 1
            puts "Ads found thus far: #{ad_index}"

        elsif line.include? "gannett.demdex.net" and in_test
     
            omni_call = URI.decode(line.slice(line.index("gannett.demdex.net/event?"),line.length))
            omni_url[omni_index] = omni_call.slice(0,omni_call.length-2)
            puts "Omni_call: #{omni_url[omni_index]}"

            omni_call = omni_call.slice(omni_call.index("?")+1,omni_call.length)  #Strip off the domain and API call, leaving just the parameters
            omni_call = omni_call.slice(0,omni_call.length-3)  #strip off last )
           
            prefix_cnt = 0
            prefixes = ["","","","","",""] #this array holds the prefixes, ie: c.a.DeviceName
            omni_row = 0
            omni_values = omni_call.split("&").sort  #Split all the URL parameters
            
            omni_values.each do |value|           

                param = value.split("=")
                col = 1
                param.each do |p_value|
                    
                    if p_value.slice(-1,1) == "." #we have a prefix
                        prefixes[prefix_cnt] = p_value
                        prefix_cnt = prefix_cnt + 1

                    elsif p_value.slice(0,1) == "."  #we have a suffix
                        prefixes[prefix_cnt-1] = ""
                        prefix_cnt = prefix_cnt - 1
                        
                    elsif col == 1   #Parameter name
                        #hf.write("<tr " + omni_style + "><td>"+prefixes[0]+prefixes[1]+prefixes[2]+prefixes[4]+prefixes[5]+p_value+"</td>")
                        col = 2
                        omni_data[omni_index,omni_row,0] = prefixes[0]+prefixes[1]+prefixes[2]+prefixes[4]+prefixes[5]+p_value.upcase        

                    elsif col==2  #Parameter value
                        
                        col = 1 

                        omni_data[omni_index,omni_row,1] = p_value.upcase
                        omni_row = omni_row + 1
                    end                    
                end
                               
            end
            omni_index = omni_index + 1

            hf.write("</table>")  

        end

    end #each file record

end #open file

###################################################################################
# AT THIS POINT ALL DATA HAS BEEN STORED.  NOW RUN THROUGH THE BUSINESS VALIDATION.
###################################################################################

=begin

current_test = ""
tmp_idx = 0
puts "Running through #{omni_index} calls"
for x in 0..omni_index
    #puts "Looping on index #{x} with testname: #{omni_testname[x]} "

    if omni_testname[x].length > 0
        current_test = omni_testname[x]
        #puts "#{current_test} Checking parameters "
    end

    if current_test.length > 3  #just make sure the current_test variable is set
        for y in 0..100 do
            #puts "Checking parameter #{omni_data[x,y,0]} value #{omni_data[x,y,1]}"
            if omni_data[x,y,0].nil?    #This means we've run out of parameters for the given URL
                break
            elsif omni_data[x,y,0] == "CONTENTTYPE"
                
                case current_test
                when "LAUNCHAPP"
                    if omni_data[x,y,1] == CONTENT_TYPE[LAUNCHAPP_CONST]
                        content_type_passing_test = content_type_passing_test + 1
                        content_type_passes = content_type_passes + current_test + "<br>"
                    else
                        content_type_failing_test = content_type_failing_test + 1
                        content_type_errors = content_type_errors + current_test + " Content_Type Error: Value: " + omni_data[x,y,1] + " Should be: " + CONTENT_TYPE[LAUNCHAPP_CONST] + " <br>"
                    end
                when "ARTICLETAP"
                    if omni_data[x,y,1] == CONTENT_TYPE[ARTICLE_TAP_CONST]
                        content_type_passing_test = content_type_passing_test + 1
                        content_type_passes = content_type_passes + current_test + "<br>"
                    else
                        content_type_failing_test = content_type_failing_test + 1
                        content_type_errors = content_type_errors + current_test + " Content_Type Error: Value: " + omni_data[x,y,1] + " Should be: " + CONTENT_TYPE[ARTICLE_TAP_CONST] + " <br>"
                    end
                when "ARTICLESWIPE/NEXT", "ARTICLESWIPE/PREV"
                    if omni_data[x,y,1] == CONTENT_TYPE[ARTICLESWIPE_CONST]
                        content_type_passing_test = content_type_passing_test + 1
                        content_type_passes = content_type_passes + current_test + "<br>"
                    else
                        content_type_failing_test = content_type_failing_test + 1
                        content_type_errors = content_type_errors + current_test + " Content_Type Error: Value: " + omni_data[x,y,1] + " Should be: " + CONTENT_TYPE[ARTICLESWIPE_CONST] + " <br>"
                    end                                 
                when "SAVEDARTICLE_LANDSCAPE", "SAVEDARTICLE_PORTRAIT"
                    if omni_data[x,y,1] == CONTENT_TYPE[SAVED_ARTICLE_CONST]
                        content_type_passing_test = content_type_passing_test + 1
                        content_type_passes = content_type_passes + current_test + "<br>"
                    else
                        content_type_failing_test = content_type_failing_test + 1
                        content_type_errors = content_type_errors + current_test + " Content_Type Error: Value: " + omni_data[x,y,1] + " Should be: " + CONTENT_TYPE[SAVED_ARTICLE_CONST] + " <br>"
                    end                                        
                when "REFRESHCONTENT"
                    if omni_data[x,y,1] == CONTENT_TYPE[REFRESH_CONTENT_CONST]
                        content_type_passing_test = content_type_passing_test + 1
                        content_type_passes = content_type_passes + current_test + "<br>"
                    else
                        content_type_failing_test = content_type_failing_test + 1
                        content_type_errors = content_type_errors + current_test + " Content_Type Error: Value: " + omni_data[x,y,1] + " Should be: " + CONTENT_TYPE[REFRESH_CONTENT_CONST] + " <br>"
                    end    
                when "BREAKINGNEWSALERTON", "BREAKINGNEWSALERTOFF"
                    if omni_data[x,y,1] == CONTENT_TYPE[BREAKING_NEWS_ALERT_CONST]
                        content_type_passing_test = content_type_passing_test + 1
                        content_type_passes = content_type_passes + current_test + "<br>"
                    else
                        content_type_failing_test = content_type_failing_test + 1
                        content_type_errors = content_type_errors + current_test + " Content_Type Error: Value: " + omni_data[x,y,1] + " Should be: " + CONTENT_TYPE[BREAKING_NEWS_ALERT_CONST] + " <br>"
                    end   
                when "MENUTAP" 
                    if omni_data[x,y,1] == CONTENT_TYPE[MENU_TAP_CONST]
                        content_type_passing_test = content_type_passing_test + 1
                        content_type_passes = content_type_passes + current_test + "<br>"
                    else
                        content_type_failing_test = content_type_failing_test + 1
                        content_type_errors = content_type_errors + current_test + " Content_Type Error: Value: " + omni_data[x,y,1] + " Should be: " + CONTENT_TYPE[MENU_TAP_CONST] + " <br>"
                    end   
                when "WEATHERLOCATIONS" 
                    if omni_data[x,y,1] == CONTENT_TYPE[WEATHER_LOCATIONS_CONST]
                        content_type_passing_test = content_type_passing_test + 1
                        content_type_passes = content_type_passes + current_test + "<br>"
                    else
                        content_type_failing_test = content_type_failing_test + 1
                        content_type_errors = content_type_errors + current_test + " Content_Type Error: Value: " + omni_data[x,y,1] + " Should be: " + CONTENT_TYPE[WEATHER_LOCATIONS_CONST] + " <br>"
                    end  
                when "ARTICLELINK/GALLERY" 
                    if omni_data[x,y,1] == CONTENT_TYPE[ARTICLE_LINK_GALLERY_CONST]
                        content_type_passing_test = content_type_passing_test + 1
                        content_type_passes = content_type_passes + current_test + "<br>"
                    else
                        content_type_failing_test = content_type_failing_test + 1
                        content_type_errors = content_type_errors + current_test + " Content_Type Error: Value: " + omni_data[x,y,1] + " Should be: " + CONTENT_TYPE[ARTICLE_LINK_GALLERY_CONST] + " <br>"
                    end  
                when "ARTICLELINK/VIDEO" 
                    if omni_data[x,y,1] == CONTENT_TYPE[ARTICLE_LINK_VIDEO_CONST]
                        content_type_passing_test = content_type_passing_test + 1
                        content_type_passes = content_type_passes + current_test + "<br>"
                    else
                        content_type_failing_test = content_type_failing_test + 1
                        content_type_errors = content_type_errors + current_test + " Content_Type Error: Value: " + omni_data[x,y,1] + " Should be: " + CONTENT_TYPE[ARTICLE_LINK_VIDEO_CONST] + " <br>"
                    end  
                when "SETTINGS/ACCOUNTMANAGEMENT"
                    if omni_data[x,y,1] == CONTENT_TYPE[SETTINGS_ACCT_MGT_CONST]
                        content_type_passing_test = content_type_passing_test + 1
                        content_type_passes = content_type_passes + current_test + "<br>"
                    else
                        content_type_failing_test = content_type_failing_test + 1
                        content_type_errors = content_type_errors + current_test + " Content_Type Error: Value: " + omni_data[x,y,1] + " Should be: " + CONTENT_TYPE[SETTINGS_ACCT_MGT_CONST] + " <br>"
                    end                      
                else
                    puts "Test name #{current_test}"
                    hf.write("Invalid 'Content Type' test name found: #{current_test}<br>")
                end
            
            elsif omni_data[x,y,0] == "ACTION" and omni_data[x,y,1] != "HOUSEADIMPRESSION"     #IGNORE AD IMPRESSIONS ACTIONS
               
                case current_test           
                when "ARTICLESWIPE/NEXT"
                    if omni_data[x,y,1] == "ARTICLESWIPE|NEXT"
                        action_passing_test = action_passing_test + 1
                        action_passes = action_passes + current_test + "<br>"
                    else
                        action_failing_test = action_failing_test + 1
                        action_errors = action_errors + current_test + " Action Error: Value: " + omni_data[x,y,1] + " Should be: ARTICLESWIPE|NEXT<br>"
                    end  
                when "ARTICLESWIPE/PREV"
                    if omni_data[x,y,1] == "ARTICLESWIPE|PREVIOUS"
                        action_passing_test = action_passing_test + 1
                        action_passes = action_passes + current_test + "<br>"
                    else
                        action_failing_test = action_failing_test + 1
                        action_errors = action_errors + current_test + " Action Error: Value: " + omni_data[x,y,1] + " Should be: ARTICLESWIPE|PREVIOUS<br>"
                    end                                                                      
                when "REFRESHCONTENT"
                    if omni_data[x,y,1] == "REFRESHCONTENT"
                        action_passing_test = action_passing_test + 1
                        action_passes = action_passes + current_test + "<br>"
                    else
                        action_failing_test = action_failing_test + 1
                        action_errors = action_errors + current_test + " Action Error: Value: " + omni_data[x,y,1] + " Should be: REFRESHCONTENT<br>"
                    end    
                when "BREAKINGNEWSALERTON"
                    if omni_data[x,y,1] == "ALERTS|BN|OFF"
                        action_passing_test = action_passing_test + 1
                        action_passes = action_passes + current_test + "<br>"
                    else
                        action_failing_test = action_failing_test + 1
                        action_errors = action_errors + current_test + " Action Error: Value: " + omni_data[x,y,1] + " Should be: ALERTS|BN|OFF<br>"
                    end  
                when "BREAKINGNEWSALERTOFF"
                    if omni_data[x,y,1] == "ALERTS|BN|ON"
                        action_passing_test = action_passing_test + 1
                        action_passes = action_passes + current_test + "<br>"
                    else
                        action_failing_test = action_failing_test + 1
                        action_errors = action_errors + current_test + " Action Error: Value: " + omni_data[x,y,1] + " Should be: ALERTS|BN|ON<br>"
                    end  

                when "MENUTAP" 
                    if omni_data[x,y,1].include? "NAVMENU"
                        action_passing_test = action_passing_test + 1
                        action_passes = action_passes + current_test + "<br>"
                    else
                        action_failing_test = action_failing_test + 1
                        action_errors = action_errors + current_test + " Action Error: Value: " + omni_data[x,y,1] + " Should be like : NAVMENU*<br>"
                    end  

                when "WEATHERLOCATIONS" 
                    if omni_data[x,y,1] == "NAVMENU|WEATHER"
                        action_passing_test = action_passing_test + 1
                        action_passes = action_passes + current_test + "<br>"
                    else
                        action_failing_test = action_failing_test + 1
                        action_errors = action_errors + current_test + " Action Error: Value: " + omni_data[x,y,1] + " Should be: NAVMENU|WEATHER<br>"
                    end  

                when "ARTICLELINK/GALLERY" 
                    if omni_data[x,y,1] == "NAVMENU|DAY_IN_PICTURES"
                        action_passing_test = action_passing_test + 1
                        action_passes = action_passes + current_test + "<br>"
                    else
                        action_failing_test = action_failing_test + 1
                        action_errors = action_errors + current_test + " Action Error: Value: " + omni_data[x,y,1] + " Should be: NAVMENU|DAY_IN_PICTURES<br>"
                    end  

                when "ARTICLELINK/VIDEO" 
                    if omni_data[x,y,1] == CONTENT_TYPE[ARTICLE_LINK_VIDEO_CONST]
                        action_passing_test = action_passing_test + 1
                        action_passes = action_passes + current_test + "<br>"
                    else
                        action_failing_test = action_failing_test + 1
                        action_errors = action_errors + current_test + " Action Error: Value: " + omni_data[x,y,1] + " Should be: " + CONTENT_TYPE[ARTICLE_LINK_VIDEO_CONST] + " <br>"
                    end  

                when "SAVEDARTICLE_LANDSCAPE", "SAVEDARTICLE_PORTRAIT"
                    if omni_data[x,y,1] == CONTENT_TYPE[SAVED_ARTICLE_CONST]
                        action_passing_test = action_passing_test + 1
                        action_passes = action_passes + current_test + "<br>"
                    else
                        action_failing_test = action_failing_test + 1
                        action_errors = action_errors + current_test + " Content_Type Error: Value: " + omni_data[x,y,1] + " Should be: " + CONTENT_TYPE[SAVED_ARTICLE_CONST] + " <br>"
                    end                       
                    
                else
                    puts "Test name #{current_test}"
                    hf.write("Invalid 'Action' test name found: #{current_test}<br>")
                end
            end
        end
    end
end

puts "Passing tests:#{content_type_passing_test}"
puts "Failing tests:#{content_type_failing_test}"



###################################################################################
# PRINT OUT ALL BUSINESS RULE FINDINGS\
###################################################################################
=end

#Print title
hf.write("<table style='width:100%'><tr><td " + product_name_style +">PRODUCT TESTED: " + product_name + "</td></tr></table>")
puts "Printing product name information.  Omni_index: #{omni_index}"



for i in 0..omni_index
    if omni_testname[i].length > 0
        hf.write("<a href='##{omni_testname[i]}'>Jump to #{omni_testname[i]}</a><br>")
    end
end

=begin

###################################################################################
#CONTENT TYPE RESULTS
###################################################################################
hf.write("<table style='width:100%'><tr><td " + business_rule_style +">CONTENT TYPE RESULTS  ")
if content_type_failing_test == 0
    hf.write("<img src='../green_checkmark.png' height=40>" )
else
    hf.write("<img src='../red_x.jpeg' height=40><br>" )
end
hf.write("</td></tr></table>")


hf.write("<a href=""javascript:ReverseDisplay('CONTENTTYPE_ID')"">Click to show/hide Content Type tests</a>")
hf.write("<div id='CONTENTTYPE_ID' style='display:none;'>")

hf.write("<p>Passing content type rules: #{content_type_passing_test}")
if content_type_failing_test == 0
    hf.write("<img src='../green_checkmark.png' height=40>" )
end
hf.write("#{content_type_passes}")

hf.write("<p>Failing content type rules: #{content_type_failing_test}")
if content_type_failing_test > 0 
    hf.write("<img src='../red_x.jpeg' height=40><br>" )
    hf.write("#{content_type_errors}")
end
hf.write("</div>")


###################################################################################
#ACTION RESULTS
###################################################################################
hf.write("<table style='width:100%'><tr><td " + business_rule_style +">ACTION RESULTS  ")
if action_failing_test == 0
    hf.write("<img src='../green_checkmark.png' height=40>" )
else
    hf.write("<img src='../red_x.jpeg' height=40><br>" )
end
hf.write("</td></tr></table>")


hf.write("<a href=""javascript:ReverseDisplay('ACTION_ID')"">Click to show/hide Action tests</a>")
hf.write("<div id='ACTION_ID' style='display:none;'>")

hf.write("<p>Passing action rules: #{action_passing_test}")
if action_failing_test == 0
    hf.write("<img src='../green_checkmark.png' height=40>" )
end
hf.write("#{action_passes}")

hf.write("<p>Failing action rules: #{action_failing_test}")
if action_failing_test > 0 
    hf.write("<img src='../red_x.jpeg' height=40><br>" )
    hf.write("#{action_errors}")
end
hf.write("</div>")

=end


###################################################################################
# Print out AD calls
###################################################################################
ad_index=0
hf.write("<p><p><a name='ad_calls'></a>")

#hf.write("<table " + ad_style +"><tr><td>AD CALLS</td><td><a href=""javascript:ReverseDisplay('ADCALL_ID')"">Click to show/hide AD Calls</a></td></tr></table>")
hf.write("<table style='width:100%'><tr><td " + ad_style +"'>AD CALLS</td></tr></table>")

hf.write("<a href=""javascript:ReverseDisplay('ADCALL_ID')"">Click to show/hide AD Calls</a>")
hf.write("<div id='ADCALL_ID' style='display:none;'>")
hf.write("<table class='sortable'><tr style='font-weight: bold;'><td>Section</td><td>AD Call</td><td>Size</td><td>AWS Value</td><td>AD Parms</td></tr>")

ad_data.each do |line|
    if ad_data[ad_index][0].nil?  #this signifies there are no more elements
        break
    else
        hf.write("<td>"+ad_data[ad_index][0]+"</td>")
        hf.write("<td>"+ad_data[ad_index][1]+"</td>")
        #hf.write("<td>"+ad_data[ad_index][2]+"</td>")
        #hf.write("<td>"+ad_data[ad_index][3]+"</td>")
        #hf.write("<td>"+ad_data[ad_index][4]+"</td>")
        hf.write("</tr>")
        ad_index = ad_index + 1
    end 
end #do

#Build the html table casing
hf.write("</table></div>")


#Beginning printing the smoke tests
hf.write("<p><p><a href='#top_of_page'>Back to Top</a><br><br>")

for x in 0..omni_index-1 #Loop through each omniture call

    if omni_testname[x].length > 1
        if module_cnt > 0
            hf.write("</td></row></table>")
        end
        hf.write("<a name='#{omni_testname[x]}'></a>")
        hf.write("<table style='width:100%'><tr><td " + article_style +">"+omni_testname[x]+"</td></tr></table>") 
        hf.write("<a href='#top_of_page'>Back to Top</a><br><br>")  
        module_cnt = 0
    end

    module_cnt = module_cnt + 1

    case module_cnt
    when 1
        hf.write("<table><tr style='vertical-align: top;'><td>")
    when 2
        hf.write("</td><td>")
    when 3
        hf.write("</td><td>")
    when 4
        hf.write("</td></tr></table><table><tr style='vertical-align: top;'><td>")
        module_cnt = 1
    end           

    #Write out the API call
    hf.write("<a href=""javascript:ReverseDisplay('myid" + id.to_s + "')"">Click to show/hide parameters</a>")
    hf.write("<div id='myid" + id.to_s + "' style='display:none;'><table " + omni_style + "><tr><td>" + omni_url[x] + "</td></tr></table></div>")
    id = id + 1  

    #Beginning of each omniture call
    hf.write ("<table " + omni_style + "><tr style='font-weight:bold'><td>Omniture Parameter</td><td>Value</td></row>")
    for y in 0..100   
        if omni_data[x,y,0].nil? 
            break
        else    
            hf.write("<tr " + omni_style + ">")
            hf.write("<td>"+omni_data[x,y,0]+"</td>")
            hf.write("<td>"+omni_data[x,y,1]+"</td>")
            hf.write("</tr>")
        end
    end
    hf.write("</table>")

end 

hf.write("</body></html>")



