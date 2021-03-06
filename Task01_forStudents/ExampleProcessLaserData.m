
% Example program, for off-line processing of saved laser scans. 
% Example source code, useful for Task01. 
% AAS - 2016.S1.
% Jose Guivant.

% Note: Plotting of results is implemented via brute force approach.
% See other provided examples, for better implementation (dynamic updates using "set()").
% I expect you to avoid "brute force", in your projects. 


function MyProgram(file)

clc(); close all;
% In case the caller does not specify the input argument, we propose a
% default one.
if ~exist('file','var'), file ='Laser__2.mat'; end;

% load data file.
load(file); 
% The variable that contains the data structure is named "dataL"
% (because it was created under that name and saved)  

N = dataL.N;                         % number of scans in this squence.

disp('Brute force plotting');
disp('And there is no GUI. So, use Control-C to break loop.');

for i=1:3:N,                        % in this example I skip some of them..
    scan_i = dataL.Scans(:,i);
    ProcessScan(scan_i);
    
    s=sprintf('(Brute force plotting...)\nShowing scan #[%d]/[%d]\r',i,N);
    title(s);
    
    pause(0.01) ;                   % wait for ~10ms
end;
disp('Done. Bye.');

return;
end


%.............................
function ProcessScan(scan)

% Extract range and intensity information, from raw measurements.
% Each "pixel" is represented by range and intensity of reflection.
% It is a 16 bits number whose bits 0-12 define the distance (i.e. the range)
% in cm (a number 0<=r<2^13), and bits 13-15 indicate the intensity 
%( a number 0<=i<8 ).

% We extract range and intensity, here.
%useful masks, for dealing with bits.
mask1FFF = uint16(2^13-1);
maskE000 = bitshift(uint16(7),13)  ;

intensities = bitand(scan,maskE000);

ranges    = single(bitand(scan,mask1FFF))*0.01; 
% Ranges expressed in meters, and unsing floating point format.

% 2D points, expressed in Cartesian. From the sensor's perpective.
angles = [0:360]'*0.5* pi/180 ;         % associated angle for each range of scan
X = cos(angles).*ranges;
Y = sin(angles).*ranges;    

% Plot. "Brute force" plot (see note 1).
figure(1) ; clf(); hold on;
plot(X,Y,'b.');                     % all points
ii = find(intensities~=0);          % find those "pixels" that had intense reflection (>0)
plot(X(ii),Y(ii),'+r');             % plot highly reflective ones
axis([-10,10,0,20]);                % focuses plot on this region ( of interest in L220)

% To be done (by you)
OOIs = ExtractOOIs(ranges,intensities) ;
PlotOOIs(OOIs);

return;
end
function r = ExtractOOIs(ranges,intensities)
    r.N = 0;
    r.Centers = [];
    r.Sizes   = [];
    % your part....
    
return;
end
    
function PlotOOIs(OOIs)
    if OOIs.N<1, return ; end;
    % your part....
return;
end
    
% --------------------------------
% note 1: for a more efficient way of dynamically plotting, see example
% "ExampleUseLaserData.m", where we used graphical objects handles.
% --------------------------------
% Questions?  Ask the lecturer, j.guivant@unsw.edu.au
% --------------------------------

