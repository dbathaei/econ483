import requests
import os
import json
from dotenv import load_dotenv


with open('events.json', 'r') as file:
    original = json.load(file)

newdata = []

prepared = []

for i in range(0,len(original)):
    prepared.append(original[i])


list_of_relevant_columns_1 = ["id",
                            "name",
                            "domain",
                            "day_of_week",
                            "timezone",
                            "currency"
                            ]
list_of_relevant_columns_2 = ["event_date",
                              "local_event_date",
                              "on_sale_date",
                              "off_sale_date"]

list_of_relevant_venue_columns = ["name",
                                  "city",
                                  "country",
                                  ]

for object in prepared:

    event = {}

    for column in list_of_relevant_columns_1:
        event[f"{column}"] = object.get(f"{column}","NA")
    '''
    event["id"] = object["id"]
    event["name"] = object["name"]
    event["domain"] = object["domain"]
    event["day_of_week"] = object["day_of_week"]
    event["timezone"] = object["timezone"]
    event["currency"] = object["currency"]
    '''

    for column in list_of_relevant_columns_2:
        event[f"{column}"] = object.get(f"{column}", {}).get("value", "NA")
    '''
    event["event_date"] = object["event_date"]["value"]
    event["local_event_date"] = object["local_event_date"]["value"]
    event["on_sale_date"] = object["on_sale_date"]["value"]
    event["off_sale_date"] = object["off_sale_date"]["value"]
    '''

    venue = object.get("venue")
    if venue:
        event["venue_name"] = venue.get("name", "NA")
        event["venue_city"] = venue.get("location", {}).get("address", {}).get("city", "NA")
        event["venue_country"] = venue.get("location", {}).get("address", {}).get("country", "NA")
    else:
        event["venue_name"] = "NA"
        event["venue_city"] = "NA"
        event["venue_country"] = "NA"

    '''
    price_ranges = object.get("price_ranges")
    if price_ranges:
        event["p_gross_max"] = object["price_ranges"]["excluding_ticket_fees"]["max"]
        event["p_gross_min"] = object["price_ranges"]["excluding_ticket_fees"]["min"]

        event["p_net_max"] = object["price_ranges"]["including_ticket_fees"]["max"]
        event["p_net_min"] = object["price_ranges"]["including_ticket_fees"]["min"]
    else:
        event["p_gross_max"] = "NA"
        event["p_gross_min"] = "NA"
        event["p_net_max"] = "NA"
        event["p_net_min"] = "NA"
    '''

    
    properties = object["properties"]
    event["schedule_status"] = properties.get("schedule_status", "NONE")
    event["cancelled"] = properties.get("cancelled")
    event["rescheduled"] = properties.get("rescheduled")
    event["seats_available"] = properties.get("seats_available", "NA")
    event["sold_out"] = properties.get("sold_out", "NA")
    packageStatus = properties.get("package")
    if packageStatus == True:
        event["package"] = 1
    else:
        event["package"] = 0
    event["minimum_age_required"] = properties.get("minimum_age_required", 0)

    categories = object.get('categories')
    if categories:
        event["n_categories"] = len(categories)

        if len(categories) == 1:
            event["cat_1"] = categories[0]["name"]
            if categories[0]["subcategories"]:
                event["cat_1_subcat"] = categories[0]["subcategories"][0]["name"]
            else:
                event["cat_1_subcat"] = "NONE"
        else:
            event["cat_1"] = "NONE"
            event["cat_1_subcat"] = "NONE"
        
        if len(categories) == 2:
            event["cat_2"] = categories[1]["name"]
            if categories[1]["subcategories"]:
                event["cat_2_subcat"] = categories[1]["subcategories"][0]["name"]
            else:
                event["cat_2_subcat"] = "NONE"
        else:
            event["cat_2"] = "NONE"
            event["cat_2_subcat"] = "NONE"

    else:
        event["n_categories"] = 0
        event["cat_1"] = "NONE"
        event["cat_1_subcat"] = "NONE"
        event["cat_2"] = "NONE"
        event["cat_2_subcat"] = "NONE"
    
    attractions = object.get('attractions')
    if attractions:
        event[f"n_attractions"] = len(attractions)
        if len(attractions) <= 3:
            event["Many_attractions"] = 0
        else:
            event["Many_attractions"] = 1 # have to find reasoning for this.
    else:
        event[f"n_attractions"] = 0
        event[f"Many_attractions"] = 0
    newdata.append(event)

with open("cleanedevents.json", "w") as final:
    json.dump(newdata, final, indent=4)