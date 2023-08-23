import os
from dotenv import load_dotenv
load_dotenv()
DiscoveryAPIKey = os.getenv("DISCOVERY_API_KEY")
DiscoveryAPIBaseUrl = os.getenv("DISCOVERY_API_BASE_URL")
IntDiscBaseUrl = os.getenv("INTERNATIONAL_DISCOVERY_BASE_URL")
SGBaseUrl = os.getenv("SEATGEEK_BASE_URL")
SGAPIKey = os.getenv("SEATGEEK_API_KEY")
SGAPISecret = os.getenv("SEATGEEK_API_SECRET")

import json
import requests as r
import datetime as dt
import pandas as pd


Now = dt.datetime.today() - dt.timedelta(days=7)

Begin = Now + dt.timedelta(days=4)
End = Now + dt.timedelta(days=6)

Begin = Begin.strftime("%Y-%m-%dT00:00:00")
End = End.strftime("%Y-%m-%dT23:59:59")

