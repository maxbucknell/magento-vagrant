#! /bin/bash
# Install a new Magento project

# Project root
cd /vagrant

# Destroy any previous project
rm -rf htdocs

# Install Magento
git clone "git@bitbucket.org:redbox-digital/magento-ee.git" htdocs

rm -rf htdocs/.git htdocs/composer.json



# Install dependencies
/home/vagrant/update_project.sh $1


