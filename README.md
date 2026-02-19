# deploy_agent_Esther-Harusi
student attendance automation script.
This project tracks student attendance,and evaluate it based on the given thresholds,then send a warning or failure alert.
It also has a trap signal that cleans,and saves the data to an archive file and then exits safely in case of an interruption.

How to run the script:
 1. Make the script executable using:chmod +x setup_project.sh
2.run the script using: ./setup_project.sh
3. Run the python file:python3 attendance_checker.py -this only runs after creation of the correct project directories and files have beeb created by running the setup_project.sh script.

How to Trigger the Archive feature:
1.We use the trap signal Trap and SIGINT.
2.to trigger it presss ctrl+c,  when the script is running.
