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
