input_file = r'C:\Users\ADMIN\Desktop\temp\temp.txt'

lines = ''
with open(input_file, 'r', encoding='utf-8') as file:
    lines = file.readlines()

trimmedLines = ['\'' + line.strip() + '\',' for line in lines]

with open(input_file, 'w', encoding='utf-8') as file:
    file.writelines('\n'.join(trimmedLines))

print("done:", input_file)