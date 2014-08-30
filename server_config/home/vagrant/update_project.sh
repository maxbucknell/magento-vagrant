#! /bin/bash
# Update a project and all dependencies.

# Assumed to be the project root
cd /var/www/magento

# Get any changes to the project repository.
# - New modules
# - New versions
# - Removed modules

# If no branch is given, we check master out
BRANCH=$1
: ${BRANCH:="master"}

# Check out latest version of a branch, disallow local modifications.
# Remember to commit or stash your changes, kids!
git fetch --all
git checkout $BRANCH
git reset --hard "origin/$BRANCH"

# Install dependencies
composer.phar update

# Compile stylesheets
/home/vagrant/compass_compile.sh

