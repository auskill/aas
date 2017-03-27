
% AAS. 2016.S1.  Useful code for task01.

% Example program, for processing laser scans, stored in a Matlab data file.
% It shows the scans in its original way :POLAR.
% You are requested to modify this program to show the data in Cartesian.


% The data correspond to a laser scanner installed at the front of our UGV
% (robot). It is pointing ahead the robot, scanning horizontally, i.e. in 2D
% When you plot the data in Cartesian you will see how the room did look
% from the perspective of the moving platform.


% IMPORTANT ==> Read the program and comments before trying to modify it and before asking. 


function ExampleUseLaserData(file)

% In case the caller does not specify the input argument, we propose a
% default one.
if ~exist('file','var'), file ='Laser__2.mat'; end;

load(file); 
% now, after loading, the data is in a variable named "dataL";



    % --------------------------------------
    % Create graphical object for refreshing data during program execution.
    figure(1) ; clf(); 
    
    MyGUIHandles.handle1 = plot(0,0,'b.');      % to be used for showing the laser points
   
    
    axis([0,180,0,20]);                         % focuses the plot on this region (of interest, close to the robot)
    xlabel('angle (degrees)');
    ylabel('range (meters)');
    
    MyGUIHandles.handle2 = title('');           % create an empty title..
    zoom on ;  grid on;
    
    % If you do not understand these functions ( figure() ,plot(),
    % axis(),.....) ===> Read Matlab's Help.
    
    %---------------------------------
    
    disp('Showing laser scans, IN POLAR representation');
    disp('Yo need to modify this program for showing the data in Cartesian.');
    disp('(then the images will make sense, for our brains)');
    
    fprintf('\nThere are [ %d ] laser scans in this dataset (file [%s])\n',dataL.N,file);
    
    
    % Now, loop through the avaialable scans..
    
N = dataL.N; skip=3;
for i=1:skip:N,             % in this example I skip some of the laser scans.
    
    % Native time expressed via uint32 numbers, where 1 unint means 1/10000
    % second (i.e. 0.1 millisecond)
    t =  double(dataL.times(i)-dataL.times(1))/10000;
    % t: time expressed in seconds, relative to the time of the fist scan.
    
    scan_i = dataL.Scans(:,i);
    MyProcessingOfScan(scan_i,t,MyGUIHandles,i);   % some function to use the data...

    pause(0.01) ;                   % wait for ~10ms
end;

fprintf('\nDONE!\n');

% Read Matlab Help for explanation of FOR loops, and function double( ) and pause()


return;
end
%-----------------------------------------
function MyProcessingOfScan(scan,t,mh,i)
    % I made this function to receive the following parameters/variables:
    % 'scan' : scan measurements to plot
    % 't':  associated time    
    % 'i' : scan number
    % 'mh'  : struct contaning handles of graphical objects.
    
    angles = [0:360]'*0.5 ;         % Associated angle for each range of scan
    % same as in "dataL.angles".
    
    % scan data is provided as a array of class uint16
     
    MaskLow13Bits = uint16(2^13-1); % mask for extracting the range bits.
    % the lower 13 bits are for indicating the range data (as provided by this sensor)
    
    rangesA = bitand(scan,MaskLow13Bits) ; 
    % rangesA now contains the range data of the scan, expressed in CM, having uint16 format.
    
    % now I convert ranges to meters, and also to floating point format
    ranges    = 0.01*double(rangesA); 

    
    % and then refresh the data in the plots...
    set(mh.handle1,'xdata',angles,'ydata',ranges);

    % and some text...
    s= sprintf('Laser scan # [%d] at time [%.3f] secs',i,t);
    set(mh.handle2,'string',s);
    
    
    % Use Matlab help for learning the functionality of  uint16(), bitand()
    % , set( ), sprintf()...
    
    return;
end
%-----------------------------------------
    
% The data in the file is stored according to certain structure. 
% The fields we need are: "Scans" and "times".
% The number of scans is indicated by the field "N".
% The scans themselves are stored in the field "Scans", that is a matrix of 361 x N 
% (because each scan contains 361 measurements, that cover 180 degrees at steps of 1/2 degree).
% the ranges are originally expressed in Centimeters, as 13 bits unsigned int integers.
% as explained in the code.

%-----------------------------------------% 

%  by Jose Guivant.  MTRN4010.S1.2016 

%-----------------------------------------
