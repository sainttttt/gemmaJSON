import system/ctypes
include ./gemmaJSON/compile

type gemmaJSON = pointer

type
  GemmaNodeType* = enum
    Unknown, String, Int, Array, Object

type gemmaNode* = object
  nodeType: GemmaNodeType
  json: gemmaJSON
  dataString: string
  dataInt: int

proc newParser(): pointer  {.importc: "gemmasimdjson_parser_new",
                              header: "gemmasimdjsonc.h".}
proc elementSizeOf(): csize_t  {.importc: "gemmasimdjson_element_sizeof",
                                  header: "gemmasimdjsonc.h".}
proc arraySizeOf(array: gemmaJSON): csize_t {. importc: "gemmasimdjson_array_size",
                                                header: "gemmasimdjsonc.h".}
proc parserParse( parser: pointer, element: pointer,
                    data: cstring, len: csize_t): bool  {.importc: "gemmasimdjson_parser_parse",
                                                           header: "gemmasimdjsonc.h".}
proc getStr(attrname: cstring, attrlen: csize_t,
             element: pointer, output: var cstring,
           outputlen: var csize_t): bool  {.importc: "gemmasimdjson_element_get_str",
                                             header: "gemmasimdjsonc.h".}
proc gemmasimdjson_element_get_int64_t(attrname: cstring, attrlen: csize_t,
                                           e: pointer, output: ptr cint) {.importc: "gemmasimdjson_element_get_int64_t",
                                                                            header: "gemmasimdjsonc.h".}
proc gemmasimdjson_element_get(attrname: cstring, attrlen: csize_t,
                                   e: pointer, output_element: pointer): bool {.importc: "gemmasimdjson_element_get",
                                                                                 header: "gemmasimdjsonc.h".}
proc gemmasimdjson_element_get_type(attrname: cstring, attrlen: csize_t,
                                        e: pointer): char {.importc: "gemmasimdjson_element_get_type",
                                                             header: "gemmasimdjsonc.h".}

proc parseGemmaJSON*(s: string): gemmaNode =
  var parser = newParser()
  var gemmaJSON = alloc0(elementSizeof())
  var success = parserParse(parser, gemmaJSON, s, s.len.c_size_t)
  # var type = gemmasimdjson_element_get_type("", cast[csize_t](0), gemmaJSON)
  return gemmaNode(json: cast[gemmaJSON](gemmaJSON))

proc getStr*(g: gemmaJSON, attr: string): string =
  var outstr: cstring
  var outstrsize: csize_t
  var error = getStr(attr.cstring, attr.len.csize_t, g, outstr, outstrsize)
  return $outstr


proc getElement*(n: gemmaNode, attr: string): gemmaNode =
  var gemmaJSON = alloc0(elementSizeof())
  var node =  gemmaNode(json: cast[gemmaJSON](gemmaJSON))
  var error = gemmasimdjson_element_get(attr.cstring, attr.len.csize_t, n.json, node.json)
  return node

proc getInt*(g: gemmaJSON, attr: string): int =
  var outInt: cint
  gemmasimdjson_element_get_int64_t(attr.cstring, attr.len.csize_t, g, addr outInt)
  return outInt.int

proc type*(n: var gemmaNode): GemmaNodeType =
  if n.nodeType == GemmaNodeType.Unknown:
    var nodeType = gemmasimdjson_element_get_type("", cast[csize_t](0), n.json)
    if nodeType == 'i':
      n.nodeType = GemmaNodeType.Int
    elif nodeType == 's':
      n.nodeType = GemmaNodeType.String
    elif nodeType == 'A':
      n.nodeType = GemmaNodeType.Array
    elif nodeType == 'O':
      n.nodeType = GemmaNodeType.Object

  return n.nodeType

proc type*(n: gemmaNode): GemmaNodeType =
  var nodeType = gemmasimdjson_element_get_type("", cast[csize_t](0), n.json)
  if nodeType == 'i':
    return GemmaNodeType.Int
  elif nodeType == 's':
    return GemmaNodeType.String
  elif nodeType == 'A':
    return GemmaNodeType.Array
  elif nodeType == 'O':
    return GemmaNodeType.Object


proc getInt*(n: gemmaNode, attr: string = ""): int =
  return n.json.getInt(attr)

proc getStr*(n: gemmaNode, attr: string = ""): string =
  return n.json.getStr(attr)

proc `[]`*(n: gemmaNode, attr: string): gemmaNode =
  return n.getElement(&"/{attr}")

proc `[]`*(n: gemmaNode, index: int): gemmaNode =
  return n.getElement(&"/{index}")

proc `$`*(n: gemmaNode): string =
  if n.type == GemmaNodeType.String:
    return n.getStr("")
  elif n.type == GemmaNodeType.Int:
    return n.getInt("").`$`
  elif n.type == GemmaNodeType.Object:
    return "[Object]"
  elif n.type == GemmaNodeType.Array:
    return "[Array]"


iterator items*(n: gemmaNode): gemmaNode =
  if n.type != GemmaNodeType.Array:
    yield gemmaNode()

  var numItems = n.json.arraySizeOf.int
  for i in 0..numItems - 1:
    var indexStr = &"/{i}"
    yield n.getElement(indexStr)
