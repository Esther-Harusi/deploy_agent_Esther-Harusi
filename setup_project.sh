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

cat > "$project_dir/attendace_checker.py" <<'EOF'
import csv, json, os
from datetime import datetime

def run_attendance_check():
    with open('Helpers/config.json') as f: config = json.load(f)
    if os.path.exists('reports/reports.log'):
        os.rename('reports/reports.log', f'reports/reports_{datetime.now():%Y%m%d_%H%M%S}.log.archive')
    
    with open('Helpers/assets.csv') as f, open('reports/reports.log', 'w') as log:
        reader = csv.DictReader(f)
        total = config['total_sessions']
        log.write(f"--- Attendance Report Run: {datetime.now()} ---\n")
        
        for row in reader:
            name, email, attended = row['Names'], row['Email'], int(row['Attendance Count'])
            pct = (attended / total) * 100
            msg = ""
            if pct < config['thresholds']['failure']:
                msg = f"URGENT: {name}, your attendance is {pct:.1f}%. You will fail this class."
            elif pct < config['thresholds']['warning']:
                msg = f"WARNING: {name}, your attendance is {pct:.1f}%. Please be careful."
            
            if msg and config['run_mode'] == "live":
                log.write(f"[{datetime.now()}] ALERT SENT TO {email}: {msg}\n")
                print(f"Logged alert for {name}")

if __name__ == "__main__": run_attendance_check()
}
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

echo "Current thresholds: Warning=75%, Failure=50%"
read -p "Do you want to update attendance thresholds?(yes/no):" update_choice

