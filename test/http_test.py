import requests
import json

url = "http://open.neis.go.kr/hub/hisTimetable"
service_key = "cf79fa15b3c34635b2a24876fe0838fc"

params = {
'KEY' : service_key, 
'Type' : 'json', 
'pIndex' : '1',
'psize' : '100',
'ATPT_OFCDC _SC_CODE' : 'T10', 
'SD_SCHUL_CODE' : '7003713'}

response = requests.get(url, params=params)
contents = response.text
print(contents)