#!/bin/bash

print_env () {
  echo "FINAGLE_USE_NETTY_4_SNAPSHOT=$FINAGLE_USE_NETTY_4_SNAPSHOT"
  echo "FINAGLE_NETTY_4_VERSION=$FINAGLE_NETTY_4_VERSION"
  echo "FINAGLE_NETTY_4_TCNATIVE_VERSION=$FINAGLE_NETTY_4_TCNATIVE_VERSION"
}

unset_env() {
  unset FINAGLE_NETTY_4_VERSION
  unset FINAGLE_NETTY_4_TCNATIVE_VERSION
  unset FINAGLE_USE_NETTY_4_SNAPSHOT
  print_env
}

if [ $# -ne 1 ]; then
  USAGE_MSG=('usage: source ' $0 ' <true|false>')
  echo "${USAGE_MSG[*]}" 1>&2
  echo '  true            Netty SNAPSHOT version info can be sourced into environment variables for Finagle sbt build'
  echo '  false           Netty SNAPSHOT version info will be unset from environment variables'
  echo -e '\n\nDefault usage is "false", ensuring environment variables are unset:'
  unset_env
  exit 0
fi

USE_SNAPSHOT=$1

if [ "$USE_SNAPSHOT" = "true" ]; then
  echo "Setting Finagle Netty Snapshot environment variables"
  echo "Loading latest Netty info..."
  FILE=netty4-snapshot-pom.xml
  curl -s --connect-timeout 5 --max-time 10 --retry 5 --retry-max-time 60 https://raw.githubusercontent.com/netty/netty/4.1/pom.xml > $FILE
  echo "Parsing Netty version info..."
  FINAGLE_USE_NETTY_4_SNAPSHOT=true
  FINAGLE_NETTY_4_VERSION=$(xmlstarlet sel -N mvn='http://maven.apache.org/POM/4.0.0' -t -m '/mvn:project/mvn:version' -v . -n < $FILE)
  FINAGLE_NETTY_4_TCNATIVE_VERSION=$(xmlstarlet sel -N mvn='http://maven.apache.org/POM/4.0.0' -t -m '/mvn:project/mvn:properties/mvn:tcnative.version' -v . -n < $FILE)
  rm $FILE

  export FINAGLE_USE_NETTY_4_SNAPSHOT
  export FINAGLE_NETTY_4_VERSION
  export FINAGLE_NETTY_4_TCNATIVE_VERSION

  print_env
else
  echo "Using released Netty version. Unsetting Finagle Netty Snapshot environment variables"
  unset_env
fi
