from CI import *


# grabs data from our original fetch on Monday
with open("seatgeekMonday1FLATTENED.json", "r") as f:
    source = pd.DataFrame(json.load(f))
    sourceID = source["id"]
    NewSource = source.copy()   # data to manipulate
    

# prepares "sold_out" events when checked on Friday
with open("seatgeekFriday1FLATTENED.json", "r") as f:
    Friday = pd.DataFrame(json.load(f))
    FridaySO = Friday[Friday["sold_out"] == 1]
    FridaySOID = FridaySO["id"]
    soldOutSourceFriday = source[sourceID.isin(FridaySOID)]
    NewSource.loc[NewSource['id'].isin(soldOutSourceFriday["id"]), 'sold_out'] = 1 # updates rows if they're sold out.


# prepares "sold_out" events when checked on Saturday
'''with open("seatgeekSaturdayFLATTENED.json", "r") as f:
    Saturday = pd.DataFrame(json.load(f))
    SaturdaySO = Saturday[Saturday["sold_out"] == 1]
    SaturdaySOID = SaturdaySO["id"]
    soldOutSourceSaturday = source[sourceID.isin(SaturdaySOID)]
    NewSource.loc[NewSource['id'].isin(soldOutSourceSaturday["id"]), 'sold_out'] = 1 # updates rows if they're sold out.
'''
with open("seatgeekSunday1FLATTENED.json", "r") as f:
    Sunday = pd.DataFrame(json.load(f))
    SundaySO = Sunday[Sunday["sold_out"] == 1]
    SundaySOID = SundaySO["id"]
    soldOutSourceSunday = source[sourceID.isin(SundaySOID)]
    NewSource.loc[NewSource['id'].isin(soldOutSourceSunday["id"]), 'sold_out'] = 1 # updates rows if they're sold out.


# json and csv file.
NewSource.to_json("SoldOutData.json", orient="records", indent=4)
NewSource.to_csv("SoldOutData.csv", index=False)

# explains lengths, etc.
def Explainer(dataframe):
    expObj = {
        "total": len(dataframe),
        "sold_out": len(dataframe[dataframe['sold_out'] == 1])
    }
    print(json.dumps(expObj, indent=4))

Explainer(NewSource)