#!/bin/bash

function format_text() {
    local text=$1
    local text_regex="^[ a-zA-Z0-9\:\.\/\<\>\'\(\)\&-]+$"
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
    esac

    case $3 in
        bold) font_format=$(tput bold) ;;
        underline) font_format=$(tput smul) ;;
        blink) font_format=$(tput blink) ;;
        *) font_format=$(tput sgr0) ;;
    esac

    echo -e "${font_format}${font_color}${text}$(tput sgr0)"
}

function ask_user_yn() {
    while :;
    do
        read -p "Message: " variable_name

        case "" in
            y)  ;;
            n)  ;;
            *)  ;;
        esac
    done
}

# Script Variables
setup_name="Backend-Foundation"
script_path=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
setup_files_path="backend-setup-script"

format_text "Current Directory: ${PWD}" "cyan" "normal"
run_script=""

while :;
do
    read -p "Do you want to run the script in the current directory?: " run_script

    case "${run_script}" in
        y)
            format_text "Running script.\n" "green" "blink"
            break
            ;;
        n)
            format_text "Exiting from script.\n" "red" "bold"
            exit
            ;;
        *)
            format_text "Answer with <y/n> \n" "red" "bold" ;;
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
        format_text "The script will use the GitHub template.\n" "green" "underline" ;;
    *)
        format_text "The script will NOT use the GitHub template.\n" "yellow" "normal";;
esac

# GitHub Repository Creation
if [[ ${github} =~ ^[yY]$ ]]; then
    echo -e "${bold}Creating remote repository from template...${normal}"

    ghrepo=""

    # Keep prompting user for repo name until it is correct.
    while :;
    do
        read -p "Please pick a name for the repository: " ghrepo

        if [[ ${ghrepo} =~ ^[a-zA-Z0-9_\-]+$ ]]; then
            break
        else
            format_text "Invalid Name." "red" "bold"
        fi
    done

    # Create remote repo on GH and clone into current directory.
    # remove line from echo command to use.
    gh repo create ${ghrepo} --private --clone -p https://github.com/DaveRRC/BED-template
    mv ${ghrepo} ${setup_name}
else
    format_text "Skipping GitHub repository creation.\n" "yellow"
    mkdir ${setup_name}
fi

# FOR TESTING PURPOSES
# UNCOMMENT TO USE SCRIPT
#exit

# NPM Module installation.
ask_npm_mods=""

while :;
do
    read -p "Install npm modules?: " ask_npm_mods

    case "${ask_npm_mods}" in
        y)
            format_text "Installing modules...\n" "green" "blink"
            break
            ;;
        n)
            format_text "Skipping module installation.\n" "red" "bold"
            break
            ;;
        *)
            format_text "Answer with <y/n> \n" "red" "bold" ;;
    esac
done

if [[ ${ask_npm_mods} =~ ^[yY]+$ ]]; then install_npm_mods=true ; else install_npm_mods=false ; fi

if $install_npm_mods; then
    # Script Files and Directories creation.
    format_text "Starting installation:\n" "green" "bold"
    npm init -y &> /dev/null
    mv package.json ./${setup_name}
    format_text "Created and moved 'package.json' to ${PWD}/${setup_name}\n"
    sleep 1

    # Install Typescript
    format_text "Installing TypeScript:" "" "bold"
    npm install --prefix ./${setup_name} typescript ts-node @types/node --save-dev
    format_text "TypeScript installed.\n" "green"
    sleep 1

    # Install Express & Morgan
    format_text "Installing Express:" "" "bold"
    npm install --prefix ./${setup_name} express
    npm install --prefix ./${setup_name} @types/express --save-dev
    format_text "Express installed.\n" "green" 
    sleep 1
    format_text "Installing Morgan (HTTP Logging):" "" "bold"
    npm install --prefix ./${setup_name} morgan @types/morgan
    format_text "Morgan installed.\n" "green"
    sleep 1

    # Install Jest
    format_text "Installing Jest:" "" "bold"
    npm install --prefix ./${setup_name} jest ts-jest @types/jest supertest @types/supertest --save-dev
    format_text "Jest installed.\n" "green"
    sleep 1
fi

# Project file creation.
ask_create_structs=""

while :;
do
    read -p "Create project structure? (directories & files): " ask_create_structs

    case "${ask_create_structs}" in
        y)
            format_text "Creating project structure...\n" "green" "blink"
            break
            ;;
        n)
            format_text "Skipping project structure creation.\n" "red" "bold"
            break
            ;;
        *)
            format_text "Answer with <y/n> \n" "red" "bold" ;;
    esac
done

if [[ ${ask_create_structs} =~ ^[yY]+$ ]]; then create_struct=true ; else create_struct=false ; fi

if $create_struct; then
    # Create tsconfig.json file
    if [ -f ./${setup_name}/tsconfig.json ]; then
        format_text "File: 'tsconfig.json' already exists, skipping creation.\n" "yellow"
        sleep 1
    else
        format_text "Creating 'tsconfig.json' file:"
        cp ${script_path}/${setup_files_path}/tsconfig-setup.txt ./${setup_name}/tsconfig.json
        format_text "'tsconfig.json' file created.\n" "green"
        sleep 1
    fi

    # Create src folder and sub-directories
    format_text "Creating directory system:" "" "bold"
    mkdir -p ${setup_name}/src/api/v1/{routes,controllers,services}
    mkdir ${setup_name}/src/constants
    format_text "'src' directory and sub-directories are created.\n" "green"
    sleep 1

    # Create app.ts and server.ts file
    format_text "Creating 'app.ts' & 'server.ts' files:" "" "bold"
    cp ${script_path}/${setup_files_path}/app-setup.txt ./${setup_name}/src/app.ts
    cp ${script_path}/${setup_files_path}/server-setup.txt ./${setup_name}/src/server.ts
    format_text "'app.ts' & 'server.ts' file created in source directory\n" "green"
    sleep 1

    # Create HTTP Constants file
    format_text "Creating 'httpConstants.ts' file:" "" "bold"
    cp ${script_path}/${setup_files_path}/http-status-setup.txt ./${setup_name}/src/constants/httpConstants.ts
    format_text "'app.ts' file created in src/constants directory\n" "" "green"

    # Create Jest configuration file and test directory
    format_text "Creating 'jest.config.js' file & 'test' directory:" "" "bold"
    mkdir ${setup_name}/test
    cp ${script_path}/${setup_files_path}/jest-setup.txt ./${setup_name}/jest.config.js
    format_text "'jest.config.js' file created in root directory\n" "green"
    sleep 1

    # Modify package.json file
    format_text "Modifying scripts section in 'package.json' file:\n" "" "bold"

    package_path="./${setup_name}/package.json"

    if [ -f ${package_path} ];then
        sed -i '7s/.*/\t"start": "ts\-node src\/server.ts",\n/' ${package_path}
        sed -i '8s/.*/\t"build": "tsc",\n/' ${package_path}
        sed -i '9s/.*/\t"test": "jest",\n/' ${package_path}
        sed -i '10s/.*/\t"test:watch": "jest --watch",\n/' ${package_path}
        sed -i '11s/.*/\t"test:coverage": "jest --coverage"/' ${package_path}
        sleep 1
    fi
fi


if [[ !($ask_npm_mods) && !($ask_create_structs) ]];then
    rm -r ${setup_name}
fi

if [[ -d ./${setup_name} ]]; then
    # Requires Tree package to be installed.
    #echo -e "${bold}Directory Tree:${normal}"
    #tree ./${setup_name} -a -I node_modules/ -I .git

    format_text "Listing ./${setup_name}/" "blue" "bold"
    ls -A ${setup_name}
    format_text "Listing ./${setup_name}/src/" "blue" "bold"
    ls -A ${setup_name}/src
fi
