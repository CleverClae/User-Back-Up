#!/bin/zsh


ORG_NAME="IPG Health"
UMESSAGE="What is your username?"
PMESSAGE="What is your Password?"
USMESSAGE="Select the User"
ICON_LOGO="/Library/Application\ Support/JAMF/Jamf.app/Contents/Resources/AppIcon.icns"
USER_LIST="/usr/bin/dscl . list /Users UniqueID | /usr/bin/awk '$2 > 500 { print $1 }'"

function Backup(){
    newDir="/Volumes/Backup/"$SELECTEDUSER""
    bckUp="/Volumes/Backup"
    tranFer="/Users/"$SELECTEDUSER""

    #Create Backup mount point
    sudo mkdir  -p "/Volumes/Backup"
    # Mounts PCBackup share UserData Folder

    # adminname : Adminpwrd@"Folder location on server 
    # Example Below

    sudo mount_smbfs -s "//;"$adminName":"$adminPwrd"@XX.XXX.XXX.XXX/Foldername""" "/Volumes/Backup"

    wait

    sudo mkdir "/Volumes/Backup/$SELECTEDUSER"
    # Begin Transfer from client machine to backup server with folders excluded

    # Feel free to modify --Exclude. Must use '' with proper folder name
    sudo /usr/bin/rsync -avzrog --ignore-errors --force --progress --stats --verbose \
    --exclude='.DS_Store' --exclude='.Trash' --exclude='iTunes' --exclude='Library' --exclude='Movies' --exclude='Music' --exclude='Pictures' --exclude='Public' --exclude='.*' --exclude='.*/' \
    "/Users/$SELECTEDUSER" "/Volumes/Backup/$SELECTEDUSER" && wait

    sudo umount -fv "$bckUP"
}

dialogCMD1="dialog -ps --title \"${ORG_NAME}\" \
            --alignment "center" \
            --centericon true \
            --iconsize "250" \
            --messagefont size=24 \
			--messagefont bold \
            --icon "$ICON_LOGO" \
			--button1text OK \
			--quitkey b \
            --message  \"${UMESSAGE}\" \
            --textfield Username
"
USERNAME=$(eval "$dialogCMD1"| grep "Username" | awk -F " : " '{print $NF}')
	echo "${USERNAME}"


dialogCMD2="dialog -ps  --title \"${ORG_NAME}\" \
            --alignment "center" \
            --centericon true \
            --iconsize "250" \
            --messagefont size=24 \
			--messagefont bold \
            --icon "$ICON_LOGO" \
			--button1text OK \
			--quitkey b \
            --message  \"${PMESSAGE}\" \
            --textfield Admin-Password,secure 
"
PASSWORD=$(eval "$dialogCMD2"| grep "Admin-Password" | awk -F " : " '{print $NF}')
	echo "${PASSWORD}"



SELECTEDUSER="$(osascript << 'EOF'
	    set localUsers to do shell script "/usr/bin/dscl . list /Users UniqueID | /usr/bin/awk '$2 > 500 { print $1 }'"
	    set localUsers to paragraphs of localUsers
	    set userName to choose from list localUsers with title "Select User to Backup" with prompt "Please select which user to Backup:"
    EOF)"

SELECTEDUSER

