/*
 * Base64 encoding/decoding (RFC1341)
 * Copyright (c) 2005-2011, Jouni Malinen <j@w1.fi>
 *
 * This software may be distributed under the terms of the BSD license.
 * See README for more details.
 */

#include <stdlib.h>
#include <string.h>
#include "base64.h"

static const unsigned char base64_table[65] =
	"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

/**
 * base64_encode - Base64 encode
 * @src: Data to be encoded
 * @len: Length of the data to be encoded
 * @out_len: Pointer to output length variable, or %NULL if not used
 * Returns: Allocated buffer of out_len bytes of encoded data,
 * or %NULL on failure
 *
 * Caller is responsible for freeing the returned buffer. Returned buffer is
 * nul terminated to make it easier to use as a C string. The nul terminator is
 * not included in out_len.
 */
unsigned char * base64_encode(const unsigned char *src, size_t len,
                  size_t *out_len)
{
    unsigned char *out, *pos;
    const unsigned char *end, *in;
    size_t olen;
    int line_len;

    olen = len * 4 / 3 + 4; /* 3-byte blocks to 4-byte */
    olen += olen / 72; /* line feeds */
    olen++; /* nul termination */
    if (olen < len)
        return NULL; /* integer overflow */
    out = malloc(olen);
    if (out == NULL)
        return NULL;

    end = src + len;
    in = src;
    pos = out;
    line_len = 0;
    while (end - in >= 3) {
        *pos++ = base64_table[in[0] >> 2];
        *pos++ = base64_table[((in[0] & 0x03) << 4) | (in[1] >> 4)];
        *pos++ = base64_table[((in[1] & 0x0f) << 2) | (in[2] >> 6)];
        *pos++ = base64_table[in[2] & 0x3f];
        in += 3;
        line_len += 4;
        if (line_len >= 72) {
            *pos++ = '\n';
            line_len = 0;
        }
    }

    if (end - in) {
        *pos++ = base64_table[in[0] >> 2];
        if (end - in == 1) {
            *pos++ = base64_table[(in[0] & 0x03) << 4];
            *pos++ = '=';
        } else {
            *pos++ = base64_table[((in[0] & 0x03) << 4) |
                          (in[1] >> 4)];
            *pos++ = base64_table[(in[1] & 0x0f) << 2];
        }
        *pos++ = '=';
        line_len += 4;
    }

    if (line_len)
        *pos++ = '\n';

    *pos = '\0';
    if (out_len)
        *out_len = pos - out;
    return out;
}


/**
 * base64_decode - Base64 decode
 * @src: Data to be decoded
 * @len: Length of the data to be decoded
 * @out_len: Pointer to output length variable
 * Returns: Allocated buffer of out_len bytes of decoded data,
 * or %NULL on failure
 *
 * Caller is responsible for freeing the returned buffer.
 */
unsigned char * base64_decode(const unsigned char *src, size_t len,
                  size_t *out_len)
{
    unsigned char dtable[256], *out, *pos, block[4], tmp;
    size_t i, count, olen;
    int pad = 0;

    memset(dtable, 0x80, 256);
    // Original code:
    // (we need to process ASCII value on an EBCDIC system, so this won't work)
    // for (i = 0; i < sizeof(base64_table) - 1; i++)
    //     dtable[base64_table[i]] = (unsigned char) i;
    // dtable['='] = 0;

    dtable[43] = 62;
    dtable[47] = 63;
    dtable[48] = 52;
    dtable[49] = 53;
    dtable[50] = 54;
    dtable[51] = 55;
    dtable[52] = 56;
    dtable[53] = 57;
    dtable[54] = 58;
    dtable[55] = 59;
    dtable[56] = 60;
    dtable[57] = 61;
    dtable[61] =  0;
    dtable[65] =  0;
    dtable[66] =  1;
    dtable[67] =  2;
    dtable[68] =  3;
    dtable[69] =  4;
    dtable[70] =  5;
    dtable[71] =  6;
    dtable[72] =  7;
    dtable[73] =  8;
    dtable[74] =  9;
    dtable[75] = 10;
    dtable[76] = 11;
    dtable[77] = 12;
    dtable[78] = 13;
    dtable[79] = 14;
    dtable[80] = 15;
    dtable[81] = 16;
    dtable[82] = 17;
    dtable[83] = 18;
    dtable[84] = 19;
    dtable[85] = 20;
    dtable[86] = 21;
    dtable[87] = 22;
    dtable[88] = 23;
    dtable[89] = 24;
    dtable[90] = 25;
    dtable[97] = 26;
    dtable[98] = 27;
    dtable[99] = 28;
    dtable[100] = 29;
    dtable[101] = 30;
    dtable[102] = 31;
    dtable[103] = 32;
    dtable[104] = 33;
    dtable[105] = 34;
    dtable[106] = 35;
    dtable[107] = 36;
    dtable[108] = 37;
    dtable[109] = 38;
    dtable[110] = 39;
    dtable[111] = 40;
    dtable[112] = 41;
    dtable[113] = 42;
    dtable[114] = 43;
    dtable[115] = 44;
    dtable[116] = 45;
    dtable[117] = 46;
    dtable[118] = 47;
    dtable[119] = 48;
    dtable[120] = 49;
    dtable[121] = 50;
    dtable[122] = 51;
    
    count = 0;
    for (i = 0; i < len; i++) {
        if (dtable[src[i]] != 0x80)
            count++;
    }

    if (count == 0 || count % 4)
        return NULL;

    olen = count / 4 * 3;
    pos = out = malloc(olen);
    if (out == NULL)
        return NULL;

    count = 0;
    for (i = 0; i < len; i++) {
        tmp = dtable[src[i]];
        if (tmp == 0x80)
            continue;

        if (src[i] == '=')
            pad++;
        block[count] = tmp;
        count++;
        if (count == 4) {
            *pos++ = (block[0] << 2) | (block[1] >> 4);
            *pos++ = (block[1] << 4) | (block[2] >> 2);
            *pos++ = (block[2] << 6) | block[3];
            count = 0;
            if (pad) {
                if (pad == 1)
                    pos--;
                else if (pad == 2)
                    pos -= 2;
                else {
                    /* Invalid padding */
                    free(out);
                    return NULL;
                }
                break;
            }
        }
    }

    *out_len = pos - out;
    return out;
}