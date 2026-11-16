#!/bin/bash
psql_host=$1
psql_port=$2
db_name=$3
psql_user=$4
psql_password=$5

# Check # of args
if [ "$#" -ne 5 ]; then
    echo "Illegal number of parameters"
    exit 1
fi

#Collect hardware specifications
hostname=$(hostname -f)
cpu_number=$(lscpu | awk -F: '/^CPU\(s\):/ {print $2}' | xargs)
cpu_architecture=$(uname -m)
cpu_model=$(lscpu | grep 'Model name:' | cut -d ':' -f2- | xargs)
# Collect CPU speed in MHz
cpu_mhz=$(grep -m1 'cpu MHz' /proc/cpuinfo | cut -d ':' -f2 | xargs)
# Collect L2 cache size in KB
l2_cache=$(getconf LEVEL2_CACHE_SIZE)
l2_cache=$((l2_cache / 1024))
# Collect total memory in KB
total_mem=$(grep 'MemTotal:' /proc/meminfo | awk '{print $2}')
# Collect current UTC timestamp
timestamp=$(date -u '+%Y-%m-%d %H:%M:%S')

# Construct SQL INSERT statement
insert_stmt="INSERT INTO PUBLIC.host_info
(hostname, cpu_number, cpu_architecture, cpu_model, cpu_mhz, l2_cache, \"timestamp\", total_mem)
VALUES ('$hostname', $cpu_number, '$cpu_architecture', '$cpu_model', $cpu_mhz, $l2_cache, '$timestamp', $total_mem);"

# Set PostgreSQL password
export PGPASSWORD="$psql_password"

# Insert hardware information into PostgreSQL
psql -h "$psql_host" -p "$psql_port" -d "$db_name" -U "$psql_user" -c "$insert_stmt"

exit $?

