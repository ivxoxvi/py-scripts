import sys
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent))
from util.rwFile import rfile

result = []
data_1 = rfile(r'data1.json', type='json')
data_2 = rfile(r'data2.json', type='json')

# write your code here
firstRecordList = [d['trackingNumber'] for d in data_1]
secondRecordList = [d['trackingNumber'] for d in data_2]

for tk in firstRecordList:
    if tk in secondRecordList:
        result.append(tk)

# print result
print('-----------------------------------------------')
print('RESULT:')
print('-----------------------------------------------')
print(result)
print('-----------------------------------------------')