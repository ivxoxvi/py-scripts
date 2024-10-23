def move(n, a, b, c):
    if n == 1:
        print(a, '-->', c)

# 期待输出:
# A --> C
# A --> B
# C --> B
# A --> C
# B --> A
# B --> C
# A --> C
move(3, 'A', 'B', 'C')