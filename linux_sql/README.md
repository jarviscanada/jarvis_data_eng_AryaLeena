# Linux Cluster Monitoring Agent
This project is designed to collect and monitor Linux system information including hardware specifications and resource usage.The project uses shell scripts for automation and PostgreSQL for storing monitoring data. Docker is used to run the PostgreSQL database in a container.

## Technologies Used
- Rocky Linux
- Docker
- PostgreSQL
- Shell Scripting
- GitHub
- IntelliJ IDEA & Vim 

## Project Structure
```text
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
## PostgreSQL Docker Script
### Description
The psql_docker.sh script manages the PostgreSQL Docker Container. It automates container creation , startup and stop.
### Docker Configuration
- Container name:jrvs-psql
- Docker image-postgres:9.6-alpine

### Prerequisites
- Rocky Linux
- Docker installed
- Permission to execute Docker Commands
### Execution Steps 
- Make the script executable:
       chmod +x scripts/psql_docker.sh
- Create a PostgreSQL Container:
        ./scripts/psql_docker.sh create <db_username> <db_password. 
  - To view the created container : docker ps -a
- Start the PostgreSQL container:
         ./scripts/psql_docker.sh start <container_name>
  - To verify start: docker ps -f name="container_name"
- Stop the PostgreSQL container:
  ./scripts/psql_docker.sh stop <container_name>
   - To verify stop: docker ps -f name="container_name"
### Error Handling 
The script displays error message when:
- The container already exist during creation.
- An unsupported command is supplied.

