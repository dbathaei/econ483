import pandas as pd

df = pd.read_json('NodesAdded.json')
df.to_csv('output.csv', index=False)