import requests
import os
import json
from dotenv import load_dotenv


base_url = "https://app.ticketmaster.eu/mfxapi/v2/"
endpoints = ['events']  # Different types of data we want to store

load_dotenv()
api_key = os.getenv("API_KEY")


params = {
    "apikey": api_key,
    "start": 0,
    "rows": 250,
    "eventdate_from": "2023-07-01T00:00:00Z",
    "eventdate_to": "2023-08-01T23:59:59Z"
}

headers = {
    'Accept': 'application/json'
}

for endpoint in endpoints:

    all_data = []  # to store 'data' in this list separate from the HTTP request file.
    page = 0  # iterable

    while True:
        params["start"] = page * params["rows"]  # A.k.a (((start = page * 250))) so page 2 will start from row 250, page 3 from 500, etc...
        response = requests.get(f"{base_url}{endpoint}", params=params, headers=headers)

        # to only keep the loop going if conditions are met, else, break.
        if response.status_code == 200:
            data = json.loads(response.text)

            # find events, attractions, categories etc.
            if endpoint in data:
                items = data[endpoint]  # it's best to not do operations inside an operation.
                all_data += items  # takes every node of 'endpoint' in data.
            else:
                print(f"No {endpoint} found.")
            
            # see if pages remaining
            if 'pagination' in data and 'total' in data['pagination']:  # could also be if 'total' in data['pagination']
                total_items = data['pagination']['total']
                retrieved_items = page * params["rows"] + len(items)
                print(f"Progress: {retrieved_items}/{total_items} {endpoint} retrieved")  # just so I know the progress.
                if retrieved_items >= total_items:
                    break  # done. JESUS.

            page += 1
        else:
            print(f"Error retrieving {endpoint}, status code:", response.status_code)
            break

    # now we put the data in a file.
    with open(f"{endpoint}.json", "w") as file:
        json.dump(all_data, file, indent=4)  # Add a newline character after each event

print("Files made. Check out the folder.")
