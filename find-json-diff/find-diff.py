import sys
import os
sys.path.append(os.getcwd())

from util.readFile import readFile

result = []
data_1 = readFile(r'.\find-json-diff\data1.json', type='json')
data_2 = readFile(r'.\find-json-diff\data2.json', type='json')

# write your code here
firstRecordList = [d['trackingNumber'] for d in data_1]
secondRecordList = [d['trackingNumber'] for d in data_2]

for tk in firstRecordList:
    if tk in secondRecordList:
        result.append(tk)

# ptint result
print('-----------------------------------------------')
print('RESULT:')
print('-----------------------------------------------')
print(result)
print('-----------------------------------------------')