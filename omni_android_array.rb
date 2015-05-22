require 'uri'
require "./mobile-automation-values.rb"
require "pry"


#filename = "logcatOmnitureUSATcomplete.txt"
filename = "./data-android/omnitureTestWithMenuTap.txt"


puts "Filename: " + filename 

article_style = "style='font-weight: bold;font-size: xx-large; background-color:yellow'"
ad_style = "style='font-weight: bold;font-size: xx-large; background-color:orange'"
product_name_style = "style='font-weight: bold;font-size: xx-large; background-color:green'"
gnt_style = "style='background-color: lightblue; '"
omni_style = "style='background-color: PaleGoldenRod; '"

id=1 #rolling id # to make unique api call divs
product_name = ""  #Product being tested

module_cnt = 0  #track the number of API calls for display purposes per test
cycle_cnt = 1 #track number of times we iterate through 4 modules

ad_data = Array.new(1000) { Array.new(4) }   #array for ad calls.  1000 is upper bound.
ad_index = 0  #counter for ad call array

omni_data = Array.new(1000, Array.new(200, Array.new(2))) 

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

#Build the html table casing
hf.write("<html><body>")
hf.write("<a name='top_of_page'></a>")
hf.write("<a href='#ad_calls'>Jump to AD Calls</a><br><br>")

#hf.write("<tr style='font-weight: bold;'><td>Header Row</td></tr>")


File.open(filename) do |file|
 
    file.each do |line|

        #puts line

        if line.include? "---TESTNAME:"

             #Close prior test table
            if module_cnt > 0
                hf.write("</td></tr></table>")
            end

            #Get test name
            j = line.index("---TESTNAME:")  
            $testname = line.slice(j+12,line.length)
            hf.write("<table style='width:100%'><tr><td " + article_style +">"+$testname+"</td></tr></table>")

            $in_test = true
            module_cnt = 0
            cycle_cnt = 1

            puts "Start of "+$testname
        
        
        elsif line.include? "---THE_PRODUCT_NAME_IS:USA TODAY---"

            product_name = line.slice(line.index("THE_PRODUCT_NAME_IS")+20,line.length)
            product_name = product_name.slice(0,product_name.length-5)
        

        elsif line.include? "AD_REQUEST"
        
            ad_values = line.split("::")
                 
            #puts "Ad values(" + i.to_s + "): " + ad_values.inspect
            
            j = 1
            ad_values.each do |value|
                #puts "J value: " + j.to_s
                case j
                when 1
                    #ignore "AD_REQUEST" delimiter
                when 2
                    ad_data[ad_index][0] = value #section
                    #puts "Adding i,0"
                when 3
                    ad_data[ad_index][1] = value #adcall
                    #puts "Adding i,1"
                when 4
                    ad_data[ad_index][2] = value #size
                    #puts "Adding i,2"
                when 6
                    ad_data[ad_index][3] = value  #aws 
                    #puts "Adding i,3"
                end
            
                j = j + 1

                #puts "ad_data: " + ad_data[0][0] # + ":"+ ad_data[i][1] + ":"+ ad_data[i][2] + ":"+ ad_data[i][3] 

            end
            ad_index = ad_index + 1

        elsif line.include? "Analytics - Request Sent" and $in_test
            #puts line
            omni_call = URI.decode(line.slice(line.index("Analytics - Request Sent")+25,line.length))

            #Print out entire Omniture call

            #puts " "
            #puts omni_call.slice(0,omni_call.index("?")-1)

            omni_call = omni_call.slice(omni_call.index("?")+1,omni_call.length)  #Strip off the domain and API call, leaving just the parameters
            omni_call = omni_call.slice(0,omni_call.length-3)  #strip off last )

            #puts "Parameters: " + omni_call
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
                cycle_cnt = cycle_cnt + 1
            end           

            #Write out the API call
            hf.write("<a href=""javascript:ReverseDisplay('myid" + id.to_s + "')"">Click to show/hide parameters</a>")
            hf.write("<div id='myid" + id.to_s + "' style='display:none;'><table " + omni_style + "><tr><td>" + omni_call + "</td></tr></table></div>")
            id = id + 1            

            #Let's make the output pretty
            hf.write ("<table " + omni_style + "><tr style='font-weight:bold'><td>Omniture Parameter</td><td>Value</td></row>")
            
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
                        hf.write("<tr " + omni_style + "><td>"+prefixes[0]+prefixes[1]+prefixes[2]+prefixes[4]+prefixes[5]+p_value+"</td>")
                        col = 2

                        omni_data[omni_index][omni_row][0] = prefixes[0]+prefixes[1]+prefixes[2]+prefixes[4]+prefixes[5]+p_value
                        
                        #binding.pry


                        puts "Stored in omni_data[" + omni_index.to_s + "][" + omni_row.to_s + "][0]: "+ prefixes[0]+prefixes[1]+prefixes[2]+prefixes[4]+prefixes[5]+p_value 
                        puts "Printing: " + omni_data[omni_index][omni_row][0]

                        

                    elsif col==2  #Parameter value
                        hf.write("<td>"+p_value+"</td></tr>")
                        col = 1 

                        omni_data[omni_index][omni_row][1] = p_value

                        #binding.pry


                        puts "Stored in omni_data[" + omni_index.to_s + "][" + omni_row.to_s + "][1]: "+ p_value 
                        puts "Printing: " + omni_data[omni_index][omni_row][1]                     

                        omni_row = omni_row + 1
                    end                    
                end
                
                
            end
            omni_index = omni_index + 1

            hf.write("</table>")  
            #puts " "
            #puts " " 


             #puts "Omni data for index: " + omni_index.to_s
             #puts "#{omni_data}"



            
                for x in omni_index-1..omni_index-1
                    for y in 0..10
                        
                            puts "Validation: Stored in omni_data[" + x.to_s + "][" + y.to_s + "]: " + omni_data[x][y][0] + ":" + omni_data[x][y][1]
                            #puts "omni_data[" + x.to_s + "][" + y.to_s + "][" + z.to_s + "]" + omni_data[x][y][z]
                   
                    end
                end
            


        end

    end #each file record
        
    hf.write("</table>")     #End table wrapper for all omniture calls

end #open file


#binding.pry
#puts "omni_data: " + omni_data[0][0][0] + "  " + omni_data[0][0][1]
#puts "omni_data: " + omni_data[0][1][0] + "  " + omni_data[0][1][1]
#puts "omni_data: " + omni_data[0][2][0] + "  " + omni_data[0][2][1]
#puts "omni_data: " + omni_data[0][3][0] + "  " + omni_data[0][3][1]
#puts "omni_data: " + omni_data[0][4][0] + "  " + omni_data[0][4][1]




#Print title
hf.write("<table style='width:100%'><tr><td " + product_name_style +">PRODUCT TESTED: " + product_name + "</td></tr></table>")

#Print out AD calls
ad_index=0
hf.write("<p><p><a name='ad_calls'></a>")
hf.write("<a href='#top_of_page'>Back to Top</a><br><br>")
hf.write("<table style='width:100%'><tr><td " + ad_style +">AD CALLS</td></tr></table>")
hf.write("<table><tr style='font-weight: bold;'><td>Section</td><td>AD Call</td><td>Size</td><td>AWS Value</td></tr>")
ad_data.each do |line|
    if ad_data[ad_index][0].nil?  #this signifies there are no more elements
        break
    else
        hf.write("<tr>")    
        hf.write("<td>"+ad_data[ad_index][0]+"</td>")
        hf.write("<td>"+ad_data[ad_index][1]+"</td>")
        hf.write("<td>"+ad_data[ad_index][2]+"</td>")
        hf.write("<td>"+ad_data[ad_index][3]+"</td>")
        hf.write("</tr>")
        ad_index = ad_index + 1
    end 
end #do

#Build the html table casing
hf.write("</table>")










hf.write ("<p><p>AD Array")
hf.write("<table>")
omni_index = 0
omni_data.each do |line|
    if omni_data[omni_index][0].nil?  #this signifies there are no more elements
        break
    else
        line.each do |line2|
            if line[0][0].nil?  #this signifies there are no more elements
                break
            else
                hf.write("<tr>")    
                hf.write("<td>"+line2[0]+"</td>")
                hf.write("<td>"+line2[1]+"</td>")
                hf.write("</tr>")
            end
        end
        omni_index = omni_index + 1
    end 
end #do
hf.write("</table>")




hf.write("</body></html>")


