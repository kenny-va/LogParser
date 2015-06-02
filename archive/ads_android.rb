require "./mobile-automation-values.rb"

#filename = "logcatNavCincinatti.txt"
filename = "./data-android/omnitureTestWithMenuTap.txt"
#filename = "logcatBrevardNavigation.txt"
#filename = "logcatOmnitureDetroit.txt"

puts filename 

#Create and open HTML file for output
html_filename = filename.slice(0,filename.rindex(".")) + ".html"  #use 5 so we don't pick up the leading period
hf = File.open(html_filename, "w")
puts "Writing to file: " + html_filename

#Build the html table casing
hf.write("<html><body><table>")
hf.write("<tr style='font-weight: bold;'><td>Section</td><td>AD Call</td><td>Size</td><td>AWS Value</td></tr>")


File.open(filename) do |file|

    file.each do |line|

        section = ""
        adcall = ""
        size = ""
        aws = ""

        if line.include? "AD_REQUEST"
        
            ad_values = line.split("::")
            #ad_values.sort
            i = 1
            ad_values.each do |value|
                case i
                when 1
                    #ignore "AD_REQUEST" delimiter
                when 2
                    section = value
                when 3
                    adcall = value
                when 4
                    size = value
                when 6
                    aws = value
                end
            i = i + 1

            end

        hf.write("<td>"+section+"</td>")
        hf.write("<td>"+adcall+"</td>")
        hf.write("<td>"+size+"</td>")
        hf.write("<td>"+aws+"</td>")

        hf.write("</tr>")

      end #if

    end #file
  end #do


#Build the html table casing
hf.write("</table></body></html>")

