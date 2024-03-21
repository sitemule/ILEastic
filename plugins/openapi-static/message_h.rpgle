**FREE

/if not defined (MESSAGE)
/define MESSAGE

///
// Messages
//
// Wrapper for OS message API for making it easier to send and receive
// program messages.
//
// This module has been split up from the RPGUnit framework so that other
// applications can also use it.
//
// Refactored by Mihael Schmidt.
//
// @link https://bitbucket.org/m1hael/message Project Website
// @link http://rpgunit.sourceforge.net RPGUnit
//
// @project Message
///

//
// Constants
//

// Call stack levels.
dcl-c MESSAGE_ONE_CALL_STACK_LEVEL_ABOVE 1;
dcl-c MESSAGE_TWO_CALL_STACK_LEVEL_ABOVE 2;

// To resend the last new escape message
dcl-c MESSAGE_LAST_NEW_ESCAPE_MESSAGE const(*blank);

// Call stack entry (current call stack entry)
dcl-c MESSAGE_CURRENT_CALL_STACK_ENTRY '*';
// Control boundary
dcl-c MESSAGE_CONTROL_BOUNDARY '*CTLBDY';


//----------------------------------------------------------------------
// Message Data Structures (Templates)
//----------------------------------------------------------------------
dcl-ds messageInfo_t qualified template;
  messageId char(7);
  message char(256);
  // Sending Program Name
  programName char(12);
  // Sending Procedure Name
  procedureName char(256);
  // Sending Statement Number
  statement char(10);
end-ds;

// Program Message
dcl-ds message_t qualified template;
  id char(7);
  text varchar(254);
  replacementData varchar(254);
  sender likeds(messageSender_t);
end-ds;

// Program Message Sender
dcl-ds messageSender_t qualified template;
  programName char(12);
  procedureName char(256);
  statement char(6);
end-ds;


//-------------------------------------------------------------------------------------------------
// Message Prototypes
//-------------------------------------------------------------------------------------------------

///
// Receive exception message
//
// @return message info
///
dcl-pr message_receiveMessageInfo likeds(messageInfo_t) extproc(*dclcase) end-pr;

///
// Receive a program message replacement data
//
// @param message type (*ANY, *COMP, *EXCP, ...)
// @return message data
///
dcl-pr message_receiveMessageData char(256) extproc(*dclcase);
  type char(10) const;
end-pr;

///
// Receive a program message text
//
// @param message type (*ANY, *COMP, *EXCP, ...)
// @return message text
///
dcl-pr message_receiveMessageText char(256) extproc(*dclcase);
  type char(10) const;
end-pr;

///
// Receive a program message
//
// If the message was sent to a procedure above in the call stack,
// indicate how many level above it is with the callStackLevelAbove
// parameter.
//
// @param message type (*ANY, *COMP, *EXCP, ...)
// @param call stack level above the current stack entry
// @param message key (*TOP, ...)
// @return message
///
dcl-pr message_receiveMessage likeds(message_t) extproc(*dclcase);
  type char(10) const;
  callStackLevelAbove int(10) const options(*omit : *nopass);
  messageKey char(4) const options(*nopass);
end-pr;

///
// Resend an escape message
//
// Resend an escape message that was monitored in a monitor block.
// See API <a href="https://www.ibm.com/support/knowledgecenter/en/ssw_ibm_i_73/apis/QMHRSNEM.htm">QMHRSNEM - Resend Escape Message</a>.
//
// @param message key
// @param error code
///
dcl-pr message_resendEscapeMessage extpgm('QMHRSNEM');
  messageKey char(4) const;
  errorCode char(32565) const options(*varsize) noopt;
end-pr;

///
// Send completion message
//
// @param message
// @param call stack level above the current stack entry
///
dcl-pr message_sendCompletionMessage extproc(*dclcase);
  message char(256) const;
  callStackLevelAbove int(10) const options(*nopass);
end-pr;

///
// Send escape message
//
// @param message
// @param call stack level above the current stack entry
///
dcl-pr message_sendEscapeMessage extproc(*dclcase);
  message char(256) const;
  callStackLevel int(10) const options(*nopass);
end-pr;

///
// Send escape message to caller
//
// Send an escape message to the procedure's caller.
//
// @param message
///
dcl-pr message_sendEscapeMessageToCaller extproc(*dclcase);
  message char(256) const;
end-pr;

///
// Send escape message above control boundary
//
// Send an escape message to the call stack entry just above the control boundary.
// Useful to terminate a program.
//
// @param message
///
dcl-pr message_sendEscapeMessageAboveControlBody extproc(*dclcase);
  message char(256) const;
end-pr;

///
// Send info message
//
// Send an information message.
//
// @param message
// @param call stack level above the current stack entry
///
dcl-pr message_sendInfoMessage extproc(*dclcase);
  message char(256) const;
  callStackLevelAbove int(10) const options(*nopass);
end-pr;

///
// Send status message
//
// @param message
///
dcl-pr message_sendStatusMessage extproc(*dclcase);
  message char(256) const;
end-pr;

///
// Send info message
//
// Send an information message.
//
// @param message
///
dcl-pr message_info extproc(*dclcase);
  message char(256) const;
end-pr;

///
// Send status message
//
// @param message
///
dcl-pr message_status extproc(*dclcase);
  message char(256) const;
end-pr;

///
// Send completion message
//
// @param message
///
dcl-pr message_completion extproc(*dclcase);
  message char(256) const;
end-pr;

///
// Send escape message above control boundary
//
// Send an escape message to the call stack entry just above the control boundary.
// Useful to terminate a program.
//
// @param message
// @param call stack level above the current stack entry
///
dcl-pr message_escape extproc(*dclcase);
  message char(256) const;
  callStackLevel int(10) const options(*nopass);
end-pr;

///
// Send info message from message file
//
// Sends specified message from the message file as an info message.
//
// @param library (default *LIBL)
// @param message file name
// @param message Id
// @param message (optional)
// @param call stack level above the current stack entry
///
dcl-pr message_file_info extproc(*dclcase);
  library char(10) const options(*omit);
  msgfile char(10) const;
  messageId char(7) const;
  message char(1024) const options(*omit : *nopass);
  callStackLevelAbove int(10) const options(*nopass);
end-pr;

///
// Send escape message from message file
//
// Sends specified message from the message file as an escape message.
//
// @param library (default *LIBL)
// @param message file name
// @param message Id
// @param message (optional)
// @param call stack level above the current stack entry
///
dcl-pr message_file_escape extproc(*dclcase);
  library char(10) const options(*omit);
  msgfile char(10) const;
  messageId char(7) const;
  message char(1024) const options(*omit : *nopass);
  callStackLevelAbove int(10) const options(*nopass);
end-pr;

///
// Send diagnostic message
//
// @param message
///
dcl-pr message_diagnostic extproc(*dclcase);
  message char(256) const;
end-pr;

/endif
