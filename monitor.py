import requests
import time
from datetime import datetime

sites = [
    "https://example1.com",
    "https://example2.com"
]

def check_status(url):
    try:
        response = requests.get(url, timeout=10)
        status = "UP" if response.status_code == 200 else "DOWN"
        print(f"{datetime.now()} - {url}: {status}")
        return status
    except:
        print(f"{datetime.now()} - {url}: DOWN")
        return "DOWN"

for site in sites:
    check_status(site)
