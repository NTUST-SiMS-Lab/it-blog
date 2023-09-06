import re
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("-f", "--file", help="input file")
args = parser.parse_args()

file_name = args.file

# 正則表達式模式來匹配`$`或`$$`包起來的LaTeX代碼
latex_pattern = r'(\$+)([^\$]+)\1'

with open(f"source/_posts/{file_name}", 'r', encoding='utf-8') as f:
    markdown_text = f.read()

matches = re.findall(latex_pattern, markdown_text)

# 將LaTeX代碼中的底線替換為反斜杠加底線
for match in matches:
    latex_code = match[1]
    latex_code = latex_code.replace('_', r'\_')
    markdown_text = markdown_text.replace(match[0] + match[1] + match[0], match[0] + latex_code + match[0])

with open(f'source/_posts/{file_name}', 'w', encoding='utf-8') as f:
    f.write(markdown_text)