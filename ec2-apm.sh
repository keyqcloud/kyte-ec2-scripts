#!/bin/bash

# Your Slack webhook URL
WEBHOOK_URL="https://hooks.slack.com/services/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"

# Threshold for CPU and memory usage
THRESHOLD=65

# Function to send a message to Slack
send_to_slack() {
  local message=$1
  curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"$message\"}" $WEBHOOK_URL
}

# Function to get EC2 instance ID
get_instance_id() {
  TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" 2>/dev/null)
  if [ -n "$TOKEN" ]; then
    # IMDSv2
    INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/instance-id)
  else
    # IMDSv1
    INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
  fi
}

# Function to check memory usage
check_memory() {
  mem_usage=$(free | awk '/Mem/ {printf("%.0f"), $3/$2 * 100}')
  if [ "$mem_usage" -gt "$THRESHOLD" ]; then
    send_to_slack "Instance $INSTANCE_ID: Memory usage is at ${mem_usage}% which is above the threshold of ${THRESHOLD}%."
  fi
}

# Function to check CPU usage
check_cpu() {
  cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
  if [ "${cpu_usage%.*}" -gt "$THRESHOLD" ]; then
    send_to_slack "Instance $INSTANCE_ID: CPU usage is at ${cpu_usage}% which is above the threshold of ${THRESHOLD}%."
  fi
}

# Get instance ID
get_instance_id

# Run checks
check_memory
check_cpu
