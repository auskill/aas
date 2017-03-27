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



function part2()

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

x = [0;0; pi/2; 0;];
P = zeros(4,4) ;
P(4,4) = (4 * pi/180)^2;
P(4,4) = 2;

history = [0;0; pi/2; 0;];
count = 1;

landmarks = [];
startFlag = 1;

figure(1) ; clf(); 
biasHandle = plot(0,0,'b.'); hold on;
biasHandle2 = plot(0,0,'r.'); 

figure(2) ; clf();    
Handles.H1 = plot(0,0,'b.'); hold on;   %plot OOIs
Handles.H3 = quiver(0,0,0,0,'r');%plot position
Handles.H3 = plot(0,0, 'r.');
axis([-8,2,-1,7]);                         
xlabel('Position (degrees)');
ylabel('Position (meters)');
title('Laser Scan Processed Data');           
zoom on ;  grid on;

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
    if((rI1.n > 0) && (rLa.n > 0) && (rS.n > 0))
        [x, landmarks, P, history, count] = ProcessAllData(rI1,rLa,rS, x, startFlag, landmarks, P, history, count, Handles);
        yArray = 1:count-1;
        xArray = 1:count-1;
        xArray(:) = -0.017;

        set(biasHandle,'xdata', yArray, 'ydata',history(4,:));
        set(biasHandle2,'xdata', yArray, 'ydata', xArray);
        if length(landmarks) == 5
            startFlag = 0; 
        end
    end
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
function [x, landmarks, P, history, count] = ProcessAllData(rI1,rLa,rS, x, startFlag, landmarks, P, history, count, Handles)
% here you should process the new arrived data.....
fprintf('New samples: IMU1=[%d],LMS200a=[%d],SpeedMeter=[%d]\n',rI1.n,rLa.n,rS.n)
    
    stdDevGyro = 2*pi/180 ;        
    stdDevSpeed = 0.3 ;
    sdev_rangeMeasurement = 0.25 ;
    stdDevBear = 0.5 * pi / 180;

    Pu = diag([(stdDevSpeed)^2, (stdDevGyro)^2]);
    R = diag([sdev_rangeMeasurement*sdev_rangeMeasurement*4; 4 * stdDevBear * stdDevBear]);


    timeSpeed = double(rS.tcx(1,1:rS.n));      
    timeSpeed = timeSpeed - timeSpeed(1);
    timeSpeed = timeSpeed*0.0001;
    
    timeLaser = double(rLa.times(1,1:rLa.n));      
    timeLaser = timeLaser - timeLaser(1);
    timeLaser = timeLaser*0.0001;
    
    timeIMU= double(rI1.tcx(1,1:rI1.n));      
    timeIMU = timeIMU - timeIMU(1);
    timeIMU = timeIMU*0.0001;
    
    speed = rS.data(1:rS.n); 
    GyroZ = rI1.data(6,1:rI1.n);
    
    laserOld = -1;
    for i=2:rI1.n 
        speedIndex = find(timeSpeed <= timeIMU(i), 1, 'last');
        laserIndex = find(timeLaser <= timeIMU(i), 1, 'last');
        dt = timeIMU(i) - timeIMU(i-1);         
        x = RunProcessModel(x, speed(speedIndex), GyroZ(i), dt);
        
        J = [ [1,0,-dt*speed(speedIndex)*sin(x(3)), 0]  ; [0,1,dt*speed(speedIndex)*cos(x(3)), 0] ;    [ 0,0,1, -dt]; [0,0,0,1]; ] ;
        Ju = [ [cos(x(3))*dt,0] ; [sin(x(3))*dt,0] ; [0,dt]; [0,0]; ];
        Qi = diag( [ (0.01)^2 ,(0.01)^2 , (1*pi/180)^2, (1*pi/(180*60*60)*dt)^2]) ;


        Qu = Ju*Pu*Ju';
        Q = Qi + Qu;
        P = J*P*J'+Q;
        
        if laserIndex > laserOld + 1
            [correctedOOIs, OOIs]  = partD(rLa.Ranges(:, laserIndex), x, landmarks, history, Handles);
            laserOld = laserIndex;
            
        end
        
        if startFlag == 0
            [P, x] = EKFlocal2(x, landmarks, OOIs, P, R);
            history(:,count) = x;
            count = count + 1;  
        end

    end
    if startFlag == 1
       landmarks = correctedOOIs(1:2,:);
    end

end

function Xnext=RunProcessModel(X,speed,GyroZ,dt) 
    Xnext = X + dt*[ speed*cos(X(3)) ;  speed*sin(X(3)) ; GyroZ - X(4); 0 ] ;
return ;
end