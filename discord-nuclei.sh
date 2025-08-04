#!/bin/bash
discord_webhook="YOUR__WEBHOOK"
LOG_FILE="nuclei_scan.log"
DISCORD_LIMIT=2000
send_discord_notification(){
  message="$1"
  json_payload=$(jq -n --arg msg "$message" '{"content": $msg}')
  curl -s -H "Content-Type: application/json" -d "$json_payload" "$discord_webhook"
}

strip_color(){

echo "$1" | sed 's/\x1b\[[0-9;]*m//g'


}
split_message(){
	local log_message="$1"
	local max_length="$2"
	local chunk
        while [[ ${#log_message} -gt $max_length ]]; do
           chunk="${log_message:0:$max_length}"
           log_message="${log_message:$max_length}"
           send_discord_notification "$chunk"
        done


        if [[ -n "$log_message" ]]; then
           send_discord_notification "$log_message"
        fi


}
perform_recon(){
  local target="$1"
  echo "Scanning $target with nuclei"
  nuclei_output=$(nuclei -u "$target" -severity medium,high,critical)
  nuclei_output_clean=$(strip_color "$nuclei_output")
  echo "$nuclei_output_clean" >> "$LOG_FILE" 
  discord_message="Vulnerabilities found on $target :\`\`\`$nuclei_output_clean\`\`\`" 
  if [[  ${#discord_message} -gt $DISCORD_LIMIT ]]; then
     echo "output exceed 200 charachter splitting message"
     split_message "$discord_message" "$DISCORD_LIMIT"
  else
     send_discord_notification "$discord_message"
  fi
}

if [  "$1" = "-f" ]; then
    if [ ! -f "$2" ]; then
       echo "File $2 not found."
       exit 1
    fi
    while IFS= read -r Target; do 
          perform_recon "$Target"
    done < "$2"
else
     Targets=("$@")
     for TARGET in "${Targets[@]}"; do
         perform_recon "$TARGET"
     done
fi
echo "Nuclei scan complete ...Results saved im ${LOG_FILE}."
