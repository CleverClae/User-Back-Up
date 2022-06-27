#!/bin/zsh

ORG_NAME="Your Organization Name"
UMESSAGE="What is your username?"
PMESSAGE="What is your Password?"
USMESSAGE="Select the User"
ICON_LOGO="/Library/Application\ Support/JAMF/Jamf.app/Contents/Resources/AppIcon.icns"

function dialog_command(){
  echo "$1"
  echo "$1"  >> $dialog_command_file
}

function Installdialog() {
	gitusername="bartreardon"
	gitreponame="swiftDialog"
	appNewVersion=$(curl --silent --fail "https://api.github.com/repos/$gitusername/$gitreponame/releases/latest" | grep tag_name | cut -d '"' -f 4 | sed 's/[^0-9\.]//g')
	if [ -z "$appNewVersion" ]; then
		echo "could not retrieve version number for $gitusername/$gitreponame"
		appNewVersion=""
	else
		/bin/echo "Dialog WebSite Version: $appNewVersion"
	fi
	if ! test -d "${dialogAppLocation}"; then # Look to see if the Dialog App is Installed
		echo "Dialog App is not Installed"
		localDialogVersion="0.1"
	else
		localDialogVersion=$(dialog -v) # uses dialog variable set at top of Script
		/bin/echo "Dialog Local Version: $localDialogVersion"
	fi
	if [ ! "(dialog)" ] || [ "$localDialogVersion" != "$appNewVersion" ]; then # Check to See if Dialog is Installed and the Current Version
		## Variables for Dialog download
		expectedTeamID="PWA5E9TQ59"
		archiveName="/private/tmp/dialog.pkg"
		downloadURL=$(curl --silent --fail "https://api.github.com/repos/$gitusername/$gitreponame/releases/latest"| awk -F '"' "/browser_download_url/ { print \$4; exit }")
		/bin/echo "Current Dialog version is $localDialogVersion. The latest is $appNewVersion"
		if [[ "$localDialogVersion" == "$appNewVersion" ]]; then
			/bin/echo "Latest verison of Dialog installed"
		else
			/bin/echo "Dialog is either not installed or is not the latest version, downloading"
			if ! curl --silent -L --fail "$downloadURL" -o "$archiveName"; then ## Download Dialog
				/bin/echo "Error downloading $downloadURL"
				/bin/echo "Dialog download failed."
				if test -f "$archiveName"; then
					/bin/rm -f "$archiveName"
				fi
				Exit_Process 190
			fi
			if ! spctlout=$(spctl -a -vv -t install "$archiveName" 2>&1 ); then
				/bin/echo "Error verifying $archiveName"
				if test -f "$archiveName"; then
					/bin/rm -f "$archiveName"
				fi
				Exit_Process 191
			else
				teamID=$(/bin/echo "$spctlout" | awk -F '(' '/origin=/ {print $2 }' | tr -d '()' ) ## Check to make sure it's a valid PKG from the creator
				/bin/echo "Downloaded PKG Team ID: $teamID / Expected Team ID: $expectedTeamID"
				if [ "$expectedTeamID" != "$teamID" ]; then
					/bin/echo "Team IDs do not match"
					if test -f "$archiveName"; then
						/bin/rm -f "$archiveName"
					fi
					Exit_Process 192
				fi
			fi
			if ! installer -pkg "$archiveName" -tgt "/"; then ## Install Dialog
				/bin/echo  "Error installing $archiveName"
				if test -f "$archiveName"; then
					/bin/rm -f "$archiveName"
				fi
				Exit_Process 193
			else
				/bin/echo "Dialog Installed."
				if test -f "$archiveName"; then
					/bin/rm -f "$archiveName"
					/bin/echo "Dialog Installer Removed"
				fi
			fi
		fi
	else
		echo "Dialog Installed, Moving on..."
	fi
}

Installdialog

function Backup() {

    #Create Backup mount point
    sudo mkdir -p "/Volumes/Backup"
    # Mounts PCBackup share UserData Folder

    # adminname : Adminpwrd@"Folder location on server
    # Example Below

    sudo mount_smbfs -s "//;"$USERNAME":"$PASSWORD"@10.193.153.106/PCBackup""" "/Volumes/Backup"

    wait
    # Begin Transfer from client machine to backup server with folders excluded

    # Feel free to modify --Exclude. Must use '' with proper folder name
    sudo /usr/bin/rsync -avzrog --ignore-errors --force --progress --stats --verbose \
        --exclude='.DS_Store' --exclude='.Trash' --exclude='iTunes' --exclude='Library' --exclude='Movies' --exclude='Music' --exclude='Pictures' --exclude='Public' --exclude='.*' --exclude='.*/' \
        "/Users/$SELECTEDUSER" "/Volumes/Backup/" && wait

    #sudo umount -fv "$bckUP"  
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
            --textfield Username,required \
            "
USERNAME=$(eval "$dialogCMD1" | grep "Username" | awk -F " : " '{print $NF}')


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
            --textfield Admin-Password,secure,required \
	"
PASSWORD=$(eval "$dialogCMD2" | grep "Admin-Password" | awk -F " : " '{print $NF}')


line=($(/usr/bin/dscl . list /Users UniqueID | /usr/bin/awk '$2 > 500 { print $1 ","}'))


dialogCMD3="dialog -ps --title \"${ORG_NAME}\" \
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
SELECTEDUSER=$(eval "$dialogCMD3" | grep "SelectedOption" | awk -F " : " '{print $NF}')

echo "$SELECTEDUSER"

dialogCMD4="dialog -ps --title \"${ORG_NAME}\" \
            --alignment "center" \
            --centericon true \
            --iconsize "250" \
            --messagefont size=24 \
			--messagefont bold \
            --icon "$ICON_LOGO" \
			--button1text OK \
			--quitkey b \
            --message  "Backup Complete"\
"

Backup ; eval "$dialogCMD4"

exit 0
