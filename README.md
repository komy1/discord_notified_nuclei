This script performs automated vulnerability scans on one or more targets using nuclei, filters out ANSI color codes from the output, and delivers the results to a configured Discord webhook.

Results are logged to a local file (nuclei_scan.log).

Large messages are automatically split to fit within Discord's 2000-character message limit.

You can scan a single target or multiple targets from a file.
usage :-
chmod +u discord-nuclei.sh
./discord-nuclei.sh YOUR_target
