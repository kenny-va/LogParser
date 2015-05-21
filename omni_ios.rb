require 'uri'
require "./mobile-automation-values.rb"

#filename = "logcatOmnitureUSATcomplete.txt"
#filename = "omnitureBrevard.txt"
filename = "./data-ios/ios-omniture.txt"

puts "Filename: " + filename 

article_style = "style='font-weight: bold;font-size: xx-large; background-color:yellow'"
omni_style = "style='background-color: PaleGoldenRod ;'"

#Create and open HTML file for output
html_filename = filename.slice(0,filename.rindex(".")) + ".html"
hf = File.open(html_filename, "w")

#Build the html table casing
hf.write("<html><body><table>")
#hf.write("<tr style='font-weight: bold;'><td>Header Row</td></tr>")


File.open(filename) do |file|
 
    file.each do |line|

        $in_test = true

        if line.include? "---TESTNAME:"

            #Get test name
            j = line.index("---TESTNAME:")  
            $testname = line.slice(j+12,line.length)
            hf.write("<p><table><tr><td " + article_style +">Start of "+$testname+"</td></tr></table>")

            $in_test = true
            puts "Start of "+$testname
        

        elsif $in_test #While we are in within Omniture Test comments, log all api calls

            #puts "in in_test and looking for api calls"

            if line.include? "NSURLRequest" #Extract the Omniture call. 
                
                #hf.write("<p>Original line: " + line)

                omni_call = line.slice(line.index("URL:"),line.length)  #Strip off the omniture call

                #hf.write("<p>Omniture call: " + omni_call)

                hf.write("<p><table " + omni_style + "><tr><td colspan=2>"+omni_call+"</td></tr></table>")
                hf.write("<p><table " + omni_style + "><tr style='font-weight:bold'><td>Parameter</td><td>Value</td></tr>")

                omni_call = URI.decode(line.slice(line.index("?")+1,line.length))
                omni_call = omni_call.slice(0,omni_call.length-3)  #strip off last }
                


                #split all the GNT values
                #omni_call = omni_call.slice(omni_call.index("&")-1,omni_call.length)  #strip off domain call, leaving just parameters
                gnt_values = omni_call.split("&")

                prefix_cnt = 0
                prefixes = ["","","","","",""] #this array holds the prefixes, ie: c.a.DeviceName
           
                gnt_values.each do |value|
                    #hf.write("Parsing: " + value + "<br>")
                    param = value.split("=")
                    col = 1                    
                    param.each do |p_value|

                        if p_value.slice(-1,1) == "." #we have a prefix
                            prefixes[prefix_cnt] = p_value
                            puts "Found prefix number " + prefix_cnt.to_s + prefixes[prefix_cnt]

                            prefix_cnt = prefix_cnt + 1

                        elsif p_value.slice(0,1) == "."  #we have a suffix
                            prefixes[prefix_cnt-1] = ""
                            puts "Found suffix "+ prefix_cnt.to_s + prefixes[prefix_cnt]

                            prefix_cnt = prefix_cnt - 1

                        elsif col == 1  #parameter name
                            hf.write("<tr><td>"+prefixes[0]+prefixes[1]+prefixes[2]+prefixes[4]+prefixes[5] + p_value+"</td>")
                            puts "Parameter: " +prefixes[0]+prefixes[1]+prefixes[2]+prefixes[4]+prefixes[5] + p_value
                            col = 2
                            
                        elsif col==2  #parameter value
                            hf.write("<td>" + p_value.slice(0,p_value.length) + "</td></tr>")
                            puts "Value: " + p_value.slice(0,p_value.length)
                            col = 1 
                        end
                    end
                end

                hf.write("</table>")

                puts " "
                puts " "

            end #if

        end #elsif
        
    end #do
  end #do


#Build the html table casing
hf.write("</table></body></html>")


