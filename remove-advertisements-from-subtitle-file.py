import re, sys

try:
    file=sys.argv[1]
except IndexError:
    print('No file')
    exit()  

file = open(file, "w+")

content = file.read()

blocks = content.split("\n\n")

newContent = ""

advertisementPatterns=[
    "Advertise your product or brand here",
    "OpenSubtitles.org",
    "Please rate this subtitle",
    "[A-Za-z0-9]{4,}\.[A-Za-z0-9]{2,}"
]

def isAdvertisement(block):
    result = False
    
    for pattern in advertisementPatterns:
        if re.search(pattern, block): result = True

    return result

blockCounter=1

hasAdvertisements = False

for block in blocks:
    if not isAdvertisement(block):
        blockCounter=blockCounter+1
        fixedBlock=re.sub('^[0-9]+', "{}".format(blockCounter), block)
        newContent=newContent+fixedBlock+"\n\n"
    else:
        hasAdvertisements = True

if hasAdvertisements:
    try:
        file.write(newContent)
        print("True")
    except IndexError:
        print("Error writing to file")
else:
    print("False")

file.close()