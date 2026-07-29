map = {"cnm": """Language|files|blank|comment|code
:-------|-------:|-------:|-------:|-------:
TypeScript|256|1831|102|12613
Markdown|17|352|0|814
JavaScript|12|115|486|600
JSON|8|0|0|437
YAML|3|0|0|186
CSS|2|44|0|134
SVG|2|6|4|29
Handlebars|3|7|0|20
HTML|1|1|0|17
Text|1|0|0|3
--------|--------|--------|--------|--------
SUM:|305|2356|592|14853"""}

a = map.items()[0]
print(int(a[1][a[1].rfind("\n") :].split("|")[-1]))
