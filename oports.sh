#!/bin/bash

#OPENED-PORTS V.1.0

#	#---- What is it for? ----#

#	#Port scanning and collection of the most important information:

#		-OS
#		-Open ports
#		-Services
#		-Versions

#	#--------------------------------------------------------------------------#
#	#---- It can be used both to analyze the previously mentioned data in  ----#
#	#---- a file or create the scan from scratch and then do the analysis. ----#
#	#--------------------------------------------------------------------------#
#	#------------------------- More info in oports.sh -------------------------#
#	#--------------------------------------------------------------------------#

# 				#------- Installation process: -------#
#	#------------------------------------------------------------------------------------#
#	#---- You can save the script wherever you want. For example: /usr/bin/oports.sh ----#
#	#---- Give it execution permissions: chmod +x oports.sh 			 ----#
#	#---- And that's it. Now you can run it in any directory. :D   			 ----#
#	#---- Type oports.sh -h to see how to use the script.				 ----#
#	#------------------------------------------------------------------------------------#
#			    #------ You need to have installed NMAP ------#

#------- COLORS -------
RED="$(printf '\033[31m')"
YELLOW="$(printf '\033[33m')"
BLUE="$(printf '\033[34m')"
GREEN="$(printf '\033[32m')"
ENDCOLOR="$(printf '\033[0m')"
LIGHT_YELLOW="$(printf '\033[93m')"

#------- Function that tells what OS is -------#
ttl (){
        ttl=$(ping -c 1 $IP 2>/dev/null | grep -o 'ttl=[0-9]\+' | awk -F'=' '{print $2}')

        if [ $(("$ttl")) -le 70 ]; then
                SYSTEM="Linux"
        else
                SYSTEM="Windows"
        fi
}

#------- Draw this at the end of the script execution -------#
end (){
        echo -e "${GREEN}----------------------------------------------------------------------------${ENDCOLOR}"
        echo -e "${RED} ▒█████  ${BLUE} ██▓███   ▒█████   ██▀███  ▄▄▄█████▓  ██████ ${ENDCOLOR}"
        echo -e "${RED}▒██▒  ██▒${BLUE}▓██░  ██ ▒██▒  ██▒▓██ ▒ ██▒▓  ██▒ ▓▒▒██    ▒ ${ENDCOLOR}"
        echo -e "${RED}▒██░  ██▒${BLUE}▓██░ ██▓▒▒██░  ██▒▓██ ░▄█ ▒▒ ▓██░ ▒░░ ▓██▄   ${ENDCOLOR}"
        echo -e "${RED}▒██   ██░${BLUE}▒██▄█▓▒ ▒▒██   ██░▒██▀▀█▄  ░ ▓██▓ ░   ▒   ██▒${ENDCOLOR}"
        echo -e "${RED}░ ████▓▒░${BLUE}▒██▒ ░  ░░ ████▓▒░░██▓ ▒██▒  ▒██▒ ░ ▒██████▒▒${ENDCOLOR}"
        echo -e "${RED}░ ▒░▒░▒░ ${BLUE}▒▓▒░ ░  ░░ ▒░▒░▒░ ░ ▒▓ ░▒▓░  ▒ ░░   ▒ ▒▓▒ ▒ ░${ENDCOLOR}"
        echo -e "${RED}  ░ ▒ ▒░ ${BLUE}░▒ ░       ░ ▒ ▒░   ░▒ ░ ▒░    ░    ░ ░▒  ░  ${ENDCOLOR}"
        echo -e "${RED}░ ░ ░ ▒  ${BLUE}░░       ░ ░ ░ ▒     ░   ░   ░ ░    ░  ░  ░  ${ENDCOLOR}"
        echo -e "${RED}    ░ ░  ${BLUE}             ░ ░     ░                    ░  ${ENDCOLOR}"
        echo -e "${GREEN}░▄▀▀░▄▀▄░█▄░█▒█▀▄▒██▀▒█▀▄${ENDCOLOR}"
        echo -e "${GREEN}░▀▄▄░▀▄▀░█▒▀█░█▀▒░█▄▄░█▀▄  ${BLUE}https://github.com/Conper${ENDCOLOR}"
	echo -e "${GREEN}----------------------------------------------------------------------------${ENDCOLOR}"
}

#------- Save or not the result -------#
save (){
	echo -n -e "${BLUE}Save the result?  (y/n)  --> ${ENDCOLOR}"
        read OPT
        OPT="${OPT,,}"
        if [ $OPT == "yes" ] || [ $OPT == "y" ]; then
		echo -e "${YELLOW}You chose: ${GREEN}YES${ENDCOLOR}"
                echo -e "${BLUE}Type file name: ${ENDCOLOR}"
        	read  FILE_NAME
        	touch $FILE_NAME
        	echo -n -e "\r${GREEN}----------------------------------------------------------------------------\n${ENDCOLOR}" > $FILE_NAME
        	echo -e "${LIGHT_YELLOW}OS: $SYSTEM ${ENDCOLOR}" >> $FILE_NAME
        	echo -e "$IP" >> $FILE_NAME
        	echo -e "${BLUE}PORT ${RED}| ${GREEN}STATE ${RED}| ${YELLOW}SERVICE ${RED}| ${LIGHT_YELLOW}VERSION${ENDCOLOR}" >> $FILE_NAME
        	echo -e "$SCAN" >> $FILE_NAME
        	end >> $FILE_NAME
		echo " "
                echo -e "${YELLOW}Thanks for using the script :D${ENDCOLOR}"

        else
		echo -e "${YELLOW}You chose: ${RED}NO${ENDCOLOR}"
                echo " "
		echo -e "${YELLOW}Thanks for using the script :D${ENDCOLOR}"
        fi
}

#------------------- OPTIONS -------------------#

#------- Help option -------#
if [ "$1" == "-h" ]; then

	echo -e "${GREEN}\n---------- How to use this program? ----------${ENDCOLOR}"
	echo -e "${GREEN}\n  With a file --> ${YELLOW}oports.sh ${LIGHT_YELLOW}-f file_directory${ENDCOLOR}"
	echo -e "${GREEN}  With IP --> ${YELLOW}oports.sh ${LIGHT_YELLOW}-i IP/Domain ${BLUE}-o file_name${ENDCOLOR}"
	echo -e "${GREEN}				  	 ↑     ↑${ENDCOLOR}"
	echo -e "${GREEN}                                NMAP output scan file name${ENDCOLOR}"
	echo " "
	echo -e "${LIGHT_YELLOW}  At the end of the script you will have the option to save or not the result.${ENDCOLOR}"
#------- If you don't put any option -------#
elif [ -z "$1" ]; then

	echo "${LIGHT_YELLOW}Type --> oports.sh -h <-- to know how to use it${ENDCOLOR}"

#------- Option with IP/DOMAIN -------#
elif [ "$1" == "-i" ] && [ "$3" = "-o" ]; then

	echo -e "${BLUE}THIS PROCESS CAN TAKE FROM ONE TO SEVERAL MINUTES. PLEASE WAIT.    (~ 1-10 minutes)${ENDCOLOR}"
        nmap -p- -sV -n -Pn $2 -oN $4 > /dev/null
	SCAN=$(cat "./$4" | grep 'open ' | awk -v blue="$BLUE" -v green="$GREEN" -v yellow="$YELLOW" -v light_yellow="$LIGHT_YELLOW" '{print blue $1, green $2, yellow $3, light_yellow $4 " " $5 " " $6 " " $7 " " $8 " "  $9 " " $10 " " $11 " " $12 " " $13 " " $14 endcolor}')
	IP=$(cat "./$4" | grep 'Nmap scan report' | awk -v red="$RED" -v endcolor="$ENDCOLOR" '{print "IP of the victim machine: " red $5 endcolor}')
	ttl
        echo -n -e "\r${GREEN}----------------------------------------------------------------------------\n${ENDCOLOR}"
        echo -e "${LIGHT_YELLOW}OS: $SYSTEM ${ENDCOLOR}"
        echo -e "$IP"
        echo -e "${BLUE}PORT ${RED}| ${GREEN}STATE ${RED}| ${YELLOW}SERVICE ${RED}| ${LIGHT_YELLOW}VERSION${ENDCOLOR}"
	echo -e "$SCAN"
	end
	save

#------- Option with a file of a scan -------#
elif [ "$1" == "-f" ]; then

	FILE=$2
	echo -n -e "${RED}THE SCRIPT IS RUNNING${ENDCOLOR}"
	sleep 0.25
	i=0
	while [ $i -lt 3 ];do
		echo -n -e "${RED}.${ENDCOLOR}"
		sleep 0.25
		((i++))
	done

	IP=$(cat "$FILE" | grep 'Nmap scan report' | awk -v red="$RED" -v endcolor="$ENDCOLOR" '{print "IP of the victim machine: " red $5 endcolor}')
	ttl
	SCAN=$(cat "$FILE" | grep 'open ' | awk -v blue="$BLUE" -v green="$GREEN" -v yellow="$YELLOW" -v light_yellow="$LIGHT_YELLOW" '{print blue $1, green $2, yellow $3, light_yellow $4 " " $5 " " $6 " " $7 " " $8 " "  $9 " " $10 " " $11 " " $12 " " $13 " " $14 endcolor}')
        echo -n -e "\r${GREEN}----------------------------------------------------------------------------\n${ENDCOLOR}"
        echo -e "${LIGHT_YELLOW}OS: $SYSTEM ${ENDCOLOR}"
        echo -e "$IP"
        echo -e "${BLUE}PORT ${RED}| ${GREEN}STATE ${RED}| ${YELLOW}SERVICE ${RED}| ${LIGHT_YELLOW}VERSION${ENDCOLOR}"
	echo -e "$SCAN"
	end
	save

#------- Anything else -------#
else
	echo "${RED}Type --> oports.sh -h <-- to know how to use it${ENDCOLOR}"

fi
