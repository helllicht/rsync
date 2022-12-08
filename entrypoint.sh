#!/bin/bash
set -eu
echo ""
echo "Running deployment..."
echo ""

# check if any required var is missed
if [ -z "${REMOTE_USER+.}" ] || [ -z "${REMOTE_SERVER+.}" ] || [ -z "${LOCAL_DIRECTORY+.}" ] || [ -z "${REMOTE_DIRECTORY+.}" ]; then
  echo ""
  echo "❌ ERROR"
  echo "Missing required variable(s):"
  echo ""

  # echo missed vars for debugging purpose
  if [ -z "${REMOTE_USER+.}" ]; then
    echo "REMOTE_USER"
  fi
  if [ -z "${REMOTE_SERVER+.}" ]; then
    echo "REMOTE_SERVER"
  fi
  if [ -z "${LOCAL_DIRECTORY+.}" ]; then
    echo "LOCAL_DIRECTORY"
  fi
  if [ -z "${REMOTE_DIRECTORY+.}" ]; then
    echo "REMOTE_DIRECTORY"
  fi

  # exit script
  echo ""
  echo "exit"
  exit 1
fi

# check if either password or key is set - exit if none or both
if [ -z ${REMOTE_PASSWORD+.} ] && [ -z ${PRIVATE_KEY+.} ]; then
  echo "No password or ssh-key found."
  echo "Please set remote_password OR private_key."
  exit 1
elif [ -z ${REMOTE_PASSWORD+.} ]; then
  echo "🔐 Authorization via ssh-key"
  echo ""
  AUTHORIZATION_METHOD=SSHKEY
elif [ -z ${PRIVATE_KEY+.} ]; then
  echo "🗝 Authorization via password"
  echo ""
  AUTHORIZATION_METHOD=PASSWORD
else
  echo "Please either set remote_password OR private_key."
  exit 1
fi

echo 'done'
exit 0

# check if DRY_RUN is set
if [ -z "$DRY_RUN" ]; then
  echo ""
  echo "❌ ERROR:"
  echo "Missing required variable: dry_run"
  exit 1
fi

if [ "$AUTHORIZATION_METHOD" = "PASSWORD" ]; then
  # add sshpass to package list, to install
  ADDITIONAL_PACKAGES=sshpass

  # add sshpass command to authorize by password
  SSHPASS_COMMAND="sshpass -p $REMOTE_PASSWORD"
  SSH_KEY_SWITCH=
else
  # create private key file
  mkdir -p ~/.ssh
  touch ~/.ssh/private_key
  echo "$PRIVATE_KEY" >~/.ssh/id_rsa
  chmod 600 ~/.ssh/private_key

  ADDITIONAL_PACKAGES=
  SSHPASS_COMMAND=
fi

# set if dry run or not
$DRY_RUN = $DRY_RUN | tr '[:upper:]' '[:lower:]'
if [ $DRY_RUN = false ]; then
  echo "🚨 NOT dry run."
  echo ""
  DRY_SWITCH=
else
  echo "🐫 Performing dry run."
  echo "If you did not intend to perform a dry run set dry_run to false."
  echo ""
  DRY_SWITCH=n
fi

echo "Installing packages: rsync ssh $ADDITIONAL_PACKAGES ..."
echo ""

# install packages
apt-get update
apt-get install rsync ssh $ADDITIONAL_PACKAGES -y

echo ""
echo 'Installed ✅'
echo ""

# set if --delete switch is used
if [ -z ${DELETE_FROM_REMOTE_DIRECTORY+.} ] || [ ${DELETE_FROM_REMOTE_DIRECTORY,,} != true ]; then
  echo "🗑  NOT using delete switch."
  echo ""
  DELETE_FLAG=
else
  echo "🗑  Setting delete switch: --delete"
  echo ""
  DELETE_FLAG="--delete"
fi

# set if exclude file is used
if [ -z ${EXCLUDE_FILE+.} ]; then
  echo "⛔️ No exclude file"
  echo ""
  EXCLUDE_FILE=
else
  echo "⛔️ Using exclude file: $EXCLUDE_FILE"
  echo "Exclude file contains:"
  cat $EXCLUDE_FILE
  echo ""
  echo ""
fi

# set the used port
if [ -z "$REMOTE_PORT" ]; then
  echo "🚪 Using default port"
  echo ""
  PORT_SWITCH=
else
  echo "🚪 Using port $REMOTE_PORT"
  echo ""
  PORT_SWITCH="-p $REMOTE_PORT"
fi

echo "Running rsync..."
echo ""
$SSHPASS_COMMAND rsync -avzr$DRY_SWITCH $DELETE_FLAG --exclude-from="$EXCLUDE_FILE" --rsh="ssh -o StrictHostKeyChecking=no $PORT_SWITCH" $LOCAL_DIRECTORY $REMOTE_USER@$REMOTE_SERVER:$REMOTE_DIRECTORY
echo ""
echo "Done ✅"
