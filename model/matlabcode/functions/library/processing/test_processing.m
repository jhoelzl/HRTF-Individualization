function test_processing()

%javaaddpath('/Applications/Processing.app/Contents/Resources/Java/core/library/core.jar')
%javarmpath('/Applications/Processing.app/Contents/Resources/Java/core/library/core.jar')

javaaddpath('/Users/josefhoelzl/Studium/Projekt/objective-hrtf/matlabcode/functions/library')


import java.awt.*;
import java.awt.event.*;
import javax.swing.*;
import processing.core.*;
import plotMatlab.*;
% create window in which applet will execute
applicationWindow = JFrame( 'An applet running as an application' );
width = 800;
height = 600;
% create one applet instance
appletObject = plotMatlab2;

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
setData(appletObject, 400+randn(10000,1)*80, 300+randn(10000,1)*60, rand(10000,1)*220, ones(10000,1)*80);