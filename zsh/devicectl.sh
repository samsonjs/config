# Add to your zsh profile

function devicepid() {
    if [ -z "$1" ]; then
        echo "Usage: devicepid <device-name> <search>"
        echo "Example: devicepid 'iPhone 15 Pro Max' SpringBoard"
        return 1
    fi

    if [ -z "$2" ]; then
        echo "Usage: devicepid <device-name> <search>"
        echo "Example: devicepid 'iPhone 15 Pro Max' SpringBoard"
        return 1
    fi

    xcrun devicectl device info processes --device "$1" | grep "$2" | awk '{ print $1; }'
}

func devicekill() {
    if [ -z "$1" ]; then
        echo "Usage: devicekill <device-name> <process-name>"
        echo "Example: devicekill 'iPhone 15 Pro Max' SpringBoard"
        return 1
    fi

    if [ -z "$2" ]; then
        echo "Usage: devicekill <device-name> <process-name>"
        echo "Example: devicekill 'iPhone 15 Pro Max' SpringBoard"
        return 1
    fi

    TARGETPID=$(devicepid "$1" "$2")

    if [ $? -ne 0 ]; then
        echo "Couldn't find PID for $2"
        return 1
    fi

    echo "Found PID for $2: $TARGETPID"

    xcrun devicectl device process signal --pid $TARGETPID --signal SIGHUP --device "$1"
}

func respring() {
    if [ -z "$1" ]; then
        echo "Usage: respring <device-name>"
        return 1
    fi

    devicekill "$1" "SpringBoard"
}

func devicereboot() {
    if [ -z "$1" ]; then
        echo "Usage: devicereboot <device-name>"
        return 1
    fi

    xcrun devicectl device reboot --device "$1"
}
