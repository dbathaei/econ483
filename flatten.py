import json
FILENAME = "seatgeekSunday1"

with open(f"{FILENAME}.json", "r") as raw:
    start = json.load(raw)

day = "Sunday1"
Weekend = True

def flattenJSON():
    Polished = []
    counter = 1
    for node in start:
        performers = node["performers"]
        venue = node["venue"]
        taxonomies = node["taxonomies"][0]
        stats = node["stats"]

        event = {}

        # level 0
        event["id"] = node["id"]
        event["date"] = node["datetime_utc"]
        event["local_date"] = node["datetime_local"]
        event["score"] = node["score"]
        event["announce_date"] = node["announce_date"]
        event["type"] = node["type"]
        event["n_performers"] = len(performers)
        event["popularity"] = node["popularity"]

        # level 1
        event["venue"] = venue["name"]
        event["country"] = venue["country"]
        event["state"] = venue["state"]
        event["venue_score"] = venue["score"]
        event["venue_n_upcoming_events"] = venue["num_upcoming_events"]

        # very valuable variables:
        event["listing_count"] = stats.get("listing_count", "NA")
        event["average_price"] = stats.get("average_price", "NA")
        event["lowest_price"] = stats.get("lowest_price", "NA")
        event["highest_price"] = stats.get("highest_price", "NA")
        event["median_price"] = stats.get("median_price", "NA")

        #level 2
        event["segment"] = taxonomies["name"]        
        event["primary_performer"] = performers[0]["name"]
        event["primary_performer_event_count"] = performers[0]["stats"]["event_count"]
        event["primary_performer_score"] = performers[0]["score"]
        if len(performers) > 1:
            event["performer_2"] = performers[1]["name"]
            event["performer_2_event_count"] = performers[1]["stats"]["event_count"]
            event["performer_2_score"] = performers[1]["score"]
        else:
            event["performer_2"] = "None"
            event["performer_2_event_count"] = 0
            event["performer_2_score"] = 0
        
        if event["listing_count"] == None:
            if event["score"] > 0:
                event["sold_out"] = 1
            else:
                event["sold_out"] = 0
        else:
            event["sold_out"] = 0



        Polished.append(event)
        if Weekend == False: # removes the event if it's sold out and it's the weekend.
            if event["sold_out"] == 1:
                Polished.remove(event)
        
        
        counter += 1
        if counter%100 == 0:
            print(f"{counter} events done.")
        elif counter == len(start):
            print(f"{counter} events done. Finished.")
        
    with open(f"seatgeek{day}FLATTENED.json", "w") as prepped:
        json.dump(Polished, prepped, indent=4)
        print(f"{prepped.name} made. {len(Polished)} items in there.")

flattenJSON()