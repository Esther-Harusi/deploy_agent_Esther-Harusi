#!/usr/bin/env bash
read -p "Enter attendance_tracker_$name" name
project_dir="attendance_tracker_$name"
mkdir -p "$project_dir"
mkdir -p "$project_dir/Helpers"
mkdir -p "$project_dir/reports"
touch "$project_dir/attendance_checker.py"
echo "checking if python is installed"
if python3 --version &> /dev/null
then
        echo "python3 is installed"
else
        echo "python3 not found"
        exit 1
fi
    
cleanup_on_interruption() {
      echo -e "\n Process cancelled!Cleaning up"
   if [ -d "$project_dir" ]; then
           archive_name="${project_dir}_archive.tar.gz"
           echo "Archiving current state into $archive_name.."
           tar -czf "$archive_name" "$project_dir"
           echo "Deleting incomplete project directory"
           rm -rf "$project_dir"
           echo "safe and clean exiting"
   fi
           exit 1 
}
trap cleanup_on_interruption SIGINT

cat > "$project_dir/attendance_checker.py" <<EOF
import csv
import json
import os
from datetime import datetime

def run_attendance_check():
    # 1. Load Config
    with open('Helpers/config.json', 'r') as f:
        config = json.load(f)
    
    # 2. Archive old reports.log if it exists
    if os.path.exists('reports/reports.log'):
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        os.rename('reports/reports.log', f'reports/reports_{timestamp}.log.archive')

    # 3. Process Data
    with open('Helpers/assets.csv', mode='r') as f, open('reports/reports.log', 'w') as log:
        reader = csv.DictReader(f)
        total_sessions = config['total_sessions']
        
        log.write(f"--- Attendance Report Run: {datetime.now()} ---\n")
        
        for row in reader:
            name = row['Names']
            email = row['Email']
            attended = int(row['Attendance Count'])
            
            # Simple Math: (Attended / Total) * 100
            attendance_pct = (attended / total_sessions) * 100
            
            message = ""
            if attendance_pct < config['thresholds']['failure']:
                message = f"URGENT: {name}, your attendance is {attendance_pct:.1f}%. You will fail this class."
            elif attendance_pct < config['thresholds']['warning']:
                message = f"WARNING: {name}, your attendance is {attendance_pct:.1f}%. Please be careful."
            
            if message:
                if config['run_mode'] == "live":
                    log.write(f"[{datetime.now()}] ALERT SENT TO {email}: {message}\n")
                    print(f"Logged alert for {name}")
                else:
                    print(f"[DRY RUN] Email to {email}: {message}")

if __name__ == "__main__":
    run_attendance_check()
EOF
cat > "$project_dir/Helpers/assets.csv" <<EOF
Email,Names,Attendance Count,Absence Count
alice@example.com,Alice Johnson,14,1
bob@example.com,Bob Smith,7,8
charlie@example.com,Charlie Davis,4,11
diana@example.com,Diana Prince,15,0
EOF
cat > "$project_dir/Helpers/config.json" <<EOF
{
    "thresholds": {"warning": 75, "failure": 50},
    "run_mode": "live",
    "total_sessions": 15
}
EOF

cat > "$project_dir/reports/reports.log" <<EOF
--- Attendance Report Run: 2026-02-06 18:10:01.468726 ---
[2026-02-06 18:10:01.469363] ALERT SENT TO bob@example.com: URGENT: Bob Smith, your attendance is 46.7%. You will fail this class.
[2026-02-06 18:10:01.469424] ALERT SENT TO charlie@example.com: URGENT: Charlie Davis, your attendance is 26.7%. You will fail this class.
EOF
echo "Current thresholds: Warning=75%, Failure=50%"
read -p "Do you want to update attendance thresholds?(yes/no):" update_choice
if [[ "$update_choice" == "yes" || "$update_choice" == "Yes" ]]; then
  read  -p "Enter new Warning threshold (%):" Warning_value
  read -p "Enter new Failure threshold (%):" Failure_value
fi
sed -i "s/\"warning\": [0-9]*/\"warning\": $Warning_value/" "$project_dir/Helpers/config.json"
sed -i "s/\"failure\": [0-9]*/\"failure\": $Failure_value/" "$project_dir/Helpers/config.json"

if grep -q "\"warning\": $Warning_value" "$project_dir/Helpers/config.json"; then
    echo " Success: The file was updated correctly."
else
    echo " Error: The update failed."
fi

touch "$project_dir/reports/reports.log"
ls -la | grep "attendance_tracker_.*archive.tar.gz"
