input_file = r'C:\Users\ADMIN\Desktop\temp\temp.txt'

lines = ''
with open(input_file, 'rw', encoding='utf-8') as file:
    lines = file.readlines()
    trimmedLines = ['\'' + line.strip() + '\',' for line in lines]
    file.writelines('\n'.join(trimmedLines))

print("done:", input_file)