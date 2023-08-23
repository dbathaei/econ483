from CI import *
from CI import Begin, End


# parameters here:
FILENAME = "seatgeekSaturday1"
BASEURL = SGBaseUrl + "events"

PARAMETERS = {
    "datetime_local.gte": Begin,
    "datetime_local.lte": End,
    "per_page": 1000,
    "page": 1
}


# gives api authentication passwords
def SGvalues(apikey, apisecret):
    PARAMETERS["client_id"] = apikey
    PARAMETERS["client_secret"] = apisecret


# sends the get request
def GetRequest(url, parameters, page):
    parameters["page"] = page
    bigRequest = r.get(url, params = parameters)
    return bigRequest


# adds object or lets you know that there is a problem with it.
def addOrAnnounce(requestValue):
    if requestValue.status_code == 200:
        bigData = json.loads(requestValue.text)
    else:
        print("there is a problem with the request: ", requestValue.text)
        bigData = False
    return bigData


def gatherEvents(bigData):
    if 'events' in bigData:
        events = bigData['events']
        return events
    else:
        print("no events in this data.")


def Paginate(bigData, page):
    all_items = bigData["meta"]["total"]
    item = page * PARAMETERS["per_page"]
    if item > all_items:
        item = all_items
    all_pages = int(all_items/PARAMETERS["per_page"]) + 1
    print(f"Page {page}/{all_pages} | event {item}/{all_items} retrieved.")
    return all_pages


def main(fileName, url, parameters, apikey, apisecret):
    data = []
    page = 1
    all_pages = 0

    while True:
        #gives password everytime
        SGvalues(apikey,apisecret)


        bigRequest = GetRequest(url, parameters, page)# gives us bigRequest
        bigRequest

        
        bigData = addOrAnnounce(bigRequest) # returns 'bigData' or 'breaker' (see line 28)
        bigData
        if bigData == False:
            break


        events = gatherEvents(bigData)
        data += events


        all_pages = Paginate(bigData, page)
        page += 1
        if page > all_pages:
            break
    

    with open(f"{fileName}.json", "w") as file:
        json.dump(data, file, indent=4)
    

    print(f"finished. {all_pages} pages captured from:\n{Begin} to {End}")

main(FILENAME, BASEURL, PARAMETERS, SGAPIKey, SGAPISecret)