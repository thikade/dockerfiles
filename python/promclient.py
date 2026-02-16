#!/usr/bin/env python3
"""
Simple Prometheus exporter that executes a shell command and exposes the result as a metric.
"""

import subprocess
import time
from prometheus_client import start_http_server, Gauge
import logging

# Configuration
# COMMAND = "bash -c 'echo $(($RANDOM % 100))'"  # return random number 0-99
COMMAND = ["bash", "-c", 'echo $(($RANDOM % 100))']  # return random number 0-99
METRIC_NAME = "my_metric_name"
METRIC_HELP = "Value returned by shell command"
UPDATE_INTERVAL = 30  # seconds
PORT = 8080

# Setup logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# Create Prometheus metric
metric = Gauge(METRIC_NAME, METRIC_HELP)

def execute_command():
    """Execute shell command and return integer value."""
    try:
        result = subprocess.run(
            COMMAND,
            shell=False,
            capture_output=True,
            text=True,
            timeout=10
        )

        if result.returncode != 0:
            logger.error(f"Command failed with return code {result.returncode}: {result.stderr}")
            return None

        value = int(result.stdout.strip())
        logger.info(f"Command returned: {value}")
        return value

    except ValueError as e:
        logger.error(f"Could not parse output as integer: {result.stdout.strip()}")
        return None
    except subprocess.TimeoutExpired:
        logger.error("Command execution timed out")
        return None
    except Exception as e:
        logger.error(f"Error executing command: {e}")
        return None

def update_metric():
    """Update the Prometheus metric with command output."""
    while True:
        value = execute_command()
        if value is not None:
            metric.set(value)
        time.sleep(UPDATE_INTERVAL)

if __name__ == '__main__':
    # Start Prometheus HTTP server
    start_http_server(PORT)
    logger.info(f"Prometheus exporter started on port {PORT}")
    logger.info(f"Metrics available at http://localhost:{PORT}/metrics")
    logger.info(f"Executing command every {UPDATE_INTERVAL} seconds: {COMMAND}")

    # Start metric updates
    update_metric()