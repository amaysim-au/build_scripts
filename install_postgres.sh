#!/bin/bash -e
#
#  Usage: ./install_postgres.sh VERSION USERNAME PASSWORD DATABASE_NAME

PSQL_PORT=${PSQL_PORT:-5433}

function addPostgresqlRepo() {
  echo "adding official postgresql repo"
  sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release  -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
  wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | sudo apt-key add -
  sudo apt-get update
}

function installPostgresql() {
  local VERSION=$1

  echo "installing postgres ${VERSION}"
  sudo apt-get --yes install postgresql-$VERSION postgresql-contrib-$VERSION
  sudo service postgresql start $VERSION
}

function createPostgresqlUser() {
  local USERNAME=$1
  local PASSWORD=$2
  echo "creating postgres user ${USERNAME}"
  pushd /tmp
  sudo -u postgres -- createuser -p $PSQL_PORT -s $USERNAME
  sudo -u postgres -- psql -p $PSQL_PORT -c "ALTER USER ${USERNAME} WITH PASSWORD '${PASSWORD}';"
  popd
}

function createPostgresqlDB() {
  local USERNAME=$1
  local DATABASE=$2

  echo "creating postgres database ${DATABASE} for user ${USERNAME}"
  sudo -u postgres -- createdb -p $PSQL_PORT -O $USERNAME $DATABASE
}

addPostgresqlRepo
install_postgres $1
createPostgresqlUser $2 $3
createPostgresqlDB $2 $4
