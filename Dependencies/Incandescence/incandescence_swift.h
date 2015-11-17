// incandescence_swift.h
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

#ifndef http_parser_swift_h
#define http_parser_swift_h

#include "http_parser.h"

struct parsed_uri {
    const uint16_t field_set;

    const uint16_t scheme_start;
    const uint16_t scheme_end;

    const uint16_t user_info_start;
    const uint16_t user_info_end;

    const uint16_t host_start;
    const uint16_t host_end;

    const unsigned short port;

    const uint16_t path_start;
    const uint16_t path_end;

    const uint16_t query_start;
    const uint16_t query_end;

    const uint16_t fragment_start;
    const uint16_t fragment_end;
};

struct parsed_uri parse_uri(const char *uri_string);

#endif /* http_parser_swift_h */
