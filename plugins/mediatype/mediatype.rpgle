**FREE

///
// ILEastic : MEDIATYPE Plugin
//
// Plugin to parse mediatypes from Accept headers
//
// @author Rafal Gala
// @date 2024-12-30
///

ctl-opt nomain thread(*concurrent) ccsid(*exact);

/include 'headers/ileastic.rpgle'
/include 'mediatype_h.rpginc'

dcl-proc il_mediatype_getAcceptedMediaTypes export;
  dcl-pi *n int(10);
    request  likeds(il_request);
    o_typeList likeds(mediaType_t) dim(IL_MAX_MEDIA_TYPE_LIST_LENGTH) options(*exact);
    o_typeListLen uns(10);
  end-pi;
  
  dcl-s ptr pointer;
  dcl-s accept like(IL_LONGUTF8VARCHAR);
  dcl-s header like(IL_LONGUTF8VARCHAR);
  dcl-s comma char(1) ccsid(*utf8) inz(',');
  dcl-s qsep char(2) ccsid(*utf8) inz('q=');
  dcl-s pos int(5);
  dcl-s start int(5) inz(1);
  dcl-s len int(5);
  dcl-ds preferred likeds(mediaType_t);
  dcl-ds mediaType likeds(mediaType_t) inz(*likeds);
  dcl-s head ind;
  dcl-s i int(10) inz(0);
  dcl-s j int(10) inz(1);

  accept = il_getRequestHeader(request : %char('Accept'));
  if (accept = *blanks);
    o_typeList(1).type = '*';
    o_typeList(1).subtype = '*';
    o_typeListLen = 1;
    return 0;
  endif;

  dou pos = 0;
    pos = %scan(comma : accept);
    if pos > 0;
      header = %subst(accept : 1 : pos - 1);
      accept = %scanrpl(%subst(accept : 1 : pos) : %char('' : *utf8) : accept);
    else;
      header = accept;
    endif;

    i += 1;
    if i = IL_MAX_MEDIA_TYPE_LIST_LENGTH;
      leave;
    endif;
    o_typeList(i) = il_mediatype_parseMediaType(header);
  enddo;

  SORTA(D) %subarr(o_typeList : 1 : i) %fields(q : genericity);
  o_typeListLen = i;

  return 0;
end-proc;

dcl-proc il_mediatype_getPreferredAcceptedMediaType export;
  dcl-pi *n likeds(mediaType_t);
    request likeds(il_request);
  end-pi;

  dcl-ds typeList likeds(mediaType_t) dim(IL_MAX_MEDIA_TYPE_LIST_LENGTH);
  dcl-s typeListLen uns(10);
  dcl-ds mediaType likeds(mediaType_t) inz(*likeds);

  il_mediatype_getAcceptedMediaTypes(request : typeList : typeListLen);

  if typeListLen = 0;
    mediaType.type = '*';
    mediaType.subtype = '*';
    return mediaType;
  else;
    return typeList(1);
  endif;

end-proc;

dcl-proc il_mediatype_isMediaTypeAccepted export;
  dcl-pi *n likeds(mediaType_t);
    request        likeds(il_request);
    mediaType1     pointer value options(*string:*nopass);
    mediaType2     pointer value options(*string:*nopass);
    mediaType3     pointer value options(*string:*nopass);
    mediaType4     pointer value options(*string:*nopass);
    mediaType5     pointer value options(*string:*nopass);
    mediaType6     pointer value options(*string:*nopass);
    mediaType7     pointer value options(*string:*nopass);
    mediaType8     pointer value options(*string:*nopass);
    mediaType9     pointer value options(*string:*nopass);
    mediaType10    pointer value options(*string:*nopass);
  end-pi;

  dcl-c MAX_PARAMETERS 10;
  dcl-s i int(10);
  dcl-s j int(10);
  dcl-ds result likeds(mediaType_t) inz(*likeds);
  dcl-ds typeList likeds(mediaType_t) dim(IL_MAX_MEDIA_TYPE_LIST_LENGTH);
  dcl-s typeListLen uns(10);
  dcl-ds mediatype likeds(mediatype_t);
  dcl-ds item likeds(mediatype_t);
  dcl-s parameter varchar(256);
  dcl-s idx int(10) inz(0);
  dcl-s ptr pointer;

  il_mediatype_getAcceptedMediaTypes(request : typeList : typeListLen);
  if typeListLen = 0;
    result.type = '*';
    result.subtype = '*';
    return result;
  endif;

  for i = 1 to %min(%parms - 1 : MAX_PARAMETERS);
    select i;
      when-is 1;
        ptr = mediatype1;
      when-is 2;
        ptr = mediaType2;
      when-is 3;
        ptr = mediaType3;
      when-is 4;
        ptr = mediaType4;
      when-is 5;
        ptr = mediaType5;
      when-is 6;
        ptr = mediaType6;
      when-is 7;
        ptr = mediaType7;
      when-is 8;
        ptr = mediaType8;
      when-is 9;
        ptr = mediaType9;
      when-is 10;
        ptr = mediaType10;
    endsl;

    if ptr = *null;
      iter;
    endif;
    parameter = %str(ptr);

    for j = 1 to typeListLen;
      item = typeList(j);
      mediatype = il_mediatype_parseMediaType(parameter);

      if (item.type = '*' or (item.type = mediatype.type and
        (item.subtype = mediatype.subtype or item.subtype = '*'))) and
        (j < idx or idx = 0);
        result = mediatype;
        idx = j;
        leave;
      endif;
    endfor;
  endfor;

  return result;
end-proc;

dcl-proc il_mediatype_parseMediaType export;
  dcl-pi *n likeds(mediaType_t);
    value like(IL_LONGUTF8VARCHAR) const;
  end-pi;

  dcl-ds mediaType likeds(mediaType_t) inz(*likeds);
  dcl-s qsep char(2) ccsid(*utf8) inz('q=');
  dcl-s tsep char(1) ccsid(*utf8) inz('/');
  dcl-s scsep char(1) ccsid(*utf8) inz(';');
  dcl-s eqsep char(1) ccsid(*utf8) inz('=');
  dcl-s pos int(10);
  dcl-s i int(10) inz(1);
  dcl-s j int(10) inz(1);
  dcl-s charnum varchar(10);
  dcl-s segment varchar(256) ccsid(*utf8);
  dcl-ds extension likeds(mediaType_t.extensions);

  for-each segment in %split(value : scsep);
    // Type and subtype should come first
    if i = 1;
      pos = %scan(tsep : segment);
      if pos > 1;
        mediaType.type = %subst(segment : 1 : pos - 1);
        mediaType.subtype = %subst(segment : pos + 1);
      else;
        il_joblog(%char('Corrupted MIME type value ''%s''') : %char(segment));
      endif;
      if mediaType.type = '*' and mediaType.subtype = '*';
        mediaType.genericity = 1;
      else;
        if mediaType.type = '*';
          mediaType.genericity = 2;
        endif;
        if mediaType.subtype = '*';
          mediaType.genericity = 3;
        endif;
      endif;        
    else;
      pos = %scan(qsep : segment);
      if pos > 0;
        charnum = %subst(segment : pos + 2);
        monitor;
          mediaType.q = %dec(charnum : 2 : 1);
        on-error 00105;
          il_joblog(%char('Quality factor ''%s'' conversion error, resolving to 1') : charnum);
        endmon;
      else;
        pos = %scan(eqsep : segment);
        if pos > 0;
          extension.name = %subst(segment : 1 : pos - 1);
          extension.value = %subst(segment : pos + 1);
          mediaType.extensions(j) = extension;
          mediaType.extensionsLen = j;
          j += 1;
          if j > %elem(mediaType.extensions);
            il_joblog(%char('Exceeded maximum extensions array size'));
            leave;
          endif;
        else;
            // Corrupted extension
          il_joblog(%char('Corrupted extension ''%s''') : %char(segment));
        endif;
      endif;
    endif;
    i += 1;
  endfor;

  return mediaType;
end-proc;