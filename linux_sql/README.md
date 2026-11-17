# Linux Cluster Monitoring Agent 
# Introduction
The Linux Cluster Monitoring Agent project is designed to collect and monitor Linux system information including host hardware specifications and current host resource usage from Linux servers and store them in PostgreSQL database.Docker is used to run the PostgreSQL database in a container. The project uses shell scripts for automation and PostgreSQL for storing monitoring data.It helps developers and system administrators understand a server's configuration, review CPU and memory activity, and track available disk space over time.The project separates data collection into two scripts: `host_info.sh` records relatively static hardware details, while `host_usage.sh` collects changing usage data.
# Technologies Used
- Google Cloud Compute Engine
- Rocky Linux 9
- Git & GitHub
- Docker
- PostgreSQL
- IntelliJ IDEA
- Vim
- Bash/Shell Scripting
- Crontab

# Project Structure
```
Linux_sql/
── assets/
── scripts/
     ── host_info.sh
     ── host_usage.sh
     ── psql_docker.sh
── sql/
     ── ddl.sql
     ── queries.sql
── README.md
```
# Quick Start
This guide explains how to set up and run the Linux Cluster Monitoring Agent on a Linux machine. Follow the steps below to configure the database, collect hardware information, and enable automatic resource monitoring.

**Step 1. Prerequisites:**

* Linux operating system (Rocky Linux recommended)
* Docker
* PostgreSQL command-line client (psql)
* Git
* Cron 
* Linux system utilities, including lscpu, vmstat, and df

**Step 2. Clone the Repository:**
* Download the project to your Linux machine using Git:
`git clone GITHUB_REPOSITORY_URL`
* Navigate to the Linux SQL project directory:
`cd jarvis_data_eng_AryaAnilkumar/linux_sql`
* The project contains the Bash scripts, SQL files, and documentation required to run the monitoring agent

**Step 3: Start PostgreSQL Using Docker**

* Start the Docker service:
`sudo systemctl start docker`
* Use the `psql_docker.sh` script to create a PostgreSQL container:`bash scripts/psql_docker.sh create jrvs-psql postgres 'YOUR_PASSWORD'`
* The script creates a Docker container named `jrvs-psql` and configures the PostgreSQL database service.
* If the container already exists but is stopped, start it using:
`bash scripts/psql_docker.sh start`
* Verify the container is running:
`docker ps`

**Step 4: Create the Database and Tables**
* Create a database named host_agent:``psql -h localhost -p 5432 -U postgres -d postgres -W -c "CREATE DATABASE host_agent;"``
* Next, execute ddl.sql to create the required database tables:`psql -h localhost -p 5432 -U postgres -d host_agent -W -f sql/ddl.sql`
* This creates two tables:

  **host_info**: Stores the hardware specifications of each Linux server.

  **host_usage**: Stores CPU, memory, and disk usage information.
* To verify the tables, connect to PostgreSQL:`psql -h localhost -p 5432 -U postgres -d host_agent -W`
* Then execute:``\dt``
* The `host_info` and `host_usage` tables should be displayed.
* Exit PostgreSQL using:``\q``

**Step 5: Collect Hardware Information**

* Run `host_info.sh` to collect the hardware specifications of the Linux machine:`bash scripts/host_info.sh localhost 5432 host_agent postgres 'YOUR_PASSWORD'`
* The script collects information such as hostname, CPU architecture, CPU model, CPU speed, L2 cache, and total memory.
* The collected information is inserted into the host_info table.
 `Expected output:INSERT 0 1`
* This script is normally executed once for each server to register its hardware specifications.

**Step 6: Collect Resource Usage Information**
* Run `host_usage.sh`:`bash scripts/host_usage.sh localhost 5432 host_agent postgres 'YOUR_PASSWORD'`
* This script collects information about the machine's current resource usage, including free memory, CPU idle time, CPU kernel usage, disk I/O, and available disk space.
* The collected information is stored in the `host_usage table`. Expected output:INSERT 0 1
* To verify the records, connect to PostgreSQL and execute:`psql -h localhost -p 5432 -U postgres -d host_agent -W`
* Execute:`SELECT * FROM host_usage;`
* Exit PostgreSQL using ``\q``.

**Step 7: Configure Automatic Monitoring Using Crontab**
* Cron is used to automatically execute host_usage.sh every minute.
* First, start the cron service:
`sudo systemctl start crond`
* Open the crontab editor:
`crontab -e`
* Add the following scheduled job -``* * * * */bin/bash /ABSOLUTEPATH/linux_sql/scripts/host_usage.sh localhost 5432 host_agent postgres 'YOUR_PASSWORD' > /tmp/host_usage.log 2>&1``
* Save the crontab and verify the scheduled job:`crontab -l`
* Check the execution output:`cat /tmp/host_usage.log`
* A successful execution should display: INSERT 0 1

**Step 8: Verify Automatic Data Collection**
* Connect to the PostgreSQL database and execute:``SELECT *
FROM host_usage
ORDER BY "timestamp" DESC
LIMIT 10;``
* The query displays the latest usage records.
* If the monitoring agent is configured correctly, new records should appear approximately every minute.
# Implementation
The Linux Cluster Monitoring Agent was implemented using Bash scripting, Docker, PostgreSQL, and Linux system utilities to automate hardware information collection and resource monitoring.

The project was developed through the following steps:

1. **Linux Environment Setup**
   * Created a Rocky Linux 9 virtual machine using Google Cloud Compute Engine.
   * Installed the required tools, including Git, Docker, PostgreSQL client, and Linux utilities.

2. **PostgreSQL Database Setup**
     * Developed `psql_docker.sh` to create, start, and stop a PostgreSQL Docker container.
    * Configured persistent Docker storage to preserve database data when the container is  stopped or restarted.
3. **Database Design**
   - Created the `host_agent` database to store monitoring information.
   - Developed `ddl.sql` to create the `host_info` and `host_usage` tables.
   - Used `host_info` to store hardware specifications and `host_usage` to store resource usage statistics.

4. **Hardware Information Collection**
   - Developed `host_info.sh` using Bash and Linux commands to collect hostname, CPU details, L2 cache, and total memory.
   - Implemented SQL insertion to store the collected hardware information in the `host_info` table.

5. **Resource Usage Monitoring**
   - Developed `host_usage.sh` to collect CPU, memory, and disk usage statistics using Linux commands such as `vmstat` and `df`.
   - Linked the usage information to the corresponding Linux host through its host ID.
   - Inserted the collected statistics into the PostgreSQL `host_usage` table.

6. **Automated Monitoring Using Crontab**
   - Configured crontab to execute `host_usage.sh` automatically every minute.
   - Redirected script output and errors to a log file for monitoring and troubleshooting.

7. **Testing and Version Control**
   - Tested the Bash scripts through the Linux terminal and IntelliJ IDEA.
   - Verified successful database insertions and confirmed that crontab generated new records approximately every minute.
   - Used Git and GitHub to manage feature branches, commits, merges, and project development. 
## Architecture

The Linux Cluster Monitoring Agent is designed to monitor three Linux hosts connected through a network switch.

**Linux Host 1**: Runs Bash monitoring scripts and hosts the PostgreSQL database in Docker.

**Linux Host 2 and 3**: Run monitoring scripts and send collected data to the central database.

**Monitoring Agents**:host_info.sh collects hardware specifications, while host_usage.sh collects CPU, memory, and disk usage.

**Crontab**: Executes `host_usage.sh` every minute to automate data collection.

**PostgreSQL**: Stores hardware details in `host_info` and resource usage statistics in `host_usage`.

**Actual Implementation**: This project was developed and tested on a single Rocky Linux 9 VM hosted on Google Cloud Compute Engine, where both the monitoring scripts and PostgreSQL container run. The three-host architecture illustrates how the system can be expanded to monitor multiple Linux servers.

## Scripts
**1. psql_docker.sh**
The ``psql_docker.sh`` script was developed using Bash to manage a PostgreSQL database container through Docker.
* Supports three operations: create, start, and stop.
* Uses Docker commands to create and manage the PostgreSQL container.
* Uses a Docker volume to preserve database data even when the container is stopped or removed.

**Script Usage:**

* **Create a PostgreSQL container**

```bash scripts/psql_docker.sh create jrvs-psql postgres 'YOUR_PASSWORD'```

* **Start an existing container**

```bash scripts/psql_docker.sh start jrvs-psql```

* **Stop an existing container**

```bash scripts/psql_docker.sh stop jrvs-psql```

**2. host_info.sh**

* The `host_info.sh` script collects and stores the hardware specifications of a Linux server.

* Uses Linux commands such as hostname, lscpu, and grep to collect hardware information.

* Collects hostname, CPU number, CPU architecture, CPU model, CPU speed, L2 cache, and total memory.

* Inserts the collected information into the PostgreSQL `host_info` table.

* Normally executes once per Linux host to register its hardware details.

**Script Usage:**

```bash scripts/host_info.sh localhost 5432 host_agent postgres 'YOUR_PASSWORD'```

**3. host_usage.sh**

The `host_usage.sh` script collects Linux system resource usage statistics and stores them in PostgreSQL.

* Uses vmstat and df to collect resource usage information.

* Collects free memory, CPU idle percentage, CPU kernel usage, disk I/O, and available disk space.

*  the corresponding host ID from the `host_info` table using the hostname.

* Inserts the collected statistics into the PostgreSQL `host_usage` table.

**Script Usage:**

```bash scripts/host_usage.sh localhost 5432 host_agent postgres 'YOUR_PASSWORD'```

**4. Crontab**

* Crontab is used to automate the execution of `host_usage.sh`at regular intervals.

* Configured to execute `host_usage.sh` every minute.

* Automatically collects resource usage statistics without manual execution.

* Redirects script output and error messages to `/tmp/host_usage.log`.

* Continues monitoring while the Linux VM, cron service, and PostgreSQL database are running.

**Crontab Configuration:**

`crontab -e`

**Scheduled Job:**

`* * * * * bash /ABSOLUTE_PATH/linux_sql/scripts/host_usage.sh localhost 5432 host_agent postgres 'YOUR_PASSWORD' > /tmp/host_usage.log 2>&1`

**5. queries.sql**

The queries.sql file contains SQL queries to analyze Linux server resource usage, monitor CPU performance, and detect duplicate records.

**1. Display Latest Host Usage Records**

**Purpose:** Retrieve the latest five records from the `host_usage` table.

**Business Problem:** The IT team needs to monitor recently collected server resource usage data to verify that the monitoring system is working correctly.

**2. Identify Servers with High CPU Usage**

**Purpose:**
Identify servers where CPU utilization exceeds 80%.(For testing purpose given it as 20%)

**Business Problem:** High CPU usage may affect server performance. This query helps administrators identify servers with CPU utilization above the defined threshold and investigate potential performance issues.

**3. Detect Duplicate Host Usage Records**

**Purpose:** Identify duplicate records based on host_id and timestamp.

**Business Problem:** Duplicate monitoring records can affect the accuracy of resource usage reports. This query uses GROUP BY, COUNT(), and HAVING to identify duplicate entries and help maintain data accuracy.

**Execution:**

`psql -h localhost -p 5432 -U postgres -d host_agent -W -f sql/queries.sql`

## Database Modeling
**host_info.sh**
| Column Name | Datatype | Constraint | Description      |
|----------------------|--------------|-----------------|-----------------------|
| id               | SERIAL    | PRIMARY KEY         | Unique host ID           |
| hostname         | VARCHAR   | NOT NULL, UNIQUE    | Hostname of the machine  |
| cpu_number       | INT2      | NOT NULL            | Number of CPUs           |
| cpu_architecture | VARCHAR   | NOT NULL            | CPU architecture         |
| cpu_model        | VARCHAR   | NOT NULL            | CPU model                |
| cpu_mhz          | FLOAT8    | NOT NULL            | CPU frequency in MHz     |
| l2_cache         | INT4      | NOT NULL            | L2 cache size in KB      |
| timestamp        | TIMESTAMP | NULL                | Time of data collection  |
| total_mem        | INT4      | NULL                | Total memory in KB       |           

**host_usage.sh**
| Column Name    | Data Type | Constraint              | Description                  |
|----------------|-----------|-------------------------|------------------------------|
| timestamp      | TIMESTAMP | NOT NULL                | Time of data collection      |
| host_id        | SERIAL    | NOT NULL, FOREIGN KEY   | References host_info(id)     |
| memory_free    | INT4      | NOT NULL                | Free memory in MB            |
| cpu_idle       | INT2      | NOT NULL                | CPU idle percentage          |
| cpu_kernel     | INT2      | NOT NULL                | CPU kernel usage percentage  |
| disk_io        | INT4      | NOT NULL                | Disk I/O operations          |
| disk_available | INT4      | NOT NULL                | Available disk space in MB   |

## Test
**1. psql_docker.sh**
* Tested the script by creating, starting, and stopping the PostgreSQL Docker container. All commands executed successfully. 

**2. host_info.sh**
* Executed the script to collect host hardware information and insert it into the `host_info` table. Verified the inserted records using SQL queries.

**3. host_usage.sh**
* Executed the script to collect CPU, memory, and disk usage information and insert it into the  `host_usage` table. Verified the inserted records using SQL queries.

**4. ddl.sql**
* Tested the DDL script by executing it in PostgreSQL using psql. Verified that the `host_info` and `host_usage` tables were created successfully with the correct columns, data types, and constraints.

**5. Crontab**
* Scheduled `host_usage.sh` to execute every minute using crontab. Verified the latest inserted records using the following SQL query:

`SELECT * FROM host_usage ORDER BY timestamp DESC LIMIT 5;`

**Result:** New records were automatically inserted into the `host_usage` table every minute, confirming that the cron job was working correctly.

**Overall Result**

All Bash scripts and the DDL script executed successfully. The PostgreSQL database stored host hardware information and resource usage data, and crontab automated resource monitoring every minute.
## Deployment
The Linux Cluster Monitoring Agent was deployed on a Rocky Linux 9 virtual machine hosted on Google Cloud Compute Engine. The project uses Docker, PostgreSQL, GitHub, and crontab for database management, version control, and automated monitoring.

**1. Google Cloud Compute Engine**
* Created a Rocky Linux 9 virtual machine to develop and run the monitoring agent.
* Installed the required tools, including Docker, Git, PostgreSQL client, and Bash utilities.

**2. Docker and PostgreSQL**

* Deployed PostgreSQL inside a Docker container using `psql_docker.sh`.
* Used a Docker volume to store database data persistently.
* Created the host_agent database with `host_info` and `host_usage` tables.

**3. Git and GitHub**

* Used Git for version control and GitHub to store and manage the project source code.
* Followed GitFlow with develop and feature branches to manage code changes and merges.
* Used Pull Requests for code review as part of the development workflow.

**4. Crontab Automation**

* Configured crontab on the Rocky Linux VM to execute `host_usage.sh` every minute.
* Automated the collection and insertion of CPU, memory, and disk usage statistics into PostgreSQL.
* Configured log redirection to `/tmp/host_usage.log` to monitor script execution.

**5. Deployment Verification**

* Tested the Bash scripts manually and confirmed successful PostgreSQL insertions.
* Verified that crontab automatically inserted new records into `host_usage` approximately every minute.
* Confirmed that the monitoring agent operates while the VM, PostgreSQL container, and cron service are running.

## Improvements
**Error Handling**

Improve Bash scripts to handle database connection failures and invalid inputs.

**Avoid Duplicate Records**

Instead of inserting duplicate records, the script should compare the latest hardware information with the existing data in the host_info table and update the record whenever changes are detected. This will ensure that the database always contains accurate and up-to-date hardware information.

**Performance Monitoring Dashboard**

Create a dashboard to display CPU, memory, and disk usage using charts and graphs, making it easier to monitor server performance










