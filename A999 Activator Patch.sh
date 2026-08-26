#!/bin/bash

SCRIPTPATH="${0}"
SCRIPTPATHMAIN="${0%/*}"
PreRunOS()
{
	MACOSVERSION=$(sw_vers -productVersion | cut -d '.' -f 1,2)
}
PreRunMac()
{
	MACVERSION=$(sysctl hw.model | awk '{ print $2 }')
}
LIGHTMODE()
{
	APP='\033["38;5;23m'
	TITLE='\033["38;5;24m'
	BODY='\033["38;5;23m'
	PROMPTSTYLE='\033["38;5;66m'
	OSFOUND='\033["38;5;67m'
	WARNING='\033["38;5;160m'
	ERROR='\033["38;5;9m'
	CANCEL='\033["38;5;31m'
	BOLD='\033[1m'
	RESET='\033[0m'
}
DARKMODE()
{
	APP='\033["38;5;158m'
	TITLE='\033["38;5;153m'
	BODY='\033["38;5;158m'
	PROMPTSTYLE='\033["38;5;152m'
	OSFOUND='\033["38;5;111m'
	WARNING='\033["38;5;160m'
	ERROR='\033["38;5;196m'
	CANCEL='\033["38;5;38m'
	BOLD='\033[1m'
	RESET='\033[0m'
}
UIColors()
{
	UIAPPEARANCE=$(defaults read -g AppleInterfaceStyle 2>/dev/null)
	if [[ ! "$UIAPPEARANCE" == "Dark" ]]; then
		LIGHTMODE
	else
		if [[ "$MACOSVERSION" == 10.5 || "$MACOSVERSION" == 10.6 || "$MACOSVERSION" == 10.7 || "$MACOSVERSION" == 10.8 || "$MACOSVERSION" == 10.9 || "$MACOSVERSION" == 10.10 || "$MACOSVERSION" == 10.11 || "$MACOSVERSION" == 10.12 || "$MACOSVERSION" == 10.13 ]]; then
			LIGHTMODE
		else
			DARKMODE
		fi
	fi
}
WINDOWBAR()
{
	clear
	echo -e "${APP}${BOLD}                           a999 Activator Patch ${RESET}${APP}V1.0.0${BOLD}"
	echo -e "»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»"
}
WINDOWBAREND()
{
	echo -e ""
	echo -e "${RESET}${CANCEL}${BOLD}                                Script Canceled"
	echo -e "${RESET}${APP}${BOLD}"
	echo -e "»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»"
	echo -e "${RESET}"
	exit
}
WINDOWERROR()
{
	echo -e ""
	echo -e "${RESET}${ERROR}${BOLD}"
	echo -e "       Command not recognized, please report the following code to GitHub: "
	echo -e "                                     384508"
	echo -e "${RESET}"
	echo -e "${RESET}${APP}${BOLD}"
	echo -e "»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»"
	echo -e "${RESET}"
	exit
}
UIColors
MENU_SELECTOR()
{
    local options=("$@")
    local selected=0
    local key
    local num_options=${#options[@]}
    echo
    for i in "${!options[@]}"; do
        if [[ $i -eq $selected ]]; then
            printf "${RESET}${PROMPTSTYLE}${BOLD}                >-%s\033[0m\n" "${options[$i]}"
        else
            printf "                  ${RESET}${TITLE}%s\n" "${options[$i]}"
        fi
    done
    while true; do
        tput cuu $num_options
        for i in "${!options[@]}"; do
            if [[ $i -eq $selected ]]; then
                printf "${RESET}${PROMPTSTYLE}${BOLD}                >-%s\033[0m\n" "${options[$i]}-<"
            else
                printf "                  ${RESET}${TITLE}%s\n" "${options[$i]}  "
            fi
        done
        IFS= read -rsn1 key
        case "$key" in
            $'\x1b')
                IFS= read -rsn2 -t 1 rest || continue
                case "$rest" in
                    "[A")
                        ((selected--))
                        ((selected < 0)) && selected=$((num_options - 1))
                        ;;
                    "[B")
                        ((selected++))
                        ((selected >= num_options)) && selected=0
                        ;;
                esac
                ;;
            "")
                return $selected
                ;;
            [Qq])
                return 111
                ;;
            [Cc])
                return 110
                ;;
            *)
                ;;
        esac
    done
}
MAINMENU()
{
	WINDOWBAR
	echo -e "${RESET}${TITLE}${BOLD}                   Select the a999 executable to get started${RESET}"
	echo -e "${RESET}${BODY}                  Use ${BOLD}↑ ↓${RESET}${BODY} to navigate. Press ${BOLD}Return${RESET}${BODY} to select${RESET}"
	echo -e ""
	echo -e "${TITLE}${BOLD}                            Please choose an option:${RESET}${BODY}"
	menuoptions=("-----------Select a999 executable-----------" \
             	 "--------------------Exit--------------------" )
	MENU_SELECTOR "${menuoptions[@]}"
	selection=$?
	if [[ $selection -eq 000 ]]; then
    	A999FOLDER
    elif [[ $selection -eq 001 ]]; then
    	WINDOWBAREND
	else
    	WINDOWERROR
	fi
}
A999FOLDER()
{
folderpath=$(osascript <<EOF
		  	  tell application "System Events"
		    	    activate
		    	    set theFile to choose file with prompt "Select the a999 executable:"
		    	    return POSIX path of theFile
		    	end tell
EOF
)
FOLDERVERIFY
}
FOLDERVERIFY()
{
    local dir
    dir=$(dirname "$folderpath")
    
    local required_files=("changelog.md" "license.md" "readme.md")
    local required_folders=("bin" "payload")
    
    for file in "${required_files[@]}"; do
        if [[ ! -f "$dir/$file" ]]; then
            FOLDERERROR
            return 1
        fi
    done
    
    for folder in "${required_folders[@]}"; do
        if [[ ! -d "$dir/$folder" ]]; then
            FOLDERERROR
            return 1
        fi
    done
    
    for file in "${required_files[@]}"; do
        if [[ -f "$dir/.patched" ]]; then
            FOLDERPASSPATCHED
            return 1
        fi
    done
    
    FOLDERPASS
    return 0
}
FOLDERERROR()
{
	echo -e ""
	echo -e "${RESET}${ERROR}        This folder has been corrupted. Please redownload and try again."
	echo -e "${RESET}${APP}${BOLD}"
	echo -e "»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»"
	echo -e "${RESET}"
	exit
	
}
FOLDERPASS()
{
	WINDOWBAR
	echo -e "${RESET}${TITLE}${BOLD}                              a999 executable found!${RESET}"
	echo -e "${RESET}${BODY}                  Use ${BOLD}↑ ↓${RESET}${BODY} to navigate. Press ${BOLD}Return${RESET}${BODY} to select${RESET}"
	echo -e ""
	echo -e "${TITLE}${BOLD}                            Please choose an option:${RESET}${BODY}"
	menuoptions=("-------------* Start Patching *-------------" \
				 "-----------Select a999 executable-----------" \
             	 "--------------------Exit--------------------" )
	MENU_SELECTOR "${menuoptions[@]}"
	selection=$?
	if [[ $selection -eq 000 ]]; then
    	A999PATCH
    elif [[ $selection -eq 001 ]]; then
    	A999FOLDER
    elif [[ $selection -eq 002 ]]; then
    	WINDOWBAREND
	else
    	WINDOWERROR
	fi
}
FOLDERPASSPATCHED()
{
	WINDOWBAR
	echo -e "${RESET}${TITLE}${BOLD}                          a999 has already been patched${RESET}"
	echo -e "${RESET}${BODY}                  Use ${BOLD}↑ ↓${RESET}${BODY} to navigate. Press ${BOLD}Return${RESET}${BODY} to select${RESET}"
	echo -e ""
	echo -e "${TITLE}${BOLD}                            Please choose an option:${RESET}${BODY}"
	menuoptions=("-------------* Revert Patches *-------------" \
				 "-----------Select a999 executable-----------" \
             	 "--------------------Exit--------------------" )
	MENU_SELECTOR "${menuoptions[@]}"
	selection=$?
	if [[ $selection -eq 000 ]]; then
    	A999PATCHREVERT
    elif [[ $selection -eq 001 ]]; then
    	A999FOLDER
    elif [[ $selection -eq 002 ]]; then
    	WINDOWBAREND
	else
    	WINDOWERROR
	fi
}
A999PATCH()
{
	WINDOWBAR
	echo -e -n "${RESET}${TITLE}${BOLD}                               Applying patches..."
	echo -e ""
	echo -e "\033[1A\033[0K${BODY}"
	sed -i '' '17s/047-95293/122-77536/' "$dir/a999"
	sed -i '' '17s/18A0749D-A68D-430C-8E31-1920612F3229/9EE30DC1-EC4B-47CE-A002-24CD6B18947D/' "$dir/a999"
	sed -i '' '17s/15.8.7_19H411/15.8.8_19H422/' "$dir/a999"
	sed -i '' '19s/047-95429/122-77510/' "$dir/a999"
	sed -i '' '19s/C8FE847C-FE0E-49B1-9C7E-F56894B6E2BF/5D4563BF-445C-4D8D-AF56-0BAC336265F3/' "$dir/a999"
	sed -i '' '19s/15.8.7_19H411/15.8.8_19H422/' "$dir/a999"
	sed -i '' '26s/15.8.7/15.8.8/' "$dir/a999"
	sed -i '' '140s/15.8.7/15.8.8/' "$dir/a999"
	sed -i '' '142s/15.8.7/15.8.8/' "$dir/a999"
	sed -i '' '143s/15.8.7/15.8.8/' "$dir/a999"
	sed -i '' '145s/15.8.7/15.8.8/' "$dir/a999"
	sed -i '' '175s/15.8.7/15.8.8/' "$dir/a999"
	touch "$dir/.patched"
	echo -e "${RESET}${BODY}${BOLD}                                   All Done!${RESET}"
	echo -e ""
	echo -e "${TITLE}${BOLD}                            Please choose an option:${RESET}${BODY}"
	menuoptions=("-----------------Start a999-----------------" \
             	 "--------------------Exit--------------------" )
	MENU_SELECTOR "${menuoptions[@]}"
	selection=$?
	if [[ $selection -eq 000 ]]; then
    	echo -e "${RESET}"
    	echo -e ""
    	cd $dir
    	./a999 && exit
    elif [[ $selection -eq 001 ]]; then
    	WINDOWBAREND
	else
    	WINDOWERROR
	fi
}
A999PATCHREVERT()
{
	WINDOWBAR
	echo -e -n "${RESET}${TITLE}${BOLD}                               Removing patches..."
	echo -e ""
	echo -e "\033[1A\033[0K${BODY}"
	sed -i '' '17s/122-77536/047-95293/' "$dir/a999"
	sed -i '' '17s/9EE30DC1-EC4B-47CE-A002-24CD6B18947D/18A0749D-A68D-430C-8E31-1920612F3229/' "$dir/a999"
	sed -i '' '17s/15.8.8_19H422/15.8.7_19H411/' "$dir/a999"
	sed -i '' '19s/122-77510/047-95429/' "$dir/a999"
	sed -i '' '19s/5D4563BF-445C-4D8D-AF56-0BAC336265F3/C8FE847C-FE0E-49B1-9C7E-F56894B6E2BF/' "$dir/a999"
	sed -i '' '19s/15.8.8_19H422/15.8.7_19H411/' "$dir/a999"
	sed -i '' '26s/15.8.8/15.8.7/' "$dir/a999"
	sed -i '' '140s/15.8.8/15.8.7/' "$dir/a999"
	sed -i '' '142s/15.8.8/15.8.7/' "$dir/a999"
	sed -i '' '143s/15.8.8/15.8.7/' "$dir/a999"
	sed -i '' '145s/15.8.8/15.8.7/' "$dir/a999"
	sed -i '' '175s/15.8.8/15.8.7/' "$dir/a999"
	rm -rf "$dir/.patched"
	echo -e "${RESET}${BODY}${BOLD}                                   All Done!${RESET}"
	echo -e "${RESET}${APP}${BOLD}"
	echo -e "»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»»"
	echo -e "${RESET}"
	exit
}
MAINMENU
