#!/bin/bash

# Function to check CPU utilization
check_cpu() {
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
}

# Function to check disk space usage
check_disk() {
    disk_usage=$(df / | grep / | awk '{ print $5 }' | sed 's/%//g')
}

# Function to check memory utilization
check_memory() {
    mem_usage=$(free | grep Mem | awk '{print $3/$2 * 100.0}')
}

# Function to print status with explanation if "explain" argument is passed
print_status() {
    if [ "$1" == "cpu" ]; then
        if [ "$(echo "$cpu_usage < 50" | bc)" -eq 1 ]; then
            echo "Unhealthy: CPU utilization is less than 50%. Need to increase CPU capacity."
        else
            echo "Healthy: CPU utilization is above 50%. Adequate CPU capacity."
        fi
    elif [ "$1" == "disk" ]; then
        if [ "$disk_usage" -lt 50 ]; then
            echo "Unhealthy: Disk space utilization is less than 50%. Need to increase disk space."
        else
            echo "Healthy: Disk space utilization is above 50%. Adequate disk space."
        fi
    elif [ "$1" == "memory" ]; then
        if [ "$(echo "$mem_usage < 50" | bc)" -eq 1 ]; then
            echo "Unhealthy: Memory utilization is less than 50%. Need to increase memory."
        else
            echo "Healthy: Memory utilization is above 50%. Adequate memory."
        fi
    fi
}

# Function to explain health status if the "explain" argument is passed
explain_status() {
    if [ "$1" == "cpu" ]; then
        echo "Explanation: CPU utilization is calculated by checking the idle CPU percentage and subtracting it from 100%. If the usage is less than 50%, the CPU is considered underutilized, suggesting a need for increased capacity."
    elif [ "$1" == "disk" ]; then
        echo "Explanation: Disk space utilization is calculated by checking the disk usage percentage. If it is under 50%, the disk is considered to have adequate space."
    elif [ "$1" == "memory" ]; then
        echo "Explanation: Memory utilization is calculated by checking the used memory percentage. If it is under 50%, the system has sufficient memory, but if it exceeds 50%, the memory is under pressure."
    fi
}

# Main Script Execution
if [ "$1" == "explain" ]; then
    explain=true
    shift # remove "explain" from command-line arguments
else
    explain=false
fi

# Check CPU, Disk, and Memory
check_cpu
check_disk
check_memory

# Output Health Status for each resource
if [ "$explain" == true ]; then
    print_status "cpu"
    explain_status "cpu"
    print_status "disk"
    explain_status "disk"
    print_status "memory"
    explain_status "memory"
else
    print_status "cpu"
    print_status "disk"
    print_status "memory"
fi
