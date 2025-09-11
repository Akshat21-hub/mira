#!/usr/bin/env bash

if [ ! -d "/opt/ros/jazzy" ]; then
    echo "❌ Error: ROS Jazzy not found at /opt/ros/jazzy."
    echo "Only ROS Jazzy is supported by this workspace."
    exit 1
fi

source /opt/ros/jazzy/setup.sh

export RCUTILS_CONSOLE_OUTPUT_FORMAT="[{severity}] [{name}]: {message}"

source_ws () {
    # export PS1="(mira) $PS1"
    source install/setup.bash
}

build_ws () {
    make build
    # colcon build --parallel-workers 4 --cmake-args -DCMAKE_EXPORT_COMPILE_COMMANDS=ON 
    # source_ws
}

install_deps_ws () {
    rosdep install --from-paths src --ignore-src -r -y
}

get_submodules_ws () {
    git submodule update --init --recursive
}

get_latest_ws () {
    git fetch origin
    git reset --hard origin/$(git rev-parse --abbrev-ref HEAD)
}

install_udev_rules () {
    sudo cp misc/96-mira.rules /etc/udev/rules.d/
    sudo udevadm control --reload-rules
    sudo udevadm trigger
}

bs_ws () {
    build_ws
    source_ws
}

fix_vscode_settings () {
    current_dir=$(realpath .)
    settings_file=".vscode/settings.json"
    if [ -f "$settings_file" ]; then
        sed -i "s|/home/david/mira|$current_dir|g" "$settings_file"
    else
        echo "settings.json not found in .vscode directory."
    fi
}