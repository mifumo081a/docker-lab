touch .env
echo -e "UID=$(id -u)\nGID=$(id -g)\nUNAME=$(id -un)\nGNAME=$(id -gn)" > .env