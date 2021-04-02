#!/bin/sh

# Exit if a command exits with non-zero status
set -e

# Prints command and args as they execute
set -x

# Error if variable is unset when using
set -u

# TODO: readme file exists check
# optional params validation in case empty string is passed


# ****************************************************************************************************
# ****************************************************************************************************
# ****************************************  Parameter Check  *****************************************
# ****************************************************************************************************
# *********************************************  Start  **********************************************
# ****************************************************************************************************
# ****************************************************************************************************
# ****************                                                                   *****************
# ****************    Check for the mandatory parameters and optional parameters.    *****************
# ****************    If any mandatory parameter is missing then terminate the       *****************
# ****************    script with non-zero code. If any optional parameter is        *****************
# ****************    missing then assign the default value to those parameters.     *****************
# ****************                                                                   *****************
# ****************************************************************************************************
# ****************************************************************************************************

echo "Validating parameters..."

# Mandatory parameter check - Start
if [[ -z "${INPUT_SOURCE_BRANCH}" ]]; then
    echo "Source branch must be specified"
    return -1
fi

if [[ -z "${INPUT_TARGET_REPO}" ]]; then
    echo "Target repo must be specified"
    return -1
fi

if [[ -z "${INPUT_USER_EMAIL}" ]]; then
    echo "Email must be specified"
    return -1
fi

if [[ -z "${INPUT_USER_NAME}" ]]; then
    echo "Username must be specified"
    return -1
fi
# Mandatory parameter check - End


# Assign values to optional parameters - Start
if [[ -z "${INPUT_TARGET_BRANCH}" ]]; then
    echo "No value specified for 'target_branch'. Taking default branch - 'main'."
    INPUT_TARGET_BRANCH="main"
fi

if [[ -z "${INPUT_COMMIT_MESSAGE}" ]]; then
    echo "No commit message specified. Taking default commit message."
    INPUT_COMMIT_MESSAGE="Application deployed by user ${INPUT_USER_NAME} from https://github.com/${GITHUB_REPOSITORY}.git using the commit ${GITHUB_SHA}"
fi

# Convert delete_history variable to lowercase and validate it
INPUT_DELETE_HISTORY=$(echo "${INPUT_DELETE_HISTORY}" | tr "[:upper:]" "[:lower:]")
echo "${INPUT_DELETE_HISTORY}"
if [[ "${INPUT_DELETE_HISTORY}" != true && "${INPUT_DELETE_HISTORY}" != false ]]; then
    echo "Incorrect value passed for 'delete_history'"
    return -1
fi
# Assign values to optional parameters - End

echo "Parameters validated."

# ****************************************************************************************************
# ****************************************************************************************************
# ****************************************  Parameter Check  *****************************************
# ****************************************************************************************************
# **********************************************  End  ***********************************************
# ****************************************************************************************************
# ****************************************************************************************************



# ****************************************************************************************************
# ****************************************************************************************************
# *********************************  Build the Angular application  **********************************
# ****************************************************************************************************
# *********************************************  Start  **********************************************
# ****************************************************************************************************
# ****************************************************************************************************
# ****************                                                                   *****************
# ****************    Check for the mandatory parameters and optional parameters.    *****************
# ****************    If any mandatory parameter is missing then terminate the       *****************
# ****************    script with non-zero code. If any optional parameter is        *****************
# ****************    missing then assign the default value to those parameters.     *****************
# ****************                                                                   *****************
# ****************************************************************************************************
# ****************************************************************************************************

echo "Starting build..."

# Create a temporary directory for cloning the source and target repos
CLONE_REPO=$(mktemp -d)

# Store the source repo path
SOURCE_REPO="${CLONE_REPO}/source"

# Create source repo inside CLONE_REPO
cd "${CLONE_REPO}"
mkdir -p "${SOURCE_REPO}"

# Clone the source github repo
git clone --single-branch --branch "${INPUT_SOURCE_BRANCH}" "https://github.com/${GITHUB_REPOSITORY}.git" "${SOURCE_REPO}"


# Build the Angular app - Start
cd "${SOURCE_REPO}"
npm install
npm run build -- --prod --output-path dist/
# Build the Angular app - End

echo "Build complete"

# ****************************************************************************************************
# ****************************************************************************************************
# *********************************  Build the Angular application  **********************************
# ****************************************************************************************************
# **********************************************  End  ***********************************************
# ****************************************************************************************************
# ****************************************************************************************************



# ****************************************************************************************************
# ****************************************************************************************************
# ****************************  Copy distribution bundle to target repo  *****************************
# ****************************************************************************************************
# *********************************************  Start  **********************************************
# ****************************************************************************************************
# ****************************************************************************************************
# ****************                                                                   *****************
# ****************    Check for the mandatory parameters and optional parameters.    *****************
# ****************    If any mandatory parameter is missing then terminate the       *****************
# ****************    script with non-zero code. If any optional parameter is        *****************
# ****************    missing then assign the default value to those parameters.     *****************
# ****************                                                                   *****************
# ****************************************************************************************************
# ****************************************************************************************************

echo "Starting deployment..."

# Store the target repo path
TARGET_REPO="${CLONE_REPO}/target"
echo "${TARGET_REPO}"

# Create target repo inside CLONE_REPO
cd "${CLONE_REPO}"
mkdir -p "${TARGET_REPO}"

# Clone the target github repo
git clone --single-branch --branch "${INPUT_TARGET_BRANCH}" "https://x-access-token:${API_TOKEN_GITHUB}@github.com/${INPUT_TARGET_REPO}.git" "${TARGET_REPO}"
cd "${TARGET_REPO}"


# If $INPUT_DELETE_HISTORY is set to 'true' then reset the .git folder and initialize it again
if [[ "${INPUT_DELETE_HISTORY}" == "true" ]]; then
    echo "Deleting history..."
    rm -rf .git/
    git init
    git config user.email "${INPUT_USER_EMAIL}"
    git config user.name "${INPUT_USER_NAME}"
    git branch -M "${INPUT_TARGET_BRANCH}"
    git remote add origin "https://x-access-token:${API_TOKEN_GITHUB}@github.com/${INPUT_TARGET_REPO}.git"
    echo "History deleted"
fi


# Copy the contents from SOURCE_REPO/dist to TARGET_REPO
cp -r "${SOURCE_REPO}/dist" "${TARGET_REPO}/"


# Check if custom README.md is provided
if [[ ! -z "${INPUT_README}" ]]; then
    cp "${SOURCE_REPO}/${INPUT_README}" "${TARGET_REPO}/README.md"
fi


# Push the repo to github
git add .
git commit -m "${INPUT_COMMIT_MESSAGE}"
git push -u origin "${INPUT_TARGET_BRANCH}"

echo "Deployment complete."

# ****************************************************************************************************
# ****************************************************************************************************
# ****************************  Copy distribution bundle to target repo  *****************************
# ****************************************************************************************************
# **********************************************  End  ***********************************************
# ****************************************************************************************************
# ****************************************************************************************************
