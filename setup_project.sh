#!/usr/bin/env bash
read -p "Enter attendance_tracker_$name" name
project_dir="attendance_tracker_$name"
mkdir -p "$project_dir"
mkdir -p "$project_dir/Helpers"
mkdir -p "$project_dir/reports"
mkdir -p "$project_dir/attendance_checker.py"

	
