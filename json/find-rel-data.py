from collections import Counter
from util.readFile import read
import json

argsFilePath = r'json\args.txt'
jsonFilePath = r'json\json.json'

argsList = [line.strip() for line in read(argsFilePath, type = list)]
jsonStr = read(jsonFilePath)

args = set(argsList)
jsonObject = json.loads(jsonStr)

result = []
hitData = set()
warningData = {}
for item in jsonObject:
    if item['salesOrderNumber'] in args:
        soNumber = item['salesOrderNumber']
        if item['drpCarrierServiceCode'] == 'FedEx Ground CA':
            result.append(item['shipLineId'])
        else:
            warningData[soNumber] = item['drpCarrierServiceCode']
        hitData.add(soNumber)

print('-----------------------------------------------')
print('Json length: %d' % len(jsonStr))
print('Param length: %d' % len(args))
print('Result length: %d' % len(result))
if len(args) != len(argsList):
    print('filtered args:', [item for item, count in Counter(argsList).items() if count > 1])
if len(args) != len(hitData):
    print('missedData:', args - hitData)
if warningData:
    print('warning(%d):' % len(warningData))
    for k, v in warningData.items():
        print('\t%s : %s' % (k, v))

print('\nRESULT')
print('-----------------------------------------------')
for x in result:
    print("'%s'," % x)
print('-----------------------------------------------')
count = Counter(result)
if any(value > 1 for value in count.values()):
    print('filtered args:', [item for item, count in count.items() if count > 1])