// incandescence_swift.c
//
// The MIT License (MIT)
//
// Copyright (c) 2015 Zewo
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#include "incandescence_swift.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct parsed_uri parse_uri(const char *uri_string) {
    struct http_parser_url u;
    http_parser_parse_url(uri_string, strlen(uri_string), 0, &u);

    struct parsed_uri uri = {
        u.field_set,
        u.field_data[0].off,
        u.field_data[0].off + u.field_data[0].len,
        u.field_data[6].off,
        u.field_data[6].off + u.field_data[6].len,
        u.field_data[1].off,
        u.field_data[1].off + u.field_data[1].len,
        u.port,
        u.field_data[3].off,
        u.field_data[3].off + u.field_data[3].len,
        u.field_data[4].off,
        u.field_data[4].off + u.field_data[4].len,
        u.field_data[5].off,
        u.field_data[5].off + u.field_data[5].len,
    };

    return uri;
}