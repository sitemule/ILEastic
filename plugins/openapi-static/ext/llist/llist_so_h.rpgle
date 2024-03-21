**FREE

///
// Linked List : Sorting Algorithms
//
// @author Mihael Schmidt
// @date   2009-02-17
// @project Linked List
///

/if not defined(LLIST_SORT)
/define LLIST_SORT

//------------------------------------------------------------------------------
//                          The MIT License (MIT)
//
// Copyright (c) 2017 Mihael Schmidt
//
// Permission is hereby granted, free of charge, to any person obtaining a copy 
// of this software and associated documentation files (the "Software"), to deal 
// in the Software without restriction, including without limitation the rights 
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell 
// copies of the Software, and to permit persons to whom the Software is 
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in 
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
// SOFTWARE.
//------------------------------------------------------------------------------


///
// Insertion sort
//
// The list will be sorted inline. If no compare procedure has been passed the
// list will by sorted by bytes using <em>memcmp</em>.
//
// @author Mihael Schmidt
// @date   2009-02-17
//
// @param Pointer to the list
// @param Pointer to the compare procedure (optional)
///
dcl-pr list_sort_insertionSort extproc('list_sort_insertionSort');
  list pointer const;
  compare pointer(*proc) const options(*nopass);
end-pr;

/endif
