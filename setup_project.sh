#!/usr/bin/env bash
read -p "Enter attendance_tracker_$name" name
project_dir="attendance_tracker_$name"
mkdir -p "$project_dir"
mkdir -p "$project_dir/Helpers"
mkdir -p "$project_dir/reports"
mkdir -p "$project_dir/attendance_checker.py"

echo "checking if python is installed"
if python3 --version &> /dev/null
then
        echo "python3 is installed"
else
        echo "python3 not found"
        exit 1
fi

	
