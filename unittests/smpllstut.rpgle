**free

ctl-opt nomain;

/include assert

dcl-ds SLISTNODE_t qualified template;
   pNext pointer; // struct SLISTNODE_t
   payLoadLength int(10);
   payloadData pointer;
end-ds;

dcl-ds SLIST_t qualified template;
   pHead pointer;
   pTail pointer;
   length int(10);
end-ds;

dcl-ds SLISTITERATOR_t qualified align(*full) template;
   pThis pointer; // pointer of type SLISTNODE_t
   pNext pointer; // pointer of type SLISTNODE_t
   hasNext ind;
end-ds;

dcl-ds SLISTKEYVAL_t qualified template;
   key likeds(LVARPUCHAR_t);
   value likeds(LVARPUCHAR_t);
end-ds;

dcl-ds LVARPUCHAR_t qualified template;
   length uns(10);
   string pointer;
end-ds;

dcl-ds PLVARCHAR_t qualified template;
   length int(10);
   string varchar(1024:4);
end-ds;

dcl-pr sList_new pointer extproc('sList_new');
end-pr;

dcl-pr sList_free extproc('sList_free');
   hSlist likeds(SLIST_t) const; // simpleList.c: PSLIST
end-pr;

dcl-pr sList_push pointer extproc(*CWIDEN: 'sList_push'); // SLISTNODE_t
   hSlist likeds(SLIST_t) const; // PSLIST
   len uns(10) value;
   data pointer options(*string) value;
   head ind value;
end-pr;

dcl-pr sList_pushLVPC pointer extproc('sList_pushLVPC');
   hSlist likeds(SLIST_t) const; // PSLIST
   key likeds(LVARPUCHAR_t) const;
   value likeds(LVARPUCHAR_t) const;
end-pr;

dcl-pr sList_lookupLVPC varchar(1024:4) rtnparm
                extproc('sList_lookupLVPC');
   hSlist likeds(SLIST_t) const; // PSLIST
   key varchar(1024:4) const;
end-pr;

dcl-pr sList_setIterator likeds(SLISTITERATOR_t) extproc('sList_setIterator');
   hSlist likeds(SLIST_t) const; // PSLIST
end-pr;

dcl-pr sList_foreach ind extproc('sList_foreach');
   iterator likeds(SLISTITERATOR_t) const; // simpleList.c: PSLISTITERATOR
end-pr;

dcl-c ENUM_ON *on;
dcl-c ENUM_OFF *off;

dcl-c TEST_VALUE_1 'It works!';
dcl-c TEST_VALUE_2 'The quick brown fox jumps over the lazy dog.';

dcl-s KEY_1 varchar(100) inz('content-type');
dcl-s VALUE_1 varchar(100) inz('text/xml');

dcl-s KEY_2 varchar(100) inz('transaction-id');
dcl-s VALUE_2 varchar(100) inz('my-transaction-id');

dcl-proc lvpc;
   dcl-pi *n likeds(LVARPUCHAR_t);
      string varchar(1024) options(*varsize);
   end-pi;

   dcl-ds lVarChar likeds(LVARPUCHAR_t) inz;

   lVarChar.length = %len(string);
   lVarChar.string = %addr(string: *data);

   return lVarChar;

end-proc;

//
// Test Procedures
//
dcl-proc test_simpleList export;

   dcl-ds hSimpleList likeds(SLIST_t) based(pSimpleList);

   dcl-ds listNode1 likeds(SLISTNODE_t) based(pListNode1);
   dcl-ds listNode2 likeds(SLISTNODE_t) based(pListNode2);
   dcl-s data1 char(512) based(listNode1.payloadData);
   dcl-s data2 char(512) based(listNode2.payloadData);

   dcl-s  count int(10);
   dcl-ds hListIterator likeds(SLISTITERATOR_t) inz;
   dcl-ds listOfNodeIterator likeds(SLISTNODE_t) based(hListIterator.pThis);
   dcl-s dataOfIterator char(512) based(listOfNodeIterator.payloadData);

   // TODO: initialize handle sub-fields in sList_new()
   //       RPG does not initialize sub-fields by default
   pSimpleList = sList_new();

   assert(hSimpleList.length = 0: 'hSimpleList.length must equal 0');

   hListIterator = sList_setIterator(hSimpleList);
   assert(not hListIterator.hasNext: 'Lister iterator must have no entries');

   pListNode1 = sList_push(hSimpleList: %size(TEST_VALUE_1): TEST_VALUE_1: ENUM_OFF);
   assert(hSimpleList.length = 1: 'hSimpleList.length must equal 1');

   pListNode2 = sList_push(hSimpleList: %size(TEST_VALUE_2): TEST_VALUE_2: ENUM_ON);
   assert(hSimpleList.length = 2: 'hSimpleList.length must equal 2');

   assert(%subst(data1: 1: listNode1.payLoadLength) = TEST_VALUE_1
          : 'Data of test node 1 must match');

   assert(%subst(data2: 1: listNode2.payLoadLength) = TEST_VALUE_2
          : 'Data of test node 2 must match');

   // Return value: SLISTITERATOR_t
   hListIterator = sList_setIterator(hSimpleList);

   count = 0;
   dow (sList_foreach(hListIterator));
      count += 1;
      if (count = 1);
         assert(%subst(dataOfIterator: 1: listOfNodeIterator.payLoadLength) = TEST_VALUE_2
                : 'Data of test node ' + %char(count) + ' must match');
      else;
         assert(%subst(dataOfIterator: 1: listOfNodeIterator.payLoadLength) = TEST_VALUE_1
                : 'Data of test node ' + %char(count) + ' must match');
      endif;
   enddo;

   assert(count = hSimpleList.length: '''count'' must match ''hSimpleList.length''');

on-exit;

   sList_free(hSimpleList);

end-proc;

dcl-proc test_keyedList export;

   dcl-ds hKeyedList likeds(SLIST_t) based(pSimpleList);
   dcl-s value1 varchar(1024);
   dcl-s value2 varchar(1024);

   // TODO: initialize handle sub-fields in sList_new()
   //       RPG does not initialize sub-fields by default
   pSimpleList = sList_new();

   sList_pushLVPC(hKeyedList: lvpc(KEY_1): lvpc(VALUE_1));
   assert(hKeyedList.length = 1: 'hSimpleList.length must equal 1');

   sList_pushLVPC(hKeyedList: lvpc(KEY_2): lvpc(VALUE_2));
   assert(hKeyedList.length = 2: 'hSimpleList.length must equal 2');

   value1 = sList_lookupLVPC(hKeyedList: KEY_1);
   assert(value1 = VALUE_1: '''value1'' does not match extected value');

   value2 = sList_lookupLVPC(hKeyedList: KEY_2);
   assert(value2 = VALUE_2: '''value2'' does not match extected value');

on-exit;

   sList_free(hKeyedList);

end-proc;



