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
    
cleanup_on_interruption() {
      echo -e "\n\n\[!] Process cancelled!Cleaning up"
   if [ -d "$project_dir" ]; then
           archive_name="${project_dir}_archive.tar.gz"
           echo "Archiving current state into $archives_name.."
           tar -czf "$archive_name" "$project_dir"
           echo "Deleting incomplete project directory"
           rm -rf "$project_dir"
           echo "safe and clean exiting"
   fi
   exit 1  
}
trap cleanup_on_interruption SIGINT

rmdir $project_dir/attendance_checker.py
ls -R

