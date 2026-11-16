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

# Save machine statistics in MB and hostname
vmstat_mb=$(vmstat --unit M)
hostname=$(hostname -f)

# Get free memory in MB
memory_free=$(echo "$vmstat_mb" | awk '{print $4}' | tail -n1 | xargs)

# Get CPU idle percentage
cpu_idle=$(echo "$vmstat_mb" | awk '{print $15}' | tail -n1 | xargs)

# Get CPU kernel percentage
cpu_kernel=$(echo "$vmstat_mb" | awk '{print $14}' | tail -n1 | xargs)

# Collect disk I/O
disk_io=$(vmstat -d | awk 'NR>2 {sum+=$10} END {print sum+0}')

# Collect available disk space in MB
disk_available=$(df -BM / | awk 'NR==2 {print $4}' | tr -d 'M')

# Get current UTC timestamp
timestamp=$(date -u '+%Y-%m-%d %H:%M:%S')
# Find matching host ID from host_info table
host_id="(SELECT id FROM host_info WHERE hostname='$hostname')"

# Construct SQL INSERT statement
insert_stmt="INSERT INTO public.host_usage
(\"timestamp\", host_id, memory_free, cpu_idle, cpu_kernel, disk_io, disk_available)
VALUES ('$timestamp', $host_id, $memory_free, $cpu_idle, $cpu_kernel, $disk_io, $disk_available);"

# Set environment variable for PostgreSQL password
export PGPASSWORD="$psql_password"

# Insert usage data into PostgreSQL
psql -h "$psql_host" -p "$psql_port" -d "$db_name" -U "$psql_user" -v ON_ERROR_STOP=1 -c "$insert_stmt"

exit $?