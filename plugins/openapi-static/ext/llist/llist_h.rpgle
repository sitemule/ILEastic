**FREE

/if not defined(LLIST)
/define LLIST

///
// Linked List Implementation
//
// This is a typical Doubly-Linked List (Two-Way Linked List) Implementation
// using dynamic memory allocation. The list is particular suitable for
// character values but does also work with any other data (f. e. data
// structures).
//
// <br><br>
//
// Values are stored as null-terminated chars.
//
// <br><br>
//
// Operations that index into the list will traverse the list from
// the beginning or the end, whichever is closer to the specified index.
//
// <br><br>
//
// <b>Iteration:</b> With the procedure <em>getNext</em> the list is
// traversable in the top-bottom direction. Each call to <em>getNext</em>
// will return the next entry of the list till the end of the list.
// If the walk through the list should be stopped early (before the end
// of the list) the method <em>abortIteration</em> should be called.
// If the list is structurally modified at any time
// after an iteration has begun in any way, the result of the iteration
// can not be safely determined. If an iteratioj is not going to continue
// the procedure <em>abortIteration</em> should be called. After that
// call it is safe to modify the list again.
//
// <br><br>
//
// Throughout this service program a zero-based index is used.
//
// <br><br>
//
// This list implementation is not thread-safe.
//
// @author Mihael Schmidt
// @date   20.12.2007
// @project Linked List
//
// @rev 22.11.2009 Mihael Schmidt
//      Added sorting support <br>
//      Changed memory management to user created heap <br>
//      Added removeRange procedure <br>
//      Bug fix: list_addAll does not work if value has x'00'
//
// @rev 15.12.2009 Mihael Schmidt
//      Added merge procedure
//
// @rev 19.02.2011 Mihael Schmidt
//      Fixed list_sublist procedure <br>
//      Added list_resetIteration <br>
//      Deprecated list_abortIteration <br>
//      Added list_iterate <br>
//      Deprecated list_getNext <br>
//      Userdata parameter on list_foreach is now optional <br>
//      list_merge got new parameter to only optionally skip duplicate entries
//
// @rev 07.06.2018 Mihael Schmidt
//      Changed sort API <br>
//      Escape messages are now sent to the current call stack entry +1 
//      instead of the program control boundary <br>
//
///

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


//-------------------------------------------------------------------------
// Prototypes
//-------------------------------------------------------------------------

///
// Create list
//
// Creates a list. A header is generated for the list and the pointer to
// the list returned.
//
// <br><br>
//
// A list must be disposed via the procedure <em>dispose</em> to free all
// allocated memory.
//
// @author Mihael Schmidt
// @date   18.12.2007
//
// @return Pointer to the list
///
dcl-pr list_create pointer extproc('list_create') end-pr;

///
// Dispose list
//
// The memory for whole list are is released
// (deallocated). The list pointer is set to *null;
//
// <br><br>
//
// If the passed pointer is already *null the procedure simply returns.
//
// @author Mihael Schmidt
// @date   18.12.2007
//
// @param Pointer to the list
///
dcl-pr list_dispose extproc('list_dispose');
  list pointer;
end-pr;

///
// Add list entry
//
// Adds an entry at an exact position in the list. If the position is
// outside the list the procedure returns <em>*off</em>. The current
// entry of the list at that position will be pushed one position down
// the list.
//
// <br><br>
//
// If no position is passed to the procedure then the entry will be
// appended to the end of the list (like <em>addLast</em>).
//
// @author Mihael Schmidt
// @date   18.12.2007
//
// @param Pointer to the list
// @param Pointer to the new value
// @param Length of the new value
// @param List position for the new value (optional)
//
// @return *on = entry added the list <br>
//         *off = error
///
dcl-pr list_add ind extproc('list_add');
  list pointer const;
    value pointer const;
  length uns(10) const;
  position uns(10) const options(*nopass);
end-pr;

///
// Add list entry to the top of the list
//
// @author Mihael Schmidt
// @date   18.12.2007
//
// @param Pointer to the list
// @param Pointer to new value
// @param Length of new value
//
// @return *on = successful <br>
//         *off = error
///
dcl-pr list_addFirst ind extproc('list_addFirst');
  list pointer;
  value pointer const;
  length uns(10) const;
end-pr;

///
// Add list entry to the end of the list
//
// @author Mihael Schmidt
// @date   18.12.2007
//
// @param Pointer to the list
// @param Pointer to new value
// @param Length of new value
//
// @return *on = successful <br>
//         *off = error
///
dcl-pr list_addLast ind extproc('list_addLast');
  list pointer const;
  value pointer const;
  length uns(10) const;
end-pr;

///
// Add all elements of a list
//
// Adds all elements of the passed list to the end of this list.
// Elements will not be referenced but storage newly allocated.
//
// @author Mihael Schmidt
// @date   18.12.2007
//
// @param Pointer to the destination list
// @param Pointer to the source list
//
// @return *on = all elements added to list <br>
//         *off = not all or none elements added
///
dcl-pr list_addAll ind extproc('list_addAll');
  list pointer const;
  sourceList pointer const;
end-pr;

///
// Remove list entry
//
// Removes an entry from the list at the given position. If the
// position is outside of the list the return value will be <em>*off</em>.
//
// <br><br>
//
// The index is 0 (zero) based.
//
// @author Mihael Schmidt
// @date   18.12.2007
//
// @param Pointer to the list
// @param index of the entry in the list (zero-based)
//
// @return *on = entry removed
//         *off = error
///
dcl-pr list_remove ind extproc('list_remove');
  list pointer const;
  index uns(10) const;
end-pr;

///
// Remove first list entry
//
// Removes the first entry from the list.
//
// @author Mihael Schmidt
// @date   18.12.2007
//
// @param Pointer to the list
//
// @return *on = entry removed <br>
//         *off = error
///
dcl-pr list_removeFirst ind extproc('list_removeFirst');
  list pointer const;
end-pr;

///
// Remove last list entry
//
// Removes the last entry from the list.
//
// @author Mihael Schmidt
// @date   18.12.2007
//
// @param Pointer to the list
//
// @return *on = entry removed <br>
//         *off = error (escape message)
///
dcl-pr list_removeLast ind extproc('list_removeLast');
  list pointer const;
end-pr;

///
// Clear list
//
// Deletes all entries in the list.
//
// @author Mihael Schmidt
// @date   18.12.2007
//
// @param Pointer to the list
//
// @return *on = successful <br>
//         *off = error
///
dcl-pr list_clear ind extproc('list_clear');
  list pointer const;
end-pr;

///
// Check if list is empty
//
// Checks if the list is empty.
//
// @author Mihael Schmidt
// @date   19.12.2007
//
// @param Pointer to the list
//
// @return *on = list is empty <br>
//         *off = list is not empty
///
dcl-pr list_isEmpty ind extproc('list_isEmpty');
  list pointer const;
end-pr;

///
// Replaces an entry in the list
//
// An element in the list will be replaced. If there is no element
// at that position the return value will be <em>*off</em>.
//
// @author Mihael Schmidt
// @date   19.12.2007
//
// @param Pointer to the list
// @param Pointer to new value
// @param Length of new value
// @param index of new value
//
// @return *on = entry successfully replaced <br>
//         *off = error
///
dcl-pr list_replace ind extproc('list_replace');
  list pointer const;
  value pointer const;
  length uns(10) const;
  index uns(10) const;
end-pr;

///
// Get entry
//
// Returns a list entry specified by the passed index.
//
// @author Mihael Schmidt
// @date   19.12.2007
//
// @param Pointer to the list
// @param List position
//
// @return Pointer to a null terminated string or
//         *null if an error occured or there is no
//         entry at that position
///
dcl-pr list_get pointer extproc('list_get');
  list pointer const;
  index uns(10) const;
end-pr;

///
// Get first entry
//
// Returns the first entry of the list.
//
// @author Mihael Schmidt
// @date   19.12.2007
//
// @param Pointer to the list
//
// @return Pointer to a null terminated string or
//         *null if the list is empty or an error occured
///
dcl-pr list_getFirst pointer extproc('list_getFirst');
  list pointer const;
end-pr;

///
// Get last entry
//
// Returns the last entry of the list.
//
// @author Mihael Schmidt
// @date   19.12.2007
//
// @param Pointer to the list
//
// @return Pointer to a null terminated string or
//         *null if the list is empty or an error occured
///
dcl-pr list_getLast pointer extproc('list_getLast');
  list pointer const;
end-pr;

///
// Get next entry
//
// Iterates through the list and gets the next entry. If the iterator is
// at the end of the list this method will return <em>null</em>. The
// iteration can be aborted early with the procedure <em>
// list_resetIteration</em>.
//
// @author Mihael Schmidt
// @date   18.12.2007
//
// @param Pointer to the list
//
// @return Pointer to entry or *null if no more entries in list
//
// @deprecated Use <em>list_iterate</em> instead.
///
dcl-pr list_getNext pointer extproc('list_getNext');
  list pointer const;
end-pr;

///
// Iterate list
//
// Iterates through the list and returns the next entry. If the iterator is
// at the end of the list this method will return <em>null</em>. The
// iteration can be aborted early with the procedure <em>list_resetIteration</em>.
//
// @author Mihael Schmidt
// @date   19.2.2011
//
// @param Pointer to the list
//
// @return Pointer to entry or *nll if no more entries in list
///
dcl-pr list_iterate pointer extproc('list_iterate');
  list pointer const;
end-pr;

///
// Get previous entry
//
// Iterates through the list and gets the previous entry. If the iterator is
// before the start of the list this method will return <em>null</em>. The
// iteration can be aborted early with the procedure <em>list_resetIteration</em>.
//
// @author Mihael Schmidt
// @date   18.12.2007
//
// @param Pointer to the list
//
// @return Pointer to entry or *null if no more entries in list
///
dcl-pr list_getPrev pointer extproc('list_getPrev');
  list pointer const;
end-pr;

///
// Abort iteration
//
// If the iteration through the list should be aborted early this
// procedure should be called.
//
// @author Mihael Schmidt
// @date   18.12.2007
//
// @param Pointer to the list
//
// @deprecated Use <em>list_resetIteration</em> instead.
///
dcl-pr list_abortIteration extproc('list_abortIteration');
  list pointer const;
end-pr;

///
// Reset iteration
//
// Resets the internal iteration state of the list so that the next
// call to <em>list_iterate</em> will return the first element.
//
// @author Mihael Schmidt
// @date   19.2.2011
//
// @param Pointer to the list
///
dcl-pr list_resetIteration extproc('list_resetIteration');
  list pointer const;
end-pr;

///
// Contains entry
//
// Checks if this list contains the passed entry.
//
// @author Mihael Schmidt
// @date   19.12.2007
//
// @param Pointer to the list
// @param Pointer to value
// @param Length of value
//
// @return *on = list contains value <br>
//         *off = list does not contain value
///
dcl-pr list_contains ind extproc('list_contains');
  list pointer const;
  value pointer const;
  length uns(10) const;
end-pr;

///
// Index of entry
//
// Returns the index of the passed entry or -1 if the entry could not
// be found in the list.
//
// @author Mihael Schmidt
// @date   19.12.2007
//
// @param Pointer to the list
// @param Pointer to the value
// @param Length of the value
//
// @return index of the entry or -1 if entry not in list
///
dcl-pr list_indexOf int(10) extproc('list_indexOf');
  list pointer const;
  value pointer const;
  length uns(10) const;
end-pr;

///
// Last index of entry
//
// Returns the last indes of the passed entry or -1 if the entry
// could not be found in the list.
//
// @author Mihael Schmidt
// @date   19.12.2007
//
// @param Pointer to the list
// @param Pointer to the value
// @param Length of the value
//
// @return index of the entry or -1 if entry not in list
///
dcl-pr list_lastIndexOf int(10) extproc('list_lastIndexOf');
  list pointer const;
  value pointer const;
  length uns(10) const;
end-pr;

///
// To character array
//
// Copies all entries of this list to the passed array. Entries will be
// truncated if they are too big for the array. If the array is not big
// enough, the last entries will be silently dropped.
//
// @author Mihael Schmidt
// @date   19.12.2007
//
// @param Pointer to the list
// @param Pointer to the array
// @param Element count
// @param Element length
//
///
dcl-pr list_toCharArray extproc('list_toCharArray');
  list pointer const;
  array pointer const;
  count uns(10) const;
  length uns(10) const;
end-pr;

///
// Get list size
//
// Returns the number elements in the list.
//
// @author Mihael Schmidt
// @date   16.01.2008
//
// @param Pointer to the list
//
// @return number of elements in the list or -1 if an error occurs
///
dcl-pr list_size uns(10) extproc('list_size');
  list pointer const;
end-pr;

///
// Create sublist
//
// Creates a list with copies of a part of the passed list.
//
// @author Mihael Schmidt
// @date   16.1.2008
//
// @param Pointer to the list
// @param start of the index to copy
// @param number of elements to copy
//
// @return new list
///
dcl-pr list_sublist pointer extproc('list_sublist');
  list pointer const;
  startIndex uns(10) const;
  length uns(10) const options(*nopass);
end-pr;

///
// Rotate list by n positions
//
// Rotatas items in the list by the given number.
//
// <br><br>
//
// The elements from the end will be pushed to the front.
// A rotation of one will bring the last element to the first
// position and the first element will become the second element
// (pushed one position down the list).
//
// <br><br>
//
// Only a forward rotation is possible. No negative number of
// rotations are valid.
//
// <br><br>
//
// The number of rotations may even be greater than the size of
// the list. Example: List size 4, rotation number 5 = rotation
// number 1.
//
// @author Mihael Schmidt
// @date   23.01.2008
//
// @param Pointer to the list
// @param Number positions to rotate list
///
dcl-pr list_rotate extproc('list_rotate');
  list pointer const;
  numberRotations int(10) const;
end-pr;

///
// Swap list items
//
//
// @author Mihael Schmidt
// @date   23.01.2008
//
// @param Pointer to the list
// @param List item to swap
// @param List item to swap
///
dcl-pr list_swap ind extproc('list_swap');
  list pointer const;
  itemPosition1 uns(10) const;
  itemPosition2 uns(10) const;
end-pr;

///
// Execute procedure for every list item
//
// The passed procedure will be executed for every item
// in the list.
//
// <br><br>
//
// The user can pass data through a pointer to the procedure.
// The pointer will not be touched by this procedure itself, so it
// can be *null.
//
// <br><br>
//
// The value of list entry can be changed through the passed procedure
// but not the size of the entry/allocated memory.
//
// @author Mihael Schmidt
// @date   23.01.2008
//
// @param Pointer to the list
// @param Procedure pointer
// @param Pointer to user data (optional)
///
dcl-pr list_foreach extproc('list_foreach');
  list pointer const;
  procecdure pointer(*proc) const;
  userData pointer const options(*nopass);
end-pr;

///
// Return character representation of list
//
// Returns a string with the list items separated either by
// the passed or default separator. The items can be
// enclosed by a passed character. The maximum character length
// returned is 65535. Every character/item after that will be
// dropped silently. Items will not be trimmed for this operation.
//
// <br><br>
//
// If the third parameter is passed, the third parameter will be
// pre- and appended to the item. If the fourth parameter is also
// passed the third parameter will be prepended to the item and the
// fourth parameter will be appended to the item.
//
// @author Mihael Schmidt
// @date   08.02.2008
//
// @param Pointer to the list
// @param separator (default: ,)
// @param enclosing character (default: nothing)
// @param enclosing character at the end of item (default: nothing)
//
// @return character representation of all list items
///
dcl-pr list_toString varchar(65535) extproc('list_toString');
  list pointer const;
  separator varchar(1) const options(*omit:*nopass);
  enclosing varchar(100) const options(*nopass);
  enclosingEnd varchar(100) const options(*nopass);
end-pr;

///
// Split character string
//
// The passed character string will be split into tokens by either
// a passed or the default separator. All tokens will be added to
// a new list which will be returned.
//
// <br><br>
//
// Empty (but not blank) values will be dropped silently.
//
// @author Mihael Schmidt
// @date   08.02.2008
//
// @param Character string (null-terminated)
// @param Separator (default: ;)
//
// @return Pointer to the filled list
///
dcl-pr list_split pointer extproc('list_split') opdesc;
  string char(65535) const options(*varsize);
  separator char(1) const options(*nopass);
end-pr;

///
// Reverse list
//
// Reverse the order of the list by simply switching the previous and
// next pointers of each element.
//
// @param Pointer to the list
///
dcl-pr list_reverse extproc('list_reverse');
  list pointer const;
end-pr;

///
// Create a copy of a list
//
// Creates a list with copies of all elements of the list.
//
// @author Mihael Schmidt
// @date   7.4.2008
//
// @param Pointer to the list
//
// @return Pointer to te new list
///
dcl-pr list_copy pointer extproc('list_copy');
  list pointer const;
end-pr;

///
// Frequency of a value in the list
//
// Returns the number of times the passed value
// can be found in the list.
//
// @author Mihael Schmidt
// @date   05.04.2008
//
// @param Pointer to the list
// @param Pointer to the value
// @param Length of the value
//
// @return number of copies of passed value in the list
///
dcl-pr list_frequency uns(10) extproc('list_frequency');
  list pointer const;
  value pointer const;
  length uns(10) const;
end-pr;

///
// Add character list entry
//
// Adds a character entry to the list. If the position is outside the list
// the procedure returns <em>*off</em>. The current entry of the list at
// that position will be pushed one position down the list.
//
// <br><br>
//
// If no position is passed to the procedure then the entry will be
// appended to the end of the list (like <em>addLast</em>).
//
// @author Mihael Schmidt
// @date   21.09.2008
//
// @param Pointer to the list
// @param Character value
// @param List position for the new value (optional)
//
// @return *on = entry added the list <br>
//         *off = error
///
dcl-pr list_addString ind extproc('list_addString') opdesc;
  list pointer const;
  value char(65535) const options(*varsize);
  index uns(10) const options(*nopass);
end-pr;

///
// Add integer list entry
//
// Adds an integer entry to the list. If the position is outside the list
// the procedure returns <em>*off</em>. The current entry of the list at
// that position will be pushed one position down the list.
//
// <br><br>
//
// If no position is passed to the procedure then the entry will be
// appended to the end of the list (like <em>addLast</em>).
//
// @author Mihael Schmidt
// @date   21.09.2008
//
// @param Pointer to the list
// @param Integer value
// @param List position for the new value (optional)
//
// @return *on = entry added the list <br>
//         *off = error
///
dcl-pr list_addInteger ind extproc('list_addInteger');
  list pointer const;
  value int(10) const;
  index uns(10) const options(*nopass);
end-pr;

///
// Add long list entry
//
// Adds a long entry to the list. If the position is outside the list
// the procedure returns <em>*off</em>. The current entry of the list at
// that position will be pushed one position down the list.
//
// <br><br>
//
// If no position is passed to the procedure then the entry will be
// appended to the end of the list (like <em>addLast</em>).
//
// @author Mihael Schmidt
// @date   21.09.2008
//
// @param Pointer to the list
// @param Long value
// @param List position for the new value (optional)
//
// @return *on = entry added the list <br>
//         *off = error
///
dcl-pr list_addLong ind extproc('list_addLong');
  list pointer const;
  value int(20) const;
  index uns(10) const options(*nopass);
end-pr;

///
// Add short list entry
//
// Adds a short entry to the list. If the position is outside the list
// the procedure returns <em>*off</em>. The current entry of the list at
// that position will be pushed one position down the list.
//
// <br><br>
//
// If no position is passed to the procedure then the entry will be
// appended to the end of the list (like <em>addLast</em>).
//
// @author Mihael Schmidt
// @date   21.09.2008
//
// @param Pointer to the list
// @param Short value
// @param List position for the new value (optional)
//
// @return *on = entry added the list <br>
//         *off = error
///
dcl-pr list_addShort ind extproc('list_addShort');
  list pointer const;
  value int(5) const;
  index uns(10) const options(*nopass);
end-pr;

///
// Add float list entry
//
// Adds a float entry to the list. If the position is outside the list
// the procedure returns <em>*off</em>. The current entry of the list at
// that position will be pushed one position down the list.
//
// <br><br>
//
// If no position is passed to the procedure then the entry will be
// appended to the end of the list (like <em>addLast</em>).
//
// @author Mihael Schmidt
// @date   21.09.2008
//
// @param Pointer to the list
// @param Float value
// @param List position for the new value (optional)
//
// @return *on = entry added the list <br>
//         *off = error
///
dcl-pr list_addFloat ind extproc('list_addFloat');
  list pointer const;
  value float(4) const;
  index uns(10) const options(*nopass);
end-pr;

///
// Add double list entry
//
// Adds a double entry to the list. If the position is outside the list
// the procedure returns <em>*off</em>. The current entry of the list at
// that position will be pushed one position down the list.
//
// <br><br>
//
// If no position is passed to the procedure then the entry will be
// appended to the end of the list (like <em>addLast</em>).
//
// @author Mihael Schmidt
// @date   21.09.2008
//
// @param Pointer to the list
// @param Double value
// @param List position for the new value (optional)
//
// @return *on = entry added the list <br>
//         *off = error
///
dcl-pr list_addDouble ind extproc('list_addDouble');
  list pointer const;
  value float(8) const;
  index uns(10) const options(*nopass);
end-pr;

///
// Add boolean list entry
//
// Adds a boolean entry to the list. If the position is outside the list
// the procedure returns <em>*off</em>. The current entry of the list at
// that position will be pushed one position down the list.
//
// <br><br>
//
// If no position is passed to the procedure then the entry will be
// appended to the end of the list (like <em>addLast</em>).
//
// @author Mihael Schmidt
// @date   21.09.2008
//
// @param Pointer to the list
// @param Boolean value
// @param List position for the new value (optional)
//
// @return *on = entry added the list <br>
//         *off = error
///
dcl-pr list_addBoolean ind extproc('list_addBoolean');
  list pointer const;
  value ind const;
  index uns(10) const options(*nopass);
end-pr;

///
// Add packed decimal list entry
//
// Adds a packed decimal entry to the list. If the position is outside the list
// the procedure returns <em>*off</em>. The current entry of the list at
// that position will be pushed one position down the list.
//
// <br><br>
//
// If no position is passed to the procedure then the entry will be
// appended to the end of the list (like <em>addLast</em>).
//
// @author Mihael Schmidt
// @date   21.09.2008
//
// @param Pointer to the list
// @param Packed decimal value
// @param List position for the new value (optional)
//
// @return *on = entry added the list <br>
//         *off = error
///
dcl-pr list_addDecimal ind extproc('list_addDecimal');
  list pointer const;
  value packed(15 : 5) const;
  index uns(10) const options(*nopass);
end-pr;

///
// Add date list entry
//
// Adds a date entry to the list. If the position is outside the list
// the procedure returns <em>*off</em>. The current entry of the list at
// that position will be pushed one position down the list.
//
// <br><br>
//
// If no position is passed to the procedure then the entry will be
// appended to the end of the list (like <em>addLast</em>).
//
// @author Mihael Schmidt
// @date   21.09.2008
//
// @param Pointer to the list
// @param Date value
// @param List position for the new value (optional)
//
// @return *on = entry added the list <br>
//         *off = error
///
dcl-pr list_addDate ind extproc('list_addDate');
  list pointer const;
  value date const;
  index uns(10) const options(*nopass);
end-pr;

///
// Get character entry
//
// Returns a character list entry specified by the passed index.
//
// @author Mihael Schmidt
// @date   21.09.2008
//
// @param Pointer to the list
// @param List position
//
// @return Character string of the specified position
///
dcl-pr list_getString char(65535) extproc('list_getString');
  list pointer const;
  index uns(10) const;
end-pr;

///
// Get integer entry
//
// Returns an integer list entry specified by the passed index.
//
// @author Mihael Schmidt
// @date   21.09.2008
//
// @param Pointer to the list
// @param List position
//
// @return Integer value of the specified position
///
dcl-pr list_getInteger int(10) extproc('list_getInteger');
  list pointer const;
  index uns(10) const;
end-pr;

///
// Get short entry
//
// Returns a short list entry specified by the passed index.
//
// @author Mihael Schmidt
// @date   21.09.2008
//
// @param Pointer to the list
// @param List position
//
// @return Short value of the specified position
///
dcl-pr list_getShort int(5) extproc('list_getShort');
  list pointer const;
  index uns(10) const;
end-pr;

///
// Get long entry
//
// Returns a long list entry specified by the passed index.
//
// @author Mihael Schmidt
// @date   21.09.2008
//
// @parem Pointer to the list
// @param List position
//
// @return Long value of the specified position
///
dcl-pr list_getLong int(20) extproc('list_getLong');
  list pointer const;
  index uns(10) const;
end-pr;

///
// Get float entry
//
// Returns a float list entry specified by the passed index.
//
// @author Mihael Schmidt
// @date   21.09.2008
//
// @param Pointer to the list
// @param List position
//
// @return Float value of the specified position
///
dcl-pr list_getFloat float(4) extproc('list_getFloat');
  list pointer const;
  index uns(10) const;
end-pr;

///
// Get double entry
//
// Returns a double list entry specified by the passed index.
//
// @author Mihael Schmidt
// @date   21.09.2008
//
// @param Pointer to the list
// @param List position
//
// @return Double value of the specified position
///
dcl-pr list_getDouble float(8) extproc('list_getDouble');
  list pointer const;
  index uns(10) const;
end-pr;

///
// Get boolean entry
//
// Returns a boolean list entry specified by the passed index.
//
// @author Mihael Schmidt
// @date   21.09.2008
//
// @param Pointer to the list
// @param List position
//
// @return Boolean value of the specified position
///
dcl-pr list_getBoolean ind extproc('list_getBoolean');
  list pointer const;
  index uns(10) const;
end-pr;

///
// Get packed decimal entry
//
// Returns a packed decimal list entry specified by the passed index.
//
// @author Mihael Schmidt
// @date   21.09.2008
//
// @param Pointer to the list
// @param List position
//
// @return Packed decimal value of the specified position
///
dcl-pr list_getDecimal packed(15 : 5) extproc('list_getDecimal');
  list pointer const;
  index uns(10) const;
end-pr;

///
// Get date entry
//
// Returns a date list entry specified by the passed index.
//
// @author Mihael Schmidt
// @date   21.09.2008
//
// @param Pointer to the list
// @param List position
//
// @return Date value of the specified position
///
dcl-pr list_getDate date extproc('list_getDate');
  list pointer const;
  index uns(10) const;
end-pr;

///
// Sort list
//
// Sorts the list with the passed procedure.
//
// <br>
//
// The compare procedure compares two values of the list and returns
// <ul>
//   <li>0 if the entries are equal</li>
//   <li>&lt; 0 if the first entry should be placed above the second entry</li>
//   <li>&gt; 0 if the second entry should be placed above the first entry</li>
// </ul>
// 
// <div>
// dcl-pr compare int(10); <br>
// &nbsp;&nbsp;  value1 pointer const; <br>
// &nbsp;&nbsp;  length1 int(10) const; <br>
// &nbsp;&nbsp;  value2 pointer const; <br>
// &nbsp;&nbsp;  length2 int(10) const; <br>
// end-pr;
// </div>
//
// A value passed to the compare function can also be <code>*null</code>.
//
// @param Pointer to the list
// @param Procedure pointer for comparing values to the sort the list
///
dcl-pr list_sort extproc('list_sort');
  list pointer const;
  compareProcedure pointer(*proc) const options(*nopass);
end-pr;

///
// Remove range of elements
//
// Removes a number of elements from the list.
//
// @param Pointer to the list
// @param Starting index
// @param Number of elements to remove
//
// @throws CPF9898 Position out of bounds
///
dcl-pr list_removeRange extproc('list_removeRange');
  list pointer const;
  index uns(10) const;
  numberElements uns(10) const;
end-pr;

///
// Merge lists
//
// Merges the elements of second list with the first list. Elements which
// are already in the first list are not added by default (see third parameter).
//
// @author Mihael Schmidt
// @date   15.12.2009
//
// @param Destination list
// @param Source list
// @param Skip duplicates (default: *off)
///
dcl-pr list_merge extproc('list_merge');
  destList pointer const;
  sourceList pointer const;
  skipDuplicates ind const options(*nopass);
end-pr;

/endif

/copy 'llist_so_h.rpgle'
