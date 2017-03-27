% ---------------------------------------------------------------------
% Example: It shows how to read measurements, from many sources, using the medium level API. 
% Description: Periodically reads certain sensors' data and prints the
% number of samples obtained from each sensor.
% Example provided by Jose Guivant/Alicia Robledo - 2012.

% NEEDED resources:  
%       * Possum.exe running;
%       * Simulator.exe running or connection to real UGV system.
%       * Possum API for Matlab (provided "mex" and "p" files):
%       ( API_PossumUGV.p ; API_Possum_LowLevel.p ;  possumDB.mexw64/possumDB.mexw32 )

%   Read this program for understanding how to use the data.
% ---------------------------------------------------------------------



function ExampleReadManySensors()

% Initialize Possum's API, just once, at the start of the program
AAA = API_PossumUGV2(0);
if (AAA.Ok<1), return ; end;   % if it fails, ==>bye.
% This is usually done just once, when your program starts

% ---------------------------
% USEFUL commands, for operating the simulator, from your program.
% if you are using Possum playBack program, you may restart it, if necessary.
AAA.More.SendCmdToSimulator('restart');
% or "rewind" to time=0
% AAA.More.SendCmdToSimulator('jump 0')

% AAA.More.SendCmdToSimulator('p');  % also: to pause simulator,
% AAA.More.SendCmdToSimulator('c');  % and to continue.  

% Idea: you may create some GUI controls for operating the simulator, from Matlab.
% (just an idea. Not neccessary)
% ---------------------------
% real sensors, once, here, for flushing API buffers,
    rI1 = AAA.ReadIMU(1,1) ;         % read last measurement, from IMU #1
    rLa = AAA.ReadLMS200(2,1) ;      % from laser unit#2, get just 1 scan (last arrived one)
    rS  =AAA.ReadSpeed(1,1) ;        % read last one, from speed sensor #1
    pause(0.05);
% ---------------------------

tI = rI1.tcx(1);
tL = rLa.times(1);
tS = rS.tcx(1);

x = [0;0; pi/2;];

fprintf('Loop, for periodic processing (Use "brute force" control-C for breaking it.....\n') ;
while 1
% (periodic execution: in a for loop, while loop, timers, callbacks, ..use your way)
        
    tic();

    % read all the sources of data (sensors, etc....)
    
    %read IMU unit #1. It reads new arrived mesurements, up to 100 samples.
    rI1 = AAA.ReadIMU(1,100) ;
    
    L=15;               % up to 15 laser scans
    rLa = AAA.ReadLMS200(2,L) ;      % from laser unit#2, get just L scans (last L arrived ones)
    %API: read from LMS200, unit #2, last of the newly arrived scans.  
    rS  =AAA.ReadSpeed(1,100) ; % read up to 100 speed measurements
    
    % You may read other sensor or estimates as well

    % The rest of this code is for using the data (your business!)
    
    dtReading = toc(); 
    % BTW: just reading all this data would make Matlab to consume << 1% of CPU
         
    x = ProcessAllData(rI1,rLa,rS,x);        % this is your part. 

     dt = toc();
     dt = 0.1-dt;          % 0.1 because I want this loop to run at rate ~10hz.
     if (dt<0.01), dt=0.01 ; end;
     pause(dt) ;           
     % your processing programs would usually run faster (e.g.~50).This is just an example.
    
    
    
end;
fprintf('Loop ended\n');
return;
end

% ..................... User's stuff .......
function  x = ProcessAllData(rI1,rLa,rS, x) 
% here you should process the new arrived data.....
fprintf('New samples: IMU1=[%d],LMS200a=[%d],SpeedMeter=[%d]\n',rI1.n,rLa.n,rS.n)
    speed = mean(rS.data(1:rS.n)); 
    GyroZ = mean(rI1.data(6,1:rI1.n));
    times = double(rS.tcx(1,1:rS.n));      
    times = times - times(1);
    times = times*0.0001;
    dt = times(end);
    
    x = RunProcessModel(x, speed, GyroZ, dt);
    partD(rLa, x);

end

function Xnext=RunProcessModel(X,speed,GyroZ,dt) 
    Xnext = X + dt*[ speed*cos(X(3)) ;  speed*sin(X(3)) ; GyroZ ] ;
return ;
end