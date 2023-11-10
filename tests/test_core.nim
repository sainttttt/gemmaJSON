discard """
"""
import gemmaJSON
import std/json

var strToParse = """{
    "cat": {
        "a": [
            "woof",
            [
                "meow"
            ],
            2
        ]
    }
}"""

var jsonObj = parseGemmaJSON(strToParse)
assert jsonObj.type == GemmaNodeType.Object

var el = jsonObj.getElement("/cat/a")
assert el.type == GemmaNodeType.Array

var i = 0

var targetTypes = @[GemmaNodeType.String,
                    GemmaNodeType.Array,
                    GemmaNodeType.Int]
# test iterator
for e in el:
  assert e.type == targetTypes[i]
  i += 1

assert jsonObj.getStr("/cat/a/0") == "woof"
assert jsonObj.getStr("/cat/a/1/0") == "meow"
assert jsonObj.getInt("/cat/a/2") == 2

assert jsonObj["cat"]["a"][0].getStr == "woof"
assert $jsonObj["cat"]["a"][0] == "\"woof\""

assert $jsonObj == """{"cat":{"a":["woof",["meow"],2]}}"""

assert jsonObj.toJsonNode.pretty == parseJSON(strToParse).pretty
echo jsonObj.toJsonNode.pretty
