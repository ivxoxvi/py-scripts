import sys
from pathlib import Path

sys.path.append(str(Path(__file__).parent.parent))
from util.rw_file import rfile

result = []
data_1 = rfile(r'data1.json', typ='json')
data_2 = rfile(r'data2.json', typ='json')

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