#!/bin/sh

# (File modified to add this attribution)
# Author: matt335672
# https://github.com/matt335672/nest-systemd-user

# Workarounds for enabling multiple sessions when using systemd
#
# Mainly the issue is that a desktop session needs a dedicated dbus,
# but systemd creates a single one for every logged on user.
#
# Using systemd-run or a systemd user unit file it is possible to create 
# a separate systemd-user instance with dedicated XDG_RUNTIME_DIR and DBUS
#
# Main ideas in this script by mwsys.mine.bz

# Units to mask in the created instance
# Uncomment this line and fill in as appropriate for your installation
#UNITS_TO_MASK="pipewire-pulse.service pipewire-pulse.socket"

# We're probably going to use file descriptor 1 for output. Stash it away
# in fd 3 and redirect our fd 1 to stderr to talk to the user
exec 3>&1 >&2

# prepare user environment
prepare_user_environment()
{
    test -f "$XDG_RUNTIME_DIR"/systemd/user.control/systemd-session@.service && return
    install -dm 0700 "$XDG_RUNTIME_DIR"/systemd/user.control
    # Create a unit to wait for the target pid to finish
    {
        echo "[Unit]"
        echo "Description=Wait for XRDP session %i to finish"
        echo "Requires=systemd-session@%i.service"
        echo "ConditionPathExists=%t/systemd-session-%i/wait-for.pid"
        echo
        echo "[Service]"
        echo "Type=simple"
        echo "ExecStart=/bin/sh -c 'XRDP_STARTWM_PID=\$(cat %t/systemd-session-%i/wait-for.pid); while /bin/kill -0 \$XRDP_STARTWM_PID 2>/dev/null; do sleep 5; done; rm %t/systemd-session-%i/wait-for.pid'"
        echo "ExecStopPost=/usr/bin/systemctl --user stop systemd-session@%i.service"
        # optional: remove XDG_RUNTIME_DIR. There could be issues with unmounting $XDG_RUNTIME_DIR/doc
        # echo "ExecStopPost=rm -r %t/systemd-session-%i"
    } >"$XDG_RUNTIME_DIR"/systemd/user.control/wait-for-systemd-session@.service

    #Create the systemd-user session unit file.
    {
        echo "[Unit]"
        echo "Description=XRDP systemd User Manager for display %i"
        echo
        echo "[Service]"
        echo "Type=notify"
        echo "ExecStart=sh %t/systemd_user_session.sh systemd-session-%i"
    } > "$XDG_RUNTIME_DIR"/systemd/user.control/systemd-session@.service
    
    #create the systemd --user wrapper to launch systemd with a clean environment
    #shellcheck disable=SC2016
    echo '#!/bin/sh
test -z "$XDG_RUNTIME_DIR" && exit 1
test -z "$1" && exit 1

SESSION_RUNTIME_DIR="$XDG_RUNTIME_DIR/$1"
install -dm 0700 "$SESSION_RUNTIME_DIR"
oIFS="$IFS"
IFS="
"

# keep only absolutely needed environment variables
for ev in $(env); do
    evn="${ev%%=*}"
    case "$evn" in
        HOME) ;;
        SHELL) ;;
        LANG) ;;
        PATH) ;;
        SYSTEMD_EXEC_PID) ;;
        INVOCATION_ID) ;;
        NOTIFY_SOCKET) ;;
        MANAGERPID) ;;
        *) unset "$evn"
    esac
done

IFS="$oIFS"

XDG_RUNTIME_DIR="$SESSION_RUNTIME_DIR"

export XDG_RUNTIME_DIR

exec /lib/systemd/systemd --user
' > "$XDG_RUNTIME_DIR"/systemd_user_session.sh
    systemctl --user daemon-reload
}

# -----------------------------------------------------------------------------
get_unit_name()
{
    if [ -z "$XDG_RUNTIME_DIR" ]; then
        echo "** Warning - no $XDG_RUNTIME_DIR. Using systemd default" >&2
        XDG_RUNTIME_DIR=/run/user/$(id -u)
    fi
    if [ -z "$DISPLAY" ]; then
        echo "** Warning - no DISPLAY. Assuming test mode" >&2
        unit_name=systemd-session@test
    else
        unit_name=systemd-session@${DISPLAY##*:} ; # e.g. systemd-session@10.0
        unit_name=${unit_name%.*} ; # e.g. systemd-session@10
    fi
}

# -----------------------------------------------------------------------------
# Param : Unit name
get_session_runtime_dir()
{
    session_runtime_dir=$XDG_RUNTIME_DIR/${1%%@*}-${1##*@}
}

# -----------------------------------------------------------------------------
cmd_get()
{
    get_unit_name  ; # Output in 'unit_name'
    get_session_runtime_dir "$unit_name" ; # Output in 'session_runtime_dir'

    test -e "$session_runtime_dir/wait-for.pid" || return
    # Send the required commands to the saved file descriptor
    {
        echo "XDG_RUNTIME_DIR=\"$session_runtime_dir\"" >&3
        echo "DBUS_SESSION_BUS_ADDRESS=\"unix:path=$session_runtime_dir/bus\""
        echo "export XDG_RUNTIME_DIR DBUS_SESSION_BUS_ADDRESS"
    } >&3
}

# -----------------------------------------------------------------------------
cmd_init()
{
    if [ $# != 2 ] && [ "$1" != -p ]; then
        echo "** Need to specify a PID to monitor"
        false
    elif ! kill -0 "$2" >/dev/null 2>&1 ; then
        echo "** '$2' is not a PID which can be monitored"
        false
    else
        target_pid="$2"
        get_unit_name  ; # Output in 'unit_name'
        get_session_runtime_dir "$unit_name" ; # Output in 'session_runtime_dir'

        # Be aware the session runtime directory may still be around
        # from last time
        install -dm 0700 "$session_runtime_dir"
        rm -rf "$session_runtime_dir"/systemd/user.control/
        mkdir -p "$session_runtime_dir"/systemd/user.control/

        if [ -n "$UNITS_TO_MASK" ]; then
            for unit in $UNITS_TO_MASK; do
                ln -s /dev/null \
                    "$session_runtime_dir"/systemd/user.control/"$unit"
            done
        fi

        prepare_user_environment

        #pass pid to monitor to wait-for- unit
        echo "$target_pid" > "$session_runtime_dir"/wait-for.pid
        
        # this will also start systemd-session@
        systemctl --user start wait-for-"$unit_name"
        
        # wait for dbus to be up
        while ! dbus-send "--bus=unix:path=$session_runtime_dir/bus" --dest=org.freedesktop.DBus \
            /org/freedesktop/DBus org.freedesktop.DBus.Hello; do
            sleep 0.5
        done
        
        # Use the 'get' command to display the results. We don't need
        # the command to generate any warnings
        cmd_get >/dev/null 2>&1
    fi
}

# -----------------------------------------------------------------------------
cmd_status()
{
    get_unit_name  ; # Output in 'unit_name'
    systemctl --user status "$unit_name" >&3
}

cmd_prepare()
{
    prepare_user_environment
}

# -----------------------------------------------------------------------------
cmd_help()
{
    cat <<EOF
Usage: $0 [ init | get | prepare | help ]

    init -p <pid>
            Sets up a new systemd --user instance for this DISPLAY.
            Outputs the shell commands needed to communicate with this
            instance.

            The specified pid is polled. When it disappears, the
            systemd --user instance is wound up.

    get     Used after 'init' to find the existing private systemd --user
            instance for this DISPLAY.
            Outputs the shell commands needed to communicate with this
            instance. If the instance is not running or already terminated
            this command does nothing

    status  Displays the status of any private systemd --user
            instance for this DISPLAY.
            Does not work within the context created by 'init' or 'get'

    prepare installs systemd.unit files in the current systemd-user context.
            a custom systemd-user instance may be manually spawned with
            systemctl --user start systemd-session@<some name>

    help    Displays this help
EOF
}

# -----------------------------------------------------------------------------
case "$1" in
    get | init | status | help | prepare)
        func=cmd_$1
        shift
        $func "$@"
        exit $?
        ;;
    *)  echo "Unrecognised command '$1'. Use \"$0 help\" for info" >&2
        false
esac

exit $?
