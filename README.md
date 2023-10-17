# gemmaJSON - simdjson bindings for Nim

`nimble install gemmaJSON`


## Usage

```nim
var json = parseGemmaJSON("""{"cat": {"a": ["woof", ["meow"], 2]}}""")

echo json.getStr("/cat/a/0")
# woof

echo json.getStr("/cat/a/1/0")
# meow

echo $json["cat"]["a"][0]
# woof

for e in json.getElement("/cat/a"):
  echo $e

```
