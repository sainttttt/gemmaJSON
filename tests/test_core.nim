discard """
"""
import gemmaJSON

var json = parseGemmaJSON("""{"cat": {"a": ["woof", ["meow"], 2]}}""")
assert json.type == GemmaNodeType.Object

var el = json.getElement("/cat/a")
assert el.type == GemmaNodeType.Array

var i = 0

var targetTypes = @[GemmaNodeType.String,
                    GemmaNodeType.Array,
                    GemmaNodeType.Int]
# test iterator
for e in el:
  assert e.type == targetTypes[i]
  i += 1


assert json.getStr("/cat/a/0") == "woof"
assert json.getStr("/cat/a/1/0") == "meow"
assert json.getInt("/cat/a/2") == 2

assert json["cat"]["a"][0].getStr == "woof"
assert $json["cat"]["a"][0] == "woof"
