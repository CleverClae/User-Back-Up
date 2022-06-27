#!/bin/zsh


ORG_NAME="Your Organization Name"
UMESSAGE="What is your username?"
PMESSAGE="What is your Password?"
USMESSAGE="Select the User"
ICON_LOGO="/Library/Application\ Support/JAMF/Jamf.app/Contents/Resources/AppIcon.icns"

function Backup(){
    newDir="/Volumes/Backup/"$SELECTEDUSER""
    BACK_UP="/Volumes/Backup"
    tranFer="/Users/"$SELECTEDUSER""

    #Create Backup mount point
    sudo mkdir  -p "/Volumes/Backup"
    # Mounts PCBackup share UserData Folder

    # adminname : Adminpwrd@"Folder location on server 
    # Example Below

    sudo mount_smbfs -s "//;"$USERNAME":"$PASSWORD"@XX.XXX.XXX.XXX/Foldername""" "$BACK_UP"

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
	#echo "${PASSWORD}"

line=($(/usr/bin/dscl . list /Users UniqueID | /usr/bin/awk '$2 > 500 { print $1 ","}'))
echo "${line[*]}"

UMESSAGE="Please select the username"
ORG_NAME="Your Organization Name"
ICON_LOGO="/Library/Application\ Support/JAMF/Jamf.app/Contents/Resources/AppIcon.icns"

dialogCMD1="dialog -ps --title \"${ORG_NAME}\" \
            --alignment "center" \
            --centericon true \
            --iconsize "250" \
            --messagefont size=24 \
			--messagefont bold \
            --icon "$ICON_LOGO" \
            --selecttitle Select User \
            --selectvalues \"${line[*]}\" \
			--button1text OK \
			--quitkey b \
            --message  \"${UMESSAGE}\" \
"
SELECTEDUSER=$(eval "$dialogCMD1"| grep "SelectedOption" | awk -F " : " '{print $NF}')

echo "$SELECTEDUSER"

Backup

exit 0

