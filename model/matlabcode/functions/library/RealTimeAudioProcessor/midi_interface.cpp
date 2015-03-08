/*
 * midi_interface.cpp
 *
 * This MEX function opens a MIDI input device, buffers incoming MIDI, and 
 * reports it out when requested.
 *
 * midi_interface('open', 'device name') - Opens the specified device
 * midi_interface('open') - Prompts the user for a device from a list
 * [msgs, times] = midi_interface() - Returns the buffered MIDI messages
 * midi_interface('close') - Closes the MIDI device
 *
 * Tucker McClure @ The MathWorks
 * Copyright 2012 The MathWorks, Inc.
 */

#include "mex.h"
#include <windows.h>
#include <string.h>

// Store the MIDI input device handle.
static HMIDIIN input_device_handle = NULL;

// Buffer of MIDI messages
static unsigned int number_messages_stored = 0;
static unsigned int read_index = 0;
static unsigned int write_index = 0;
const  unsigned int BUFFER_SIZE = 65536; // Must be a power of 2
static unsigned int message_buffer[BUFFER_SIZE][3];
static double       message_time_buffer[BUFFER_SIZE];

/*
 * Callback function for Windows; buffers incoming MIDI data.
 */
void CALLBACK process_midi_input(
        HMIDIIN handle, 
        UINT wMsg, 
        DWORD dwInstance, 
        DWORD dwParam1, 
        DWORD dwParam2)
{
  switch (wMsg)
  {
    case MIM_MOREDATA:
    case MIM_DATA:
        
      WORD low_word   = LOWORD(dwParam1);
      WORD high_word  = HIWORD(dwParam1);
      unsigned int first_byte  = LOBYTE(low_word);
      unsigned int second_byte = HIBYTE(low_word);
      unsigned int third_byte  = LOBYTE(high_word);
      
      // If there's room for a new message, store it along with its 
      // timestamp.
      if (number_messages_stored < BUFFER_SIZE)
      {
        message_buffer[write_index][0]   = first_byte;
        message_buffer[write_index][1]   = second_byte;
        message_buffer[write_index][2]   = third_byte;
        message_time_buffer[write_index] = static_cast<double>(dwParam2);

        // Increase the write index and wrap if it's gone beyond the 
        // buffer size.
        ++write_index;
        write_index &= BUFFER_SIZE-1;
        
        // Augment the number of message stored.
        ++number_messages_stored;
      }
      
    break;
  }
}

/*
 * Close the MIDI input device.
 */
static void Shutdown(void)
{
  // If the device was opened...
  if (input_device_handle)
  {
    // Stop the input.
    midiInStop(input_device_handle);

    // Close the device.
    if (midiInClose(input_device_handle) == MMSYSERR_NOERROR)
    {
      mexPrintf("Successfully closed the device.\n");
    }
    else
    {
      mexPrintf("There was an error closing the device.\n");
    }
    
    // Reset the handle.
    input_device_handle = NULL;
  }
}

/*
 * This function provides the main programmatic details, including querying
 * devices, opening a device, waiting for a while, and closing the device.
 */
bool OpenMidiInputDevice(unsigned int input_device_id)
{
  bool success = false;

  mexPrintf("Opening device %d.\n", input_device_id);
  
  // Open the device for MIDI input.
  if (midiInOpen(&input_device_handle, input_device_id, (DWORD)process_midi_input, 0, CALLBACK_FUNCTION) == MMSYSERR_NOERROR)
  {
    mexPrintf("Successfully opened MIDI input device %d.\n", input_device_id);

    // Start input!
    midiInStart(input_device_handle);
    
    // Note that we were successful.
    success = true;
  }
  else
  {
    mexPrintf("There was an error opening the device.\n");
  }
  
  return success;
}

/*
 * Display the device names and ask the user to select one.
 */
bool PromptForDevice(unsigned int &device)
{
  // Query for the number of available input devices.
  unsigned int num_input_devices = midiInGetNumDevs();
  if (num_input_devices == 0)
  {
    return false;
  }

  // Container for MIDI input device capabilities.
  MIDIINCAPS input_device_capabilities;

  mexPrintf("\nAvailable devices:\n\n");
  
  // Print the name of each device.
  for (unsigned int k = 0; k < num_input_devices; ++k)
  {
    // Make sure there wasn't an error.
    if (midiInGetDevCaps(k, &input_device_capabilities, sizeof(MIDIINCAPS)) == MMSYSERR_NOERROR)
    {
      mexPrintf("%d: %s\n", k, input_device_capabilities.szPname);
    }
  }
  
  // Ask the user for input.
  mxArray * question;
  mxArray * answer;
  question = mxCreateString("\nSelect device number: ");
  mexCallMATLAB(1, &answer, 1, &question, "input");
  bool success = false;
  
  // If it's empty, bail.
  if (!mxIsEmpty(answer))
  {
    // Otherwise, grab the number.
    unsigned int device_test = static_cast <unsigned int> (mxGetScalar(answer));
    
    // Make sure number makes sense.
    if (device_test >= 0 && device_test < num_input_devices) 
    {
      // Output and return success.
      device = device_test;
      success = true;
    }
  }
  else
  {
    mexPrintf("User cancelled device selection.\n");
  }
  
  // Clean up.
  mxDestroyArray(question);
  mxDestroyArray(answer);
  
  return success;
}

/*
 * Find the user-supplied device name in the device list and return the right number.
 */
bool FindDeviceByName(char * name, unsigned int &device)
{
  // Query for the number of available input devices.
  unsigned int num_input_devices = midiInGetNumDevs();

  // Container for MIDI input device capabilities.
  MIDIINCAPS input_device_capabilities;

  // Print the name of each device.
  for (unsigned int k = 0; k < num_input_devices; ++k)
  {
    // Make sure there wasn't an error.
    if (midiInGetDevCaps(k, &input_device_capabilities, sizeof(MIDIINCAPS)) == MMSYSERR_NOERROR)
    {
      mexPrintf("%d: %s\n", k, input_device_capabilities.szPname);
      
      // If this one matches the requested name, use it.
      if (!strcmp(input_device_capabilities.szPname, name))
      {
        device = k;
        return true;
      }
    }
  }

  return false;
}

/*
 * Tell the user he messed up.
 */
void PrintUsageError()
{
  mexErrMsgIdAndTxt("MATLAB:midi_interface:InvalidArguments", 
                    "Invalid input/output arguments. See 'help midi_interface'.");
}

/*
 * This function provides the interface to MATLAB to access the payload,
 * allowing multiple arguments of different types, MATLAB structures, etc.
 * It's primary job is to get data as we care about it routed to the
 * payload function.
 */
void mexFunction(
              mwSize   number_of_outs, 
              mxArray *outs[],
              mwSize   number_of_ins,
        const mxArray *ins[])
{
  // If there are any inputs...
  if (number_of_ins > 0)
  {
    
    // Make sure the first is a command.
    if (!mxIsChar(ins[0]))
    {
      PrintUsageError();
    }
    
    // Get the command as a normal C string.
    char * command = mxArrayToString(ins[0]);
    
    /////////////////
    // Open Device //
    /////////////////
    
    // If opening...
    if (!strcmp(command, "open"))
    {
      // Register an exit function.
      mexAtExit(Shutdown);
      
      // Validate number of outputs.
      if (   number_of_outs > 2
          || number_of_ins > 2
          || (   number_of_ins == 2
              && !(mxIsNumeric(ins[1]) && mxGetM(ins[1]) == 1 && mxGetN(ins[1]) == 1)
              && !mxIsChar(ins[1])))
      {
        PrintUsageError();
      }
      
      // See if we're already open.
      if (input_device_handle != NULL)
      {
        mexErrMsgIdAndTxt("MATLAB:midi_interface:DeviceAlreadyOpen", 
                          "MIDI device is already open. Close current MIDI device first.");
      }
      
      // Store the selected device number (not handle) locally.
      unsigned int input_device_id = 0;
      bool valid_device_found = false;
      
      // If a second argument is provided, it must be the device to open. 
      // See if it's a number or string.
      if (number_of_ins == 2)
      {
        
        // User has provided the value directly. Attempt to use it.
        if (mxIsNumeric(ins[1]))
        {
          
          // Get the input as a double and round to the nearest integer.
          input_device_id = static_cast <unsigned int> (*mxGetPr(ins[1]) + 0.5);
          
          // Validate the entry.
          valid_device_found = input_device_id < midiInGetNumDevs();
          
        }
        
        // User has provided a string for the device. Attempt to match it.
        else if (mxIsChar(ins[1]))
        {
          // Get the string and go look for it!
          char * input_device_string = mxArrayToString(ins[1]);
          valid_device_found = FindDeviceByName(input_device_string, input_device_id);
          mxFree(input_device_string);
        }

      }
      
      // Else, prompt the user for a device.
      else
      {
        valid_device_found = PromptForDevice(input_device_id);
      }
      
      // Finally, we ready to open what the user provided or selected via 
      // input number or string.
      bool success = false;
      if (valid_device_found)
      {
        // Open it!
        success = OpenMidiInputDevice(input_device_id);
      }
      else
      {
        mexPrintf("Device selection was invalid.\n");
      }
      
      // Output the success of the operation.
      if (number_of_outs >= 1)
      {
        outs[0] = mxCreateLogicalScalar(success);
      }
      if (number_of_outs >= 2)
      {
        outs[1] = mxCreateDoubleScalar(input_device_id);
      }
      
    }
    
    //////////////////
    // Close Device //
    //////////////////
    
    // Otherwise if closing...
    else if (!strcmp(command, "close"))
    {
      
      // Validate number of outputs.
      if (number_of_outs > 0)
      {
        PrintUsageError();
      }
      
      // Just close the device. Nothing else to do.
      Shutdown();
      
    }
    
    // Otherwise, we don't know what to do.
    else
    {
      PrintUsageError();
    }
    
    // Clean up.
    mxFree(command);
    
  }
  
  // Otherwise, if there are no inputs, we should dump out the MIDI buffer.
  else
  {
    
    // Validate number of outputs.
    if (number_of_outs > 2)
    {
      PrintUsageError();
    }
    
    ///////////////////
    // Output Buffer //
    ///////////////////
    
    // If the user is looking for outputs, dump the buffer out to him.
    if (number_of_outs >= 1)
    {
      
      // Create the output.
      outs[0] = mxCreateDoubleMatrix(3, number_messages_stored, mxREAL);
      
      // This really shouldn't be a double. uint8 is all that's necessary. 
      // uint16 may be faster.
      double * messages_out = mxGetPr(outs[0]);
      
      // Copy out each byte of each message, starting with read_index and 
      // going until we've exhausted the outputs. If the buffer is 
      // increased while we're here, we'll just have to get that message
      // next time (we've already allocated the output matrix).
      for (unsigned int k = 0; k < number_messages_stored; ++k)
      {
        *(messages_out + 3*k + 0) = (double)(message_buffer[read_index][0]);
        *(messages_out + 3*k + 1) = (double)(message_buffer[read_index][1]);
        *(messages_out + 3*k + 2) = (double)(message_buffer[read_index][2]);
        
        // Increase the read index and wrap it if it's greater than the 
        // buffer size.
        ++read_index;
        read_index &= BUFFER_SIZE-1;
      }
      
      // If there's a second argument, hand out the times as well.
      if (number_of_outs == 2)
      {
        outs[1] = mxCreateDoubleMatrix(1, number_messages_stored, mxREAL);
        double * message_times_out = mxGetPr(outs[1]);
        for (unsigned int k = 0; k < number_messages_stored; ++k)
        {
          *(message_times_out + k) = message_time_buffer[k];
        }
      }
      
    }

    // Reset the counter.
    number_messages_stored = 0;
    
  }
  
}
