# Note that after.sh, before.sh.erb and script.sh.erb all run
# inside the container specified in submit.yml.erb.
# This script starts websockify instance and connects it to
# the assuming already running VNC server started in before.sh.erb.

export WEBSOCKIFY_CMD="/usr/bin/websockify"
export WS_LOGFILE="${LOGDIR}/websockify.log"
echo "$(date) WEBSOCKIFY_CMD ${WEBSOCKIFY_CMD}" >> $LOGFILE

clean_up()
{
  echo CLEAN UP called >> $LOGFILE
}

change_passwd ()
{
  echo "Setting VNC password..." >> "${LOGFILE}"
  password=$(create_passwd "8")
  spassword=${spassword:-$(create_passwd "8")}
  (
    umask 077
    echo -ne "${password}\n${spassword}" | vncpasswd -f > "vnc.passwd"
    sed -i "s/^password:.*/password: $password/" connection.yml
    sed -i "s/^spassword:.*/spassword: $spassword/" connection.yml
  )
}

# launches websockify in the background; waiting until the process
# has started proxying successfully.
start_websockify()
{
  # Launch websockify in background and redirect all output to a file.
  echo command ${WEBSOCKIFY_CMD} $1 $2 >> $LOGFILE
  ${WEBSOCKIFY_CMD} $1 $2 &> $WS_LOGFILE &
  local ws_pid=$!
  local counter=0

  # wait till websockify has successfully started
  echo "[websockify]: pid: $ws_pid (proxying $1 ==> $2)" >> $LOGFILE
  echo "[websockify]: log file: $WS_LOGFILE" >> $LOGFILE
  echo "[websockify]: waiting ..." >> $LOGFILE
  until grep -q -i "proxying from :$1" $WS_LOGFILE
  do
    if ! ps $ws_pid > /dev/null; then
      echo "[websockify]: failed to launch!" >> $LOGFILE
      return 1
    elif [ $counter -ge 5 ]; then
      # timeout after ~25 seconds
      echo "[websockify]: timed-out :(!" >> $LOGFILE
      return 1
    else
      sleep 5
      ((counter=counter+1))
    fi
  done
  echo "[websockify]: started successfully (proxying $1 ==> $2)" >> $LOGFILE
  echo $ws_pid
  return 0
}

# Launch websockify websocket server
websocket=$(find_port ${host})
export port=$websocket
[ $? -eq 0 ] || clean_up 1 # give up if port not found

echo "Starting websocket server... $websocket" >> $LOGFILE

ws_pid=$(start_websockify ${websocket} localhost:${app_port})
[ $? -eq 0 ] || clean_up 1 # give up if websockify launch failed

# Set up background process that scans the log file for successful
# connections by users, and change the password after every
# connection
echo "Scanning VNC log file for user authentications..." >> $LOGFILE
while read -r line; do
  if [[ ${line} =~ "Full-control authentication enabled for" ]]; then
    echo READY TO CHANGE PASSSWORD >> $LOGFILE
    change_passwd
  fi
done < <(tail -f --pid=${SCRIPT_PID} "${VNC_LOG}") &
