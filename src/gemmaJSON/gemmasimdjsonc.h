#ifndef CYSIMDJSONAPI_H
#define CYSIMDJSONAPI_H

// This is API for C (not C++) level
// This header has to be C compliant

#include <stddef.h>
#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>

#ifdef __cplusplus
extern "C" {
#endif

  void * gemmasimdjson_parser_new(void);
  void gemmasimdjson_parser_del(void * parser);

  const size_t gemmasimdjson_element_sizeof(void);

  // `element` is a pointer with pre-allocated buffer of the size=gemmasimdjson_element_sizeof()
  bool gemmasimdjson_parser_parse(void * p, void * memory, char * data, size_t datalen);

  bool gemmasimdjson_element_get_str(const char * attrname, size_t attrlen, void * element, char ** output, size_t * outputlen);
  bool gemmasimdjson_element_get_int64_t(const char * attrname, size_t attrlen, void * element, int64_t * output);
  bool gemmasimdjson_element_get_uint64_t(const char * attrname, size_t attrlen, void * element, uint64_t * output);
  bool gemmasimdjson_element_get_bool(const char * attrname, size_t attrlen, void * element, bool * output);
  bool gemmasimdjson_element_get_double(const char * attrname, size_t attrlen, void * element, double * output);

  char gemmasimdjson_element_get_type(const char * attrname, size_t attrlen, void * element);
  bool gemmasimdjson_element_get(const char * attrname, size_t attrlen, void * element, void * output_element);

  int gemmasimdjson_parser_test(void);

  size_t gemmasimdjson_array_size(void * e);

  // Export element `e` as JSON into the "buffer" and returns the exported JSON size.
  // If the "buffer_size" is too small, returns 0;
char * gemmasimdjson_minify(void * e);

#endif

#ifdef __cplusplus
}
#endif
