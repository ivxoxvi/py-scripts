import fitz

doc = fitz.open("input.pdf")

# 读取目录，返回 [[level, title, page], ...]，page是1基！
toc = doc.get_toc()
print("原始目录：", toc)

# 改：直接在列表里修改标题、页码、增删条目
# 示例：把第一条标题改掉
if toc:
    toc[0][1] = "【修改后的标题】"
    toc[0][2] = 2  # 改成跳转到第2页（1基）

# 新增二级目录
toc.append([2, "新增小节", 3])

# 写回PDF，直接替换整棵目录
doc.set_toc(toc)

doc.save("out_pymupdf.pdf")
doc.close()
