![gemmaJSONlogo](https://github.com/sainttttt/gemmaJSON/assets/58609876/836b0495-6d6d-476d-b124-fa7d9979f00f)
 gemmaJSON - simdjson bindings for Nim

`nimble install gemmaJSON`


## Benchmarks

Test was for deserialization of reddit comment json dumps, checking if the entry was from a specific subreddit

```
name ................. min time      avg time    std dv  times
sainttttt/gemmaJSON .. 13.291 s      13.386 s    ±0.110   x15
treeform/jsony ....... 28.280 s      28.659 s    ±0.366   x15
nim std/json ......... 72.095 s      73.678 s    ±1.436   x15
```

## Usage

```nim
var json = parseGemmaJSON("""{"cat": {"a": ["woof", ["meow"], 2]}}""")

echo json.getStr("/cat/a/0")
# woof

echo json.getStr("/cat/a/1/0")
# meow

echo $json["cat"]["a"][0]
# woof

echo $json
# {"cat":{"a":["woof",["meow"],2]}}

var j = jsonObj.toJsonNode.pretty
echo j.pretty

# {
#   "cat": {
#     "a": [
#       "woof",
#       [
#         "meow"
#       ],
#       2
#     ]
#   }
# }

for e in json.getElement("/cat/a"):
  echo $e

# woof
# ["meow"]
# 2

```
