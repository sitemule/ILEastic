**FREE

/if not defined (BASE64)
/define BASE64

///
// Base64 encode
//
// @param Data to be encoded
// @param Length of the data to be encoded
// @param Pointer to output length variable, or %NULL if not used
// @return Allocated buffer of out_len bytes of encoded data or *NULL on failure
//
// @info Caller is responsible for freeing the returned buffer. Returned buffer is null
//       terminated to make it easier to use as a C string. The null terminator is not
//       included in outputLength.
//
// @info The input is expected to be in CCSID 819. The output will be returned
//       in the native EBCDIC encoding.
///
dcl-pr base64_encode pointer extproc(*dclcase);
  input pointer value;
  inputLength uns(10) value;
  outputLength pointer value;
end-pr;

///
// Base64 decode
// 
// @param Data to be decoded
// @param Length of the data to be decoded
// @param Pointer to output length variable
// @return Allocated buffer of outputLength bytes of decoded data or *NULL on failure
//
// @info Caller is responsible for freeing the returned buffer.
//
// @info The input is expected to be in CCSID 819. The output will also be in 
//       CCSID 819.
///
dcl-pr base64_decode pointer extproc(*dclcase);
  input pointer value;
  inputLength uns(10) value;
  outputLength pointer value;
end-pr;

/endif