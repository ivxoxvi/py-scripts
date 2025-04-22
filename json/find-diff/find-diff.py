import json


def read(filePath, *, type = str):
    with open(filePath, 'r') as file:
        if type == str:
            return file.read()
        if type == list:
            return file.readlines()

firstFilePath = r'.\json1.txt'
secondFilePath = r'.\json2.json'

firstJsonStr = read(firstFilePath)
secondJsonStr = read(secondFilePath)

firstJsonObject = json.loads(firstJsonStr)
secondJsonObject = json.loads(secondJsonStr)

firstRecordList = firstJsonObject['data']['recordList']
secondRecordList = secondJsonObject['data']['recordList']

first = [r['headerId'] for r in firstRecordList if r['processingStatusDesc'] == 'Pushed to Delivery']
second = [r['headerId'] for r in secondRecordList if r['processingStatusDesc'] == 'Pushed to Delivery']


print('-----------------------------------------------')
print('\nRESULT')
print('-----------------------------------------------')
print(first ^ second)
print('-----------------------------------------------')