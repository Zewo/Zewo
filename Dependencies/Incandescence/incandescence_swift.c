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

    struct parsed_uri uri = {};
    const char *start = 0;
    uint16_t length = 0;

    // has scheme
    if (u.field_set & (1 << 0)) {
        start = uri_string + u.field_data[0].off;
        length = u.field_data[0].len;

        char *scheme = (char *) malloc(sizeof(char) * length + 1);
        strncpy(scheme, start, length);
        scheme[length] = '\0';
        uri.scheme = scheme;
    }

    // has host
    if (u.field_set & (1 << 1)) {
        start = uri_string + u.field_data[1].off;
        length = u.field_data[1].len;

        char *host = (char *) malloc(sizeof(char) * length + 1);
        strncpy(host, start, length);
        host[length] = '\0';
        uri.host = host;
    }

    // has port
    if (u.field_set & (1 << 2)) {
        unsigned short *port = (unsigned short *) malloc(sizeof(unsigned short));
        *port = u.port;
        uri.port = port;
    }

    // has path
    if (u.field_set & (1 << 3)) {
        start = uri_string + u.field_data[3].off;
        length = u.field_data[3].len;

        char *path = (char *) malloc(sizeof(char) * length + 1);
        strncpy(path, start, length);
        path[length] = '\0';
        uri.path = path;
    }

    // has query
    if (u.field_set & (1 << 4)) {
        start = uri_string + u.field_data[4].off;
        length = u.field_data[4].len;

        char *query = (char *) malloc(sizeof(char) * length + 1);
        strncpy(query, start, length);
        query[length] = '\0';
        uri.query = query;
    }

    // has fragment
    if (u.field_set & (1 << 5)) {
        start = uri_string + u.field_data[5].off;
        length = u.field_data[5].len;

        char *fragment = (char *) malloc(sizeof(char) * length + 1);
        strncpy(fragment, start, length);
        fragment[length] = '\0';
        uri.fragment = fragment;
    }

    // has user info
    if (u.field_set & (1 << 6)) {
        start = uri_string + u.field_data[6].off;
        length = u.field_data[6].len;

        char *user_info = (char *) malloc(sizeof(char) * length + 1);
        strncpy(user_info, start, length);
        user_info[length] = '\0';
        uri.user_info = user_info;
    }

    return uri;
}

void free_parsed_uri(struct parsed_uri uri) {
    free((void *) uri.scheme);
    free((void *) uri.user_info);
    free((void *) uri.host);
    free((void *) uri.port);
    free((void *) uri.path);
    free((void *) uri.query);
    free((void *) uri.fragment);
}