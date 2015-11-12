/*

  Copyright (c) 2015 Martin Sustrik

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"),
  to deal in the Software without restriction, including without limitation
  the rights to use, copy, modify, merge, publish, distribute, sublicense,
  and/or sell copies of the Software, and to permit persons to whom
  the Software is furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included
  in all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
  THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
  IN THE SOFTWARE.

*/

#ifndef LIBMILL_H_INCLUDED
#define LIBMILL_H_INCLUDED

#include <errno.h>
#include <stddef.h>
#include <stdint.h>

/******************************************************************************/
/*  Symbol visibility                                                         */
/******************************************************************************/

#if defined MILL_NO_EXPORTS
#   define MILL_EXPORT
#else
#   if defined _WIN32
#      if defined MILL_EXPORTS
#          define MILL_EXPORT __declspec(dllexport)
#      else
#          define MILL_EXPORT __declspec(dllimport)
#      endif
#   else
#      if defined __SUNPRO_C
#          define MILL_EXPORT __global
#      elif (defined __GNUC__ && __GNUC__ >= 4) || \
             defined __INTEL_COMPILER || defined __clang__
#          define MILL_EXPORT __attribute__ ((visibility("default")))
#      else
#          define MILL_EXPORT
#      endif
#   endif
#endif

/******************************************************************************/
/*  Helpers                                                                   */
/******************************************************************************/

MILL_EXPORT int64_t now(void);

/******************************************************************************/
/*  Coroutines                                                                */
/******************************************************************************/

MILL_EXPORT int goprepare(int count, size_t stack_size, size_t val_size);

MILL_EXPORT extern volatile int mill_unoptimisable1;
MILL_EXPORT extern volatile void *mill_unoptimisable2;

MILL_EXPORT void *mill_go_prologue(void);
MILL_EXPORT void mill_go_epilogue(void);

MILL_EXPORT void mill_yield(void);
MILL_EXPORT void mill_msleep(int64_t deadline);

#define FDW_IN 1
#define FDW_OUT 2
#define FDW_ERR 4

MILL_EXPORT int mill_fdwait(int fd, int events, int64_t deadline);

/******************************************************************************/
/*  Channels                                                                  */
/******************************************************************************/

typedef struct mill_chan *chan;

#define MILL_CLAUSELEN (sizeof(struct{void *f1; void *f2; void *f3; void *f4; \
    void *f5; int f6; int f7; int f8;}))

MILL_EXPORT chan mill_chmake(size_t bufsz);
MILL_EXPORT void mill_chs(chan ch);
MILL_EXPORT void mill_chr(chan ch);
MILL_EXPORT void mill_chdone(chan ch);
MILL_EXPORT void mill_chclose(chan ch);

MILL_EXPORT void mill_choose_init(void);
MILL_EXPORT void mill_choose_in(void *clause, chan ch, int idx);
MILL_EXPORT void mill_choose_out(void *clause, chan ch, int idx);
MILL_EXPORT void mill_choose_otherwise(void);
MILL_EXPORT int mill_choose_wait(void);

MILL_EXPORT void mill_panic(const char *text);

/******************************************************************************/
/*  IP address library                                                        */
/******************************************************************************/

#define IPADDR_IPV4 1
#define IPADDR_IPV6 2
#define IPADDR_PREF_IPV4 3
#define IPADDR_PREF_IPV6 4

typedef struct {char data[32];} ipaddr;

MILL_EXPORT ipaddr iplocal(const char *name, int port, int mode);
MILL_EXPORT ipaddr ipremote(const char *name, int port, int mode, int64_t deadline);

/******************************************************************************/
/*  TCP library                                                               */
/******************************************************************************/

typedef struct mill_tcpsock *tcpsock;

MILL_EXPORT tcpsock tcplisten(ipaddr addr, int backlog);
MILL_EXPORT int tcpport(tcpsock s);
MILL_EXPORT tcpsock tcpaccept(tcpsock s, int64_t deadline);
MILL_EXPORT tcpsock tcpconnect(ipaddr addr, int64_t deadline);
MILL_EXPORT size_t tcpsend(tcpsock s, const void *buf, size_t len, int64_t deadline);
MILL_EXPORT void tcpflush(tcpsock s, int64_t deadline);
MILL_EXPORT size_t tcprecv(tcpsock s, void *buf, size_t len, int64_t deadline);
MILL_EXPORT size_t tcprecvlh(tcpsock s, void *buf, size_t lowwater, size_t highwater, int64_t deadline);
MILL_EXPORT size_t tcprecvuntil(tcpsock s, void *buf, size_t len, const char *delims, size_t delimcount, int64_t deadline);
MILL_EXPORT void tcpclose(tcpsock s);
MILL_EXPORT tcpsock tcpattach(int fd, int listening);
MILL_EXPORT int tcpdetach(tcpsock s);

#endif

