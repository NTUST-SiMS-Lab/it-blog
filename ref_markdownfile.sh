cd ./source/_posts/; files=$(find . -name "*.md")

echo $files

cd ../../

for file in $files; do
    python3 math_underscore_replace.py -f "$file"
done