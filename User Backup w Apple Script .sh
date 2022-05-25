#!/bin/sh


###########################################################################################################################
# Created by : Clayton.Council@me.com 3/20/21
###########################################################################################################################
# General Information
###########################################################################################################################
# This script is designed to backup termed users to a backup server
# Must Change permissions before running
# Must be ran adadmin
# Now Available in Self Service
###########################################################################################################################
# General Appearance
###########################################################################################################################
## Get the logged in user's name

function Ques(){
  adminName="$(osascript <<'EOT'
    tell application "System Events"
	    display dialog "Enter your network name?" default answer ""
	    set answer to text returned of result
        end tell
    EOT)"

  adminPwrd="$(osascript <<'EOT'
        display dialog "Enter your network password?" default answer "" with icon stop buttons {"Cancel", "Continue"} default button "Continue" with hidden answer
        set answer to text returned of result
    EOT)"

  lastUser="$(osascript << 'EOF'
	    set localUsers to do shell script "/usr/bin/dscl . list /Users UniqueID | /usr/bin/awk '$2 > 500 { print $1 }'"
	    set localUsers to paragraphs of localUsers
	    set userName to choose from list localUsers with title "Select User to Backup" with prompt "Please select which user to Backup:"
    EOF)"
}


function Backup(){
newDir="/Volumes/Backup/"$lastUser""
bckUp="/Volumes/Backup"
tranFer="/Users/"$lastUser""

#Create Backup mount point
sudo mkdir  -p "/Volumes/Backup"
# Mounts PCBackup share UserData Folder

# adminname : Adminpwrd@"Folder location on server 
# Example Below

sudo mount_smbfs -s "//;"$adminName":"$adminPwrd"@XX.XXX.XXX.XXX/Foldername""" "/Volumes/Backup"

wait

sudo mkdir "/Volumes/Backup/$lastUser"
# Begin Transfer from client machine to backup server with folders excluded

# Feel free to modify --Exclude. Must use '' with proper folder name
sudo /usr/bin/rsync -avzrog --ignore-errors --force --progress --stats --verbose \
    --exclude='.DS_Store' --exclude='.Trash' --exclude='iTunes' --exclude='Library' --exclude='Movies' --exclude='Music' --exclude='Pictures' --exclude='Public' --exclude='.*' --exclude='.*/' \
    "/Users/$lastUser" "/Volumes/Backup/$lastUser" && wait

sudo umount -fv "$bckUP"


}

Ques && wait

Backup && wait


adminPwrd="$(osascript <<'EOT'
display alert "User Backup Complete"
EOT)"

exit 0
