% .................................................................
% Example: reading sensor data. Jose Guivant - MTRN3100/4010 - Session 2015
% Specifically: it shows how to read the robot's IMU in real-time.
% This example also shows how to refresh plot by using the Matlab's function SET()
% The program reads, periodically, data from a IMU, and stores the readings
% in a circular buffer, that is refreshed in a plot, like an oscilloscope.

% Read this program, you need to understand how to use the API in order to
% implement your modules for the subsequent projects.

% Before reading this example, you should read a simpler example "ExampleReadIMU.m"

% .................................................................
function main()

% initialize Possum's API, just once, at the start of the program
M3100API = API_PossumUGV2(0);
if (M3100API.Ok<1), return ; end;   % if it fails, ==>bye.
% this is usually done just once, when your program starts

% create a buffer for some horizon of time
BufferLength = 300 ;                            % horizon = 300 samples
MyBuffer = zeros(9,BufferLength,'single') ;
BufferCurrentTop=1 ;

ChannelToPlot = 6 ;         % e.g. I choose gyro Z to be shown in the scope
k = 180/pi ;

%   create a graphic object to show the plots/animations
figure(1) ; clf() ; hold on ;
hhplot1 = plot(MyBuffer(ChannelToPlot,:)) ;
hhplot2 = plot(0,0,'r*','erasemode', 'xor') ; zoom on ;
ax=axis() ; ax(3) = -20; ax(4) = 20; axis(ax) ;ax=[];       % -/+20 degress/sec.
ylabel('Wz, (in degrees/second)')
xlabel('Samples')

% IMU data is composed by 9 rows (channels): (Ax,Ay,Az,GyroX,GyroY,GyroZ, MagnetomiterX, M..y,  M..Z ] 

for i=1:1000,                       % LOOP: do some interations..
    XX = M3100API.ReadIMU(1, 100) ;
    
    % the new data is in XX.Data(:,1:XX.n)
    fprintf('iteration(%d):[%d] new measurements read\n',i,XX.n) ;
    
    if XX.n>1,                      %if new available data does exist
        
        %verify if the oscilloscope's buffer is going to be full.
        if ((BufferCurrentTop+XX.n)>BufferLength), 
                MyBuffer(:,:)=0 ;
                BufferCurrentTop=1 ;           % yes ==> reset history!
        end  ; 
        
        % add the new data in the buffer, in the proper place for looking
        % as a oscilloscope when refreshed in a figure
        MyBuffer(:,BufferCurrentTop:BufferCurrentTop+XX.n-1) = k*XX.data(:,1:XX.n) ; 
        BufferCurrentTop=BufferCurrentTop+XX.n ;

    
    % refresh the "oscilloscope"
    % every 200 millisecs is OK for the CPU ang good enough for our
    % brains to see how the signal is evolving
    set(hhplot1,'ydata',MyBuffer(ChannelToPlot,:)) ;
    set(hhplot2,'xdata',BufferCurrentTop,'ydata',MyBuffer(ChannelToPlot,BufferCurrentTop)) ;
    
    end;
        
      
        
    pause(.2) ;                         % wait for ~200ms    
end;

%       BYE
return ;


%.......................................................................
% explanation of this API function ( ReadIMU() ).

% This function provides the values of the IMU in a structure having these fields:
%  .data and .t_cx
%  .data(1:3,1:n)  = 3D accelerations                    ( units in "G" (gravities))(*)
%  .data(4:6,1:n)  = 3D gyros (angular velocities)       ( units in rads/second)(*)
%  .data(7:9,1:n)  = 3D magnetometers                    ( units in "Gauss" )
%  .tcx(1,1:n)    =  sample times of the readings        ( 1 unit = 0.1  ms)(**)
%   
%   .data is class "single"
%   .tcx is class "uint32"

% (*) In sensor/platform's coordinate frame.
% (**)In Possum's Clock, common to all sensors we use. 

% .data(i,1:n)
% i=1 --> Acceleration X  
% i=2 --> Acceleration Y
% i=3 --> Acceleration Z
% i=4 --> Angular rate Wx
% i=5 --> Angular rate Wy
% i=6 --> Angular rate Wz   <===== We use this one, in our projects
% i=7 --> Magnetometer Mx
% i=8 --> Magnetometer My
% i=9 --> Magnetometer Mz

%.......................................................................
% Questions? ==>ask via email j.guivant@unsw.edu.au or via Moodle Forum.
%.......................................................................

