#biz = Array.new(100) { Array.new(50) } 

# 2 dimensional approach
# biz = Array.new(50) { Array.new(30) }
$biz = My3Array.new

#BIZ(TEST, FIELD, VALUE)
$biz[0,0,0] = "Hamburger Button on NEWS front"
$biz[0,1,0] = "C.A.ACTION"
$biz[0,1,1] = "|MENUTOPOPEN|"

$biz[0,2,0] = "C.A.DEVICENAME"
$biz[0,2,1] = "|NOTNULL|"

$biz[1,0,0] = "NEWS FRONT"
$biz[1,1,0] = "C.A.ACTION"
$biz[1,1,1] = "|FRONT VIEW|NOTNULL|"




=begin 
#3 dimensional approach
biz = My3Array.new

biz[0,0,0] = "Hamburger Button on NEWS front"

biz[0,0,1] = "C.A.ACTION"
biz[0,0,2] = "MENUTOPOPEN"
biz[0,0,3] = "NOTNULL"

biz[0,0,1] = "C.A.DEVICENAME"
biz[0,0,2] = "NOTNULL"
=end




# biz = Array['Hamburger Button on NEWS front','C.A.ACTION'] 
# biz['Hamburger Button on NEWS front','C.A.ACTION'] = 'MENUTAPOPEN'