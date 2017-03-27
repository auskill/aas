%................................................................
% Example: It shows how to read IMU measurements using the Medium level API. 
% Description: Periodically reads and plots the last arrived IMU measurements.
% Provided by Jose Guivant/Alicia Robledo - 2011.

% see IMU.txt document for detalis about the IMU (location on UGV, etc)
% (although other IMU devices on the platform or on other platforms may be
% located at different points)

% NEEDED resources:  
%       * Possum.exe running;
%       * Simulator.exe running or connection to real UGV system.
%       * Possum API for Matlab (provided "mex" and "p" files):
%       ( API_PossumUGV.p ; API_Possum_LowLevel.p ;  possumDB.mexw64/possumDB.mexw32 )


% Questions? ==>ask via email j.guivant@unsw.edu.au or via Moodle Forum.

%................................................................
function ExampleReadIMU()

% initialize Possum's API, just once, at the start of the program
AAA = API_PossumUGV2(0);
if (AAA.Ok<1), return ; end;   % if it fails, ==>bye.
% this is usually done just once, when your program starts


fprintf('Infinite loop (control-C for breaking it.....\n') ;
while 1,     % (periodic execution: in a for loop, while loop, timers, callbacks, ..use your way)
    
    % read IMU unit #1. It reads new arrived mesurements, 
    % ... up to 100 records, if those are available.
    r = AAA.ReadIMU(1, 100) ;

    % You may read other sensor or estimates as well
    % See example "ExampleReadingManySensors.m"

    % the rest of this code is for using the data (your business!)
    ProcessMyImuData(r) ; 

    pause(.2) ;           % your processing programs would usually run faster (e.g.~50 or 100ms)
end;

end

% ..................... User's stuff .......
function  ProcessMyImuData(r) 

fprintf('[%d] newly arrived IMU records\n',r.n) ;
if r.n<1, return ; end;

% Each column corresponds to specific sample, providing accelerations, angular velocities, magnetometers, etc.   

% This way: 
% tcx(:,i) : [time;timeIMU;counter] (it is class "uint32")

% data(:,i) : [ax;ay;az; gyroX (roll rate);gyroY (pitch rate);gyroZ (yaw rate); magnetometerX;..Y;..Z];
% it is (class "single")

% where "timeIMU" is the time acording to IMU internal clock. 
% "time" is the timestmap according the system  (Possum's clock)(use this one for data fusion) 

ax = r.data(1,1:r.n);     % m/s^2
ay = r.data(2,1:r.n);     % m/s^2
az = r.data(3,1:r.n);     % m/s^2

kg = 180/pi;
wx = kg*r.data(4,1:r.n);     % wx originally in rad/s, we convert to degrees/sec to visualize.
wy = kg*r.data(5,1:r.n);     % wy originally in rad/s, ..
wz = kg*r.data(6,1:r.n);     % wz originally in rad/s, ..

mx = r.data(7,1:r.n);     % magnetometerx
my = r.data(8,1:r.n);     % magnetometery
mz = r.data(9,1:r.n);     % magnetometerz

% ... associated sample times (timestamps)
time = r.tcx(1,1:r.n); 
% time, 1 unit = 0.1ms. Possum Clock, at UGV node.

time=double(time-time(1))/10000 ;    % now, expressed in seconds
% we substract time(1) just for showing times starting at ZERO
% Read document "PossumTimestamps.pdf" for extra comments.

% "brute force" dynamic plotting. 
figure(1)  ; clf();
subplot(311) ; hold on ; plot(time,ax,'b'); plot(time,ay,'r'); plot(time,az,'g'); ylabel('accelerations (gravities)');
subplot(312) ; hold on ; plot(time,wx,'b'); plot(time,wy,'r'); plot(time,wz,'g'); ylabel('gyros (deg/secs)');
subplot(313) ; hold on ; plot(time,mx,'b'); plot(time,my,'r'); plot(time,mz,'g'); ylabel('magnetometers');
xlabel('time (secs)');

end

%.......................................................................
% Questions? ==>ask via email j.guivant@unsw.edu.au or via Moodle Forum.
%.......................................................................
