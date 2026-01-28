#!/bin/bash

function format_text() {
    local text=$1
    local text_regex="^[ a-zA-Z0-9\:\.\/\<\>\'-]+$"
    if [[ ${text} =~ ${text_regex} ]]; then text=$1 ; else text="undefined" ; fi

    local font_color=$2
    local font_format=$3

    case $2 in
        red) font_color=$(tput setaf 1) ;;
        green) font_color=$(tput setaf 2) ;;
        yellow) font_color=$(tput setaf 3) ;;
        blue) font_color=$(tput setaf 4) ;;
        magenta) font_color=$(tput setaf 5) ;;
        cyan) font_color=$(tput setaf 6) ;;
        *) font_color=$(tput setaf 9) ;;
    esac

    case $3 in
        bold) font_format=$(tput bold) ;;
        underline) font_format=$(tput smul) ;;
        blink) font_format=$(tput blink) ;;
        *) font_format=$(tput sgr0) ;;
    esac

    echo -e "${font_format}${font_color}${text}$(tput sgr0)"
}

# Script Variables
setup_name="Backend-Foundation"
script_path=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
setup_files_path="backend-setup-script"

echo -e "${bold}Current Directory: ${PWD}${normal}"
run_script=""

while :;
do
    read -p "Do you want to run the script in the current directory?: " run_script

    case "${run_script}" in
	y)
	    echo -e "Running script.\n"
	    break
            ;;
	n)
	    echo -e "Exiting from script.\n"
	    exit
	    ;;
	*)
	    echo -e "Answer with <y/n>.\n"
    esac
done

# Get flag options.
while getopts g: flag
do
    case "${flag}" in
        g) github=${OPTARG};;
    esac
done

# Modify Code to consider use of GitHub template.
case "${github}" in
    y)
        echo -e "${s_und}The script will use the GitHub template.\n${e_und}";;
    *)
        echo -e "The script will not use the GitHub template.\n";;
esac

# GitHub Repository Creation
if [[ ${github} =~ ^[yY]$ ]]; then
    echo -e "${bold}Creating remote repository from template...${normal}"

    ghrepo=""

    # Keep prompting user for repo name until it is correct.
    while :;
    do
        read -p "Prompt user for repository name: " ghrepo

	if [[ ${ghrepo} =~ ^[a-zA-Z0-9_\-]+$ ]]; then
	    break
	else
	    echo -e "Invalid Name."
	fi
    done

    # Create remote repo on GH and clone into current directory.
    # remove line from echo command to use.
    gh repo create ${ghrepo} --private --clone -p https://github.com/DaveRRC/BED-template
    mv ${ghrepo} ${setup_name}
else
    echo -e "Skipping GitHub repository creation."
    mkdir ${setup_name}
fi

# FOR TESTING PURPOSES
# UNCOMMENT TO USE SCRIPT
#exit

# Script Files and Directories creation.
echo -e "${bold}Starting installation:\n${normal}"
npm init -y &> /dev/null
mv package.json ./${setup_name}
echo -e "Created and moved 'package.json' to ${PWD}/${setup_name}"
sleep 1

# Install Typescript
echo -e "${bold}Installing TypeScript:${normal}"
npm install --prefix ./${setup_name} typescript ts-node @types/node --save-dev
echo -e "TypeScript installed.\n"
sleep 1

# Create tsconfig.json file
if [ -f ./${setup_name}/tsconfig.json ]; then
    echo -e "File: 'tsconfig.json' already exists, skipping creation.\n"
    sleep 1
else
    echo -e "${bold}Creating 'tsconfig.json' file:${normal}"
    cp ${script_path}/${setup_files_path}/tsconfig-setup.txt ./${setup_name}/tsconfig.json
    echo -e "'tsconfig.json' file created.\n"
    sleep 1
fi

# Install Express & Morgan
echo -e "${bold}Installing Express:${normal}"
npm install --prefix ./${setup_name} express
npm install --prefix ./${setup_name} @types/express --save-dev
echo -e "Express installed.\n"
sleep 1
echo -e "${bold}Installing Morgan (HTTP Logging):${normal}"
npm install --prefix ./${setup_name} morgan @types/morgan
echo -e "Morgan installed.\n"
sleep 1

# Create src folder and sub-directories
echo -e "${bold}Creating directory system:${normal}"
mkdir -p ${setup_name}/src/api/v1 ${setup_name}/src/api/v1/routes ${setup_name}/src/api/v1/controllers ${setup_name}/src/api/v1/services
echo -e "'src' directory and sub-directories are created.\n"
sleep 1

# Create app.ts and server.ts file
echo -e "${bold}Creating 'app.ts' & 'server.ts' files:${normal}"
cp ${script_path}/${setup_files_path}/app-setup.txt ./${setup_name}/src/app.ts
cp ${script_path}/${setup_files_path}/server-setup.txt ./${setup_name}/src/server.ts
echo -e "'app.ts' & 'server.ts' file created in source directory\n"
sleep 1

# Install Jest
echo -e "${bold}Installing Jest:${normal}"
npm install --prefix ./${setup_name} jest ts-jest @types/jest supertest @types/supertest --save-dev
echo -e "Jest installed.\n"
sleep 1

# Create Jest configuration file and test directory
echo -e "${bold}Creating 'jest.config.js' file & 'test' directory:${normal}"
mkdir ${setup_name}/test
cp ${script_path}/${setup_files_path}/jest-setup.txt ./${setup_name}/jest.config.js
echo -e "'jest.config.js' file created in root directory\n"
sleep 1

# Modify package.json file
echo -e "${bold}Modifying scripts section in 'package.json' file:${normal}\n"

package_path="./${setup_name}/package.json"

sed -i '7s/.*/\t"start": "ts\-node src\/server.ts",\n/' ${package_path}
sed -i '8s/.*/\t"build": "tsc",\n/' ${package_path}
sed -i '9s/.*/\t"test": "jest",\n/' ${package_path}
sed -i '10s/.*/\t"test:watch": "jest --watch",\n/' ${package_path}
sed -i '11s/.*/\t"test:coverage": "jest --coverage"/' ${package_path}
sleep 1

# Requires Tree package to be installed.
#echo -e "${bold}Directory Tree:${normal}"
#tree ./${setup_name} -a -I node_modules/ -I .git

echo -e "${bold}Listing ./${setup_name}/${normal}"
ls -A ${setup_name}
echo -e "${bold}Listing ./${setup_name}/src/${normal}"
ls -A ${setup_name}/src
