require "./mobile-automation-values.rb"

#filename = "logcatNavCincinatti.txt"
filename = "./data-android/omnitureTestWithMenuTap.txt"
#filename = "logcatBrevardNavigation.txt"
#filename = "logcatOmnitureDetroit.txt"

puts filename 

#Build array of values
multi = Array.new(1000) { Array.new(4) }

File.open(filename) do |file|
    i = 0
    file.each do |line|

        if line.include? "AD_REQUEST"
        
            ad_values = line.split("::")
                 
            #puts "Ad values(" + i.to_s + "): " + ad_values.inspect
            
            j = 1
            ad_values.each do |value|
                #puts "J value: " + j.to_s
                case j
                when 1
                    #ignore "AD_REQUEST" delimiter
                when 2
                    multi[i][0] = value #section
                    #puts "Adding i,0"
                when 3
                    multi[i][1] = value #adcall
                    #puts "Adding i,1"
                when 4
                    multi[i][2] = value #size
                    #puts "Adding i,2"
                when 6
                    multi[i][3] = value  #aws 
                    #puts "Adding i,3"
                end
            
                j = j + 1

                #puts "Multi: " + multi[0][0] # + ":"+ multi[i][1] + ":"+ multi[i][2] + ":"+ multi[i][3] 

            end
            i = i + 1

        end #if
    end #file
end #do

#puts "Iterating through multi"
#multi.compact
#puts multi.inspect


#Create and open HTML file for output
html_filename = filename.slice(0,filename.rindex(".")) + ".html"  #use 5 so we don't pick up the leading period
hf = File.open(html_filename, "w")
i=0
hf.write("<html><body><table>")
hf.write("<tr style='font-weight: bold;'><td>Section</td><td>AD Call</td><td>Size</td><td>AWS Value</td></tr>")
multi.each do |line|
    if multi[i][0].nil?
        break
    else
        hf.write("<tr>")    
        hf.write("<td>"+multi[i][0]+"</td>")
        hf.write("<td>"+multi[i][1]+"</td>")
        hf.write("<td>"+multi[i][2]+"</td>")
        hf.write("<td>"+multi[i][3]+"</td>")
        hf.write("</tr>")
        i = i + 1 
    end 
end #do

#Build the html table casing
hf.write("</table></body></html>")

