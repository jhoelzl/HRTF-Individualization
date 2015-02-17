% midi_interface - Interface for acquiring MIDI messages from one of the
% system's MIDI input devices. Only works on Windows XP and above.
% 
% Usage:
% 
% [success, device] = midi_interface('open') prompts the user for MIDI
% devices to open, opens a device, and returns the success and device id.
% 
% success = midi_interface('open', device) opens the specified device (by
% number or string name) and returns the success.
% 
% midi_interface('close') closes the current MIDI device.
%
% [messages, times] = midi_interface() returns the buffer of messages and
% message times and clears the buffer. One message is a 1x3 matrix of ints.
% The first value is the first "byte", etc. The meaning of the values can
% be found here: http://www.midi.org/techspecs/midimessages.php.
%
% Notes:
%
% - Only 1 device can be open at a time.
% - A new device cannot be opened until the first is properly closed.
% - The maximum buffer size is 65536 messages. Beyond this number, messages
%   will be dropped, so the buffer should be checked quickly.
%
% Tucker McClure @ The MathWorks
% Copyright 2012 The MathWorks, Inc.
