const os = require('os');
const fs = require('fs');

function getHealthStatus() {
  // CPU Usage (based on load average)
  const cpuCount = os.cpus().length;
  const loadAvg = os.loadavg()[0]; // 1 minute load average
  const cpuUsagePercent = (loadAvg / cpuCount) * 100;

  // Memory Usage
  const totalMemory = os.totalmem();
  const freeMemory = os.freemem();
  const memoryUsagePercent = ((totalMemory - freeMemory) / totalMemory) * 100;

  // Disk Space (for current directory)
  const diskInfo = fs.statfsSync('.');
  const totalSpace = diskInfo.blocks * diskInfo.bsize;
  const freeSpace = diskInfo.bfree * diskInfo.bsize;
  const diskUsagePercent = ((totalSpace - freeSpace) / totalSpace) * 100;

  return {
    cpu: {
      usage: cpuUsagePercent,
      healthy: cpuUsagePercent > 50,
      details: `CPU Usage: ${cpuUsagePercent.toFixed(2)}% (Load Average: ${loadAvg.toFixed(2)} across ${cpuCount} CPUs)`
    },
    memory: {
      usage: memoryUsagePercent,
      healthy: memoryUsagePercent > 50,
      details: `Memory Usage: ${memoryUsagePercent.toFixed(2)}% (${((totalMemory - freeMemory) / 1024 / 1024 / 1024).toFixed(2)}GB used out of ${(totalMemory / 1024 / 1024 / 1024).toFixed(2)}GB)`
    },
    disk: {
      usage: diskUsagePercent,
      healthy: diskUsagePercent > 50,
      details: `Disk Usage: ${diskUsagePercent.toFixed(2)}% (${((totalSpace - freeSpace) / 1024 / 1024 / 1024).toFixed(2)}GB used out of ${(totalSpace / 1024 / 1024 / 1024).toFixed(2)}GB)`
    }
  };
}

function main() {
  const explain = process.argv.includes('explain');
  const health = getHealthStatus();
  
  const resources = ['cpu', 'memory', 'disk'];
  
  resources.forEach(resource => {
    const status = health[resource];
    console.log(`\n${resource.toUpperCase()} Status:`);
    console.log(status.healthy ? '✅ Healthy with adequate space' : '❌ Unhealthy, need to increase the space');
    
    if (explain) {
      console.log(status.details);
    }
  });
}

main();
