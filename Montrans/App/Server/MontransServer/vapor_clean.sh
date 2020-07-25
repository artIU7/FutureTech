#!/bin/bash
echo "Cleaner Vapor :: $LOGNAME "
echo "In Path :"
pwd
sudo rm -Rf .circleci
echo "Complete"
sudo rm -Rf .git
echo "Complete"
sudo rm .dockerignore
echo "Complete"
sudo rm .gitignore
echo "Complete"
sudo rm CONTRIBUTING.md
echo "Complete"
sudo rm README.md
echo "Complete"
sudo rm web.Dockerfile
echo "Complete"



