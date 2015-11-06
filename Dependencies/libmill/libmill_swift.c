// libmill_swift.c
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

#include "libmill_swift.h"

void co(void (^routine)(void)) {
    void *mill_sp = mill_go_prologue();
    if(mill_sp) {
        int mill_anchor[mill_unoptimisable1];
        mill_unoptimisable2 = &mill_anchor;
        char mill_filler[(char*)&mill_anchor - (char*)(mill_sp)];
        mill_unoptimisable2 = &mill_filler;
        routine();
        mill_go_epilogue();
    }
}

size_t mill_clauselen() {
    return MILL_CLAUSELEN;
}

pid_t mill_fork() {
    return fork();
}
