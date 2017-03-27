% Example: reading sensors' data. 
% Provided by Jose Guivant/Alicia Robledo - 2016.
% This short program reads, periodically, the laser scanner LMS200, in real-time. It
% plots the measured scan data, in Cartesian coordinates.
% It also shows the highly reflective pixels.

% Read this program, you need to understand how to use the API in order to
% implement your modules for the projects in MTRN4010
% It also helps you to understand about some basic processing and plotting in  Matlab.


% NEEDED resources:  
%       * Possum.exe running;
%       * Simulator.exe running or connection to real UGV system.
%       * Possum API for Matlab (provided "mex" and "p" files):
%       ( API_PossumUGV2.p ; API_Possum_LowLevel.p ;  possumDB.mexw64/possumDB.mexw32 )

%.......................................................................
% Questions? ==>ask via email j.guivant@unsw.edu.au or via Moodle Forum.
%.......................................................................

% ---------------------------------------------------------------------
function main()

% .................
% We initialize the API; this is usually done just once, when your program starts
My4010API = API_PossumUGV2(1) ;
if (My4010API.Ok<1), return ; end;   
% .................
% ---------------------------
% USEFUL commands, for operating the simulator, from your program.
% if you are using Possum playBack program, you may restart it, if necessary.
My4010API.More.SendCmdToSimulator('restart');
% or "rewind" to time=0
% My4010API.More.SendCmdToSimulator('jump 0')

% My4010API.More.SendCmdToSimulator('p');  % also: to pause simulator,
% My4010API.More.SendCmdToSimulator('c');  % and to continue.  

% Idea: you may create some GUI controls for operating the simulator, from Matlab.
% (just an idea. Not neccessary)
% ---------------------------



% ........................
% Create some graphical object (because We want to show some plots,
% periodically). We will plot in Cartesian.
figure(1) ; clf() ;  hold on ;
handlePlot1 = plot(0,0,'.') ;           % to show all the scan points   (blue dots)       
handlePlot2 = plot(0,0,'r+') ;          % ..just for highly reflective points  (red crosses)            
hold off;
xlabel('X (cms)'); ylabel('Y (cms)');

axis([-1000,1000,0,1500]) ;             % by default zoom focuses on this area (in cm)
zoom on ;
title('Test-Lms200-xy (running)');
% ........................

% Implicit angles, associated to the measured ranges.
% aa = [0:360]'*pi/360 ;                % We do know these are the related angles to the laser 361 ranges
aa = [360:-1:0]'*pi/360 ;               % I use this way, because the scanner was installed upside-down.

cosaa = cos(aa) ;                       % These vectors are constants ==> I evaluate them OUTSIDE the loop
sinaa = sin(aa) ;
mask13 = uint16(2^13-1) ;               % mask for extracting the first 13 bits of an integer number







N = 1000;
for i=1:N,                           % loop for periodic execution, N iterations...
    
    r = My4010API.ReadLMS200(2, 1) ;     % from laser unit#2, get just one scan (last one)
    if r.n>0,                             % verify if we actually got any new laser scan.

        Ranges =double(bitand(r.Ranges(:,r.n),mask13));        % the range is in the lowest 13 bits of the 16 bits integer *see note (1))
        Intensity = bitshift(r.Ranges(:,r.n),-13);             % the intensity is in the highest 3 bits of the 16 bits integer *see note (1))
        ii = find(Intensity>0);
        
        xx = Ranges.*cosaa ;                                    % evaluate cartesian represetation
        yy = Ranges.*sinaa ;
        set(handlePlot1,'xdata',xx,'ydata',yy) ;                % refresh plot of XY points
        set(handlePlot2,'xdata',xx(ii),'ydata',yy(ii)) ;        % refresh plot of XY points
        fprintf('time =[%.3f]\n',double(r.times(r.n))/10000) ;  % print sample time , in seconds
    end;    
    
    
    pause(0.1) ;                                                %  sleep for some short period of time, release cpu
end;

figure(1) ;  title('Test-Lms200-xy (Ended)'); disp('BYE..');
% bye. there is no need to close any handle or other Possum's API resource,
% we just leave...

return ;
end
% ---------------------------------------------------------------------
% ..  About the structure that contains the read laser scans ....
% r.n                   : number of new laser frames
% r.Ranges(:,1:r.n)     : new laser scans
% r.times(1:r.n)        : timestamps
% NOTE that the useful data is contained in the first 'r.n' columns! 
% r.Ranges(:,j)         : laser scan # j , where j  /  1<=j<=r.n
% r.times(j)            : associated timestamp of laser scan #j
% .Ranges is class "uint16"  (*1)(you may need to convert it to other format, e.g. double)   
% .times  is class "uint32"  (...)   
%
% (*1) Compossed by a distance measurement (in cm) and a reflection index.
% * distance is stored in bits [0:12] of the 16 bits measurement
% * reflection index is stored in bits [13:15]
% ---------------------------------------------------------------------


%.......................................................................
% Questions? ==>ask via email j.guivant@unsw.edu.au or via Moodle Forum.
%.......................................................................