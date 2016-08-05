=begin

These are the stored validation business rules.  Rules are organized by test. The test name is set during the automation 
test of the iOS scripts. 

It's possible to test for "not null" and specific values.  This means you can test to ensure that a field has a value, and you can test
for a specific value.  You cannot test for multiple values.

To add fields for a test, you first need the test name.  This may be retrieved from the HTML output.  For example, the 
test "Beginning Omniture test: SPORTS front" appears on the HTML output.  The testname to use for field validation would be
"SPORTS front".  Just strip off the beginning portion of the line.  Test names should be uppercase in the business rules.

Field values are easy to pick.  Must be upper case.

To set the allowable values, just add the values separated by the pipe operator "|".  Pipes must enclose the value, before and after.  To include
multiple allowable values, just keep adding them to the string, ie: |value1|value2|value3|.

To add the "NOT NULL" condition, just add |NOTNULL| to the field string.

The indexes of the entries must follow a strict pattern.  The first index is for test names.  The 2nd index is used for each field, starting at the 
value 1.  The 3rd index stores the allowable values and is set at 1.  Future expansion may use additional indexes.  Index values must be contiguous, 
meaning no numbers may be skipped.  If a number is skipped, then the validation will stop at that gap in indexes.

=end

$biz = My3Array.new

#BIZ(TEST, FIELD, VALUE)


$biz[0,0,0] = "Hamburger Button on NEWS front"

$biz[0,1,0] = "C.A.ACTION"
$biz[0,1,1] = "|MENUTAPOPEN|"

$biz[0,2,0] = "C.A.DEVICENAME"
$biz[0,2,1] = "|NOTNULL|"

$biz[0,3,0] = "C.A.APPID"
$biz[0,3,1] = "|NOTNULL|"

$biz[0,4,0] = "C.GNT.ORIENTATION"
$biz[0,4,1] = "|PORTRAIT|LANDSCAPE|"

# NEWS FRONT TEST
$biz[1,0,0] = "NEWS FRONT"

$biz[1,1,0] = "C.A.ACTION"
$biz[1,1,1] = "|FRONT VIEW|NOTNULL|"

# TOP STORIES FRONT TEST
$biz[2,0,0] = "TOP STORIES FRONT"

$biz[2,1,0] = "C.GNT.ORIGINATINGSECTION"
$biz[2,1,1] = "|TOP STORIES|NOTNULL|"



