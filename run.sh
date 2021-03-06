#!/bin/bash
set -e

FOLDERS=(
    "/mnt/hdd/share/tv"
    "/mnt/hdd/share/movies"
    "/mnt/hdd/share/movies2"
)

COLOR_RESET=$(tput sgr0)
COLOR_TEXT_GREEN=$(tput setaf 2)
COLOR_TEXT_RED=$(tput setaf 1)
COLOR_TEXT_YELLOW=$(tput setaf 3)
COLOR_TEXT_BLACK=$(tput setaf 0)
COLOR_TEXT_WHITE=$(tput setaf 7)
COLOR_BACKGROUND_WHITE=$(tput setab 7)
COLOR_BACKGROUND_GREEN=$(tput setab 2)
COLOR_BACKGROUND_RED=$(tput setab 1)
COLOR_BACKGROUND_YELLOW=$(tput setab 3)
MESSAGE_TEMPLATE="  $(tput bold)%b  %s\\n"
MESSAGE_ICON_TICK="${COLOR_BACKGROUND_GREEN}${COLOR_TEXT_BLACK} ✓ ${COLOR_RESET}"
MESSAGE_ICON_CROSS="${COLOR_BACKGROUND_RED}${COLOR_TEXT_WHITE} ✗ ${COLOR_RESET}"
MESSAGE_ICON_WARN="${COLOR_BACKGROUND_YELLOW}${COLOR_TEXT_BLACK} ⚠ ${COLOR_RESET}"
MESSAGE_ICON_INFO="${COLOR_BACKGROUND_WHITE}${COLOR_TEXT_BLACK} i ${COLOR_RESET}"

SUBTITLE_AMOUNT_TOTAL=0
SUBTITLE_AMOUNT_FIXED=0
SUBTITLE_AMOUNT_UNTOUCHED=0
SUBTITLE_AMOUNT_ERROR=0

FLAG_VERBOSE=0

printError()
{
    printf "${MESSAGE_TEMPLATE}" "${MESSAGE_ICON_CROSS}" "${COLOR_TEXT_RED}${1}${COLOR_RESET}"
}

printSuccess()
{
    printf "${MESSAGE_TEMPLATE}" "${MESSAGE_ICON_TICK}" "${COLOR_TEXT_GREEN}${1}${COLOR_RESET}"
}

printWarning()
{
    printf "${MESSAGE_TEMPLATE}" "${MESSAGE_ICON_WARN}" "${COLOR_TEXT_YELLOW}${1}${COLOR_RESET}"
}

printInfo()
{
    printf "${MESSAGE_TEMPLATE}" "${MESSAGE_ICON_INFO}" "${COLOR_TEXT_WHITE}${1}${COLOR_RESET}"
}

printLine()
{
    echo "       ${1}"
}

main()
{
    printInfo "Running cleaner"

    (
        # checkFlags
        checkRequirements
        scanAndFixFolders
    )

    if [ $? -eq 0 ]; then
        printSuccess "Done!"
    else
        printError "Something went wrong..."
    fi
}

checkFlags()
{  
    printInfo "Testing flags"
    printInfo "${1}"
    while test $# -gt 0; do
        printInfo "${1}"
        case "$1" in
            -v|--verbose)
                shift
                FLAG_VERBOSE=1
                shift
                ;;
          
            *)
                printError "$1 is not a recognized flag!"
                return 1;
                ;;
        esac
    done
}

checkRequirements()
{
    local requirementsMet=1
    local requirements=(python3)


    for requirement in "${requirements[@]}"; do
        if [[ ! $(which ${requirement}) ]]; then
            printWarning "${requirement} not installed"
            requirementsMet=0
        fi
    done

    if [[ ! $requirementsMet == 1 ]]; then
        printError "Not all requirements met"
        return 20
    fi

}

scanAndFixFolders()
{
    for FOLDER in "${FOLDERS[@]}"; do
        if [[ ! -d "${FOLDER}" ]]; then
            printWarning "Folder (${FOLDER}) does not exist"
        else
            scanFolderAndExecuteFix $FOLDER
        fi
    done
    printAmounts
}

scanFolderAndExecuteFix()
{
    shopt -s globstar lastpipe
    printInfo "Scanning '$(tput smul)${1}$COLOR_RESET'"
    for SUBTITLE_FILE in ${1}/**/*.srt; do
        if [[ -f "${SUBTITLE_FILE}" ]]; then
            fixSubtitleFile "${SUBTITLE_FILE}"
        fi
    done
}

fixSubtitleFile()
{
    SUBTITLE_AMOUNT_TOTAL=$((SUBTITLE_AMOUNT_TOTAL+1))
    REMOVE=$(python3 remove-advertisements-from-subtitle-file.py "${1}")
    if [[ "${REMOVE}" == 'True' ]]; then
        SUBTITLE_AMOUNT_FIXED=$((SUBTITLE_AMOUNT_FIXED+1))
        printSuccess "Fixed ${1}"
        if [[ $FLAG_VERBOSE == 1 ]]; then
            printSuccess "Fixed ${1}"
        fi
    elif [[ "${REMOVE}" == 'False' ]]; then
        SUBTITLE_AMOUNT_UNTOUCHED=$((SUBTITLE_AMOUNT_UNTOUCHED+1))
    else 
        SUBTITLE_AMOUNT_ERROR=$((SUBTITLE_AMOUNT_ERROR+1))
    fi
}

printAmounts()
{
    #Calculate percentages
    local percentageFixed=$(echo "scale=3; $SUBTITLE_AMOUNT_FIXED/$SUBTITLE_AMOUNT_TOTAL*100" | bc &> /dev/null)
    local percentageUntouched=$(echo "scale=3; $SUBTITLE_AMOUNT_UNTOUCHED/$SUBTITLE_AMOUNT_TOTAL*100" | bc &> /dev/null)
    local percentageError=$(echo "scale=3; $SUBTITLE_AMOUNT_ERROR/$SUBTITLE_AMOUNT_TOTAL*100" | bc &> /dev/null)

    #Round off the percentages
    percentageFixed=$(printf %.$2f $percentageFixed)
    percentageUntouched=$(printf %.$2f $percentageUntouched)
    percentageError=$(printf %.$2f $percentageError)

    #Pad percentages with two spaces to the left
    percentageFixed=$(printf "%2s%s" $percentageFixed)
    percentageUntouched=$(printf "%2s%s" $percentageUntouched)
    percentageError=$(printf "%2s%s" $percentageError)

    #Pad amounts with three spaces to the left
    SUBTITLE_AMOUNT_TOTAL=$(printf "%3s%s" $SUBTITLE_AMOUNT_TOTAL)
    SUBTITLE_AMOUNT_FIXED=$(printf "%3s%s" $SUBTITLE_AMOUNT_FIXED)
    SUBTITLE_AMOUNT_UNTOUCHED=$(printf "%3s%s" $SUBTITLE_AMOUNT_UNTOUCHED)
    SUBTITLE_AMOUNT_ERROR=$(printf "%3s%s" $SUBTITLE_AMOUNT_ERROR)

    #Print information
    printLine "Total      ${COLOR_BACKGROUND_WHITE}${COLOR_TEXT_BLACK} ${SUBTITLE_AMOUNT_TOTAL} ${COLOR_RESET}";
    printLine "Fixed      ${COLOR_BACKGROUND_GREEN}${COLOR_TEXT_BLACK} ${SUBTITLE_AMOUNT_FIXED} ${COLOR_RESET} (${percentageFixed}%)";
    printLine "Untouched  ${COLOR_BACKGROUND_YELLOW}${COLOR_TEXT_BLACK} ${SUBTITLE_AMOUNT_UNTOUCHED} ${COLOR_RESET} (${percentageUntouched}%)";
    printLine "Error      ${COLOR_BACKGROUND_RED}${COLOR_TEXT_WHITE} ${SUBTITLE_AMOUNT_ERROR} ${COLOR_RESET} (${percentageError}%)";
}

main "$@"