function test_processing2()

import java.awt.*;
import java.awt.event.*;
import javax.swing.*;
import processing.core.*;

% create window in which applet will execute
applicationWindow = JFrame( 'An applet running as an application' );
width = 300;
height = 200;

% create one applet instance
appletObject = matlab_test(width,height-22);

% call applet's init and start methods
appletObject.init;
appletObject.start;

% attach applet to center of window
applicationWindow.getContentPane.add( appletObject );

% set the window's size
applicationWindow.setSize( width, height );

% showing the window causes all GUI components
% attached to the window to be painted
applicationWindow.show;