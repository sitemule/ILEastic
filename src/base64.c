/* SYSIFCOPT(*IFSIO) TERASPACE(*YES *TSIFC) STGMDL(*INHERIT) */
/* ------------------------------------------------------------- */
/* Design  . . . : Niels Liisberg                                */
/* Function  . . : Base 64 encoding and decoding                 */
/*                                                               */
/* By     Date       PTF     Description                         */
/* NL     24.04.2010         New program                         */
/* ------------------------------------------------------------- */
#include "ostypes.h"
#include "varchar.h"
#include "base64.h"

/* ------------------------------------------------------------- */

void il_encodeBase64(PLVARCHAR output, PLVARCHAR input )
{
#pragma convert(1252)
    static const UCHAR base64_pad = '=';
    static const UCHAR base64_table[] = 
        "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        "abcdefghijklmnopqrstuvwxyz"
        "0123456789+/";
#pragma convert(0)

    PUCHAR current = input->String;
    ULONG  inlen = input->Length;
    PUCHAR result = output->String;

    while (inlen > 2) {
        *result++ = base64_table[current[0] >> 2];
        *result++ = base64_table[((current[0] & 0x03) << 4) + (current[1] >> 4)];
        *result++ = base64_table[((current[1] & 0x0f) << 2) + (current[2] >> 6)];
        *result++ = base64_table[current[2] & 0x3f];

        current += 3;
        inlen -= 3; // always 3 bytes becomes 4 bytes
    }

    // now the tail: 2 and one bytes left
    if (inlen != 0) {
        *result++ = base64_table[current[0] >> 2];
        if (inlen > 1) {
            *result++ = base64_table[((current[0] & 0x03) << 4) + (current[1] >> 4)];
            *result++ = base64_table[(current[1] & 0x0f) << 2];
            *result++ = base64_pad;
        }
        else {
            *result++ = base64_table[(current[0] & 0x03) << 4];
            *result++ = base64_pad;
            *result++ = base64_pad;
        }
    }
    output->Length= result - output->String;
    *result = '\0';
}

/* ------------------------------------------------------------- */
void il_decodeBase64 (PLVARCHAR output, PLVARCHAR input )
{
#pragma convert(1252)
    static const UCHAR base64_pad = '=';
    static const UCHAR base64_table [] = {
        0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
        0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
        0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,   62, 0xff, 0xff, 0xff,   63,
        52  ,   53,   54,   55,   56,   57,   58,   59,   60,   61, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
        0xff,    0,    1,    2,    3,    4,    5,    6,    7,    8,    9,   10,   11 ,  12,   13,   14,
        15  ,   16,   17,   18,   19,   20,   21,   22,   23,   24,   25, 0xff, 0xff, 0xff, 0xff, 0xff,
        0xff,   26,   27,   28,   29,   30,   31,   32,   33,   34,   35,   36,   37,   38,   39,   40,
        41  ,   42,   43,   44,   45,   46,   47,   48,   49,   50,   51, 0xff, 0xff, 0xff, 0xff, 0xff
    };
#pragma convert(0)

    ULONG  i = 0, j = 0, k;
    UCHAR  ch, c;
    PUCHAR current = input->String;
    PUCHAR result = output->String;
    ULONG  inlength = input->Length;

    // Handle each byte
    while (inlength--) {
        c  = *current++;
        if (c  == base64_pad)          break;
        if (c >= sizeof(base64_table)) continue; // Only 128 bytes are defined
        ch = base64_table[c];
        if (ch == 0xff)                continue;

        switch(i % 4) {
        case 0:
            result[j] = ch << 2;
            break;
        case 1:
            result[j++] |= ch >> 4;
            result[j] = (ch & 0x0f) << 4;
            break;
        case 2:
            result[j++] |= ch >>2;
            result[j] = (ch & 0x03) << 6;
            break;
        case 3:
            result[j++] |= ch;
            break;
        }
        i++;
    }

    output->Length = k = j;

    // The final boudary 
    if (c  == base64_pad) {
        switch(i % 4) {
        case 0:
            return;
        case 1:
            output->Length = k + 1;
            return;
        case 2:
            k++;
        case 3:
            result[k++] = 0;
        }
    }

    result[k] = '\0';
}
