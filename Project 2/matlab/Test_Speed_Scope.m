% .................................................................
% Example: reading sensor data. Jose Guivant - MTRN4010 - Session 1 /2013
% Specifically: it shows how to read the robot's speed measurement in real-time
% This example also shows how to refresh plot by using the Matlab's function SET()
% The program reads, periodically, data from the speed source, and stores the readings
% in a circular buffer, that is refreshed in a plot, like as an
% oscilloscope.

% Read this program, you need to understand how to use the API in order to
% implement your modules for the subsequent projects

% NEEDED resources:  
%       * Possum.exe running;
%       * Simulator.exe running or connection to real UGV system.
%       * Possum API for Matlab (provided "mex" and "p" files):
%       ( API_PossumUGV.p ; API_Possum_LowLevel.p ;  possumDB.mexw64/possumDB.mexw32 )

% Questions? ==>ask via email j.guivant@unsw.edu.au or via Moodle Forum.

% .................................................................
function main()

% Initialize Possum's API, just once, at the start of the program
My4010API = API_PossumUGV2(0);
if (My4010API.Ok<1), return ; end;   % if it fails, ==>bye.
% This is usually done just once, when your program starts.

% Create a buffer for some horizon of time
BufferLength = 400 ;                            % e.g. horizon = 400 samples
MyBuffer = zeros(1,BufferLength,'single') ;
BufferCurrentTop=1 ;


%   Create a graphic object to show the plots/animations.
figure(1) ; clf() ; hold on ;
hhplot1 = plot(MyBuffer(1,:)) ;
hhplot2 = plot(0,0,'r*','erasemode', 'xor') ; zoom on ;
ax=axis() ; ax(3) = -1; ax(4) = 1; axis(ax) ;ax=[];   % focuses on range -/+1 m/sec.
title('Showind Speed measurements')
ylabel('Speed, (in m/second)');
xlabel('Samples');
lastSpeed=0;


for i=1:100,                       % LOOP: do some interations..
    
    XX = My4010API.ReadSpeed(1,100) ; % read up to 100 speed measurements
    
    % the new data is in XX.data(:,1:XX.n)
  
    fprintf('Iteration(%d):[%d] new measurements read; curr speed =[%.2f]m/s\n',i,XX.n,lastSpeed) ;
    
    if XX.n>1,                      %if new available data does exist
        
        %Verify if the oscilloscope's buffer is going to be full.
        if ((BufferCurrentTop+XX.n)>BufferLength), 
                MyBuffer(:,:)=0 ;
                BufferCurrentTop=1 ;           % yes ==> reset history!
        end  ; 
        
        % add the new data in the buffer, in the proper place for looking
        % as a oscilloscope when refreshed in a figure
        MyBuffer(:,BufferCurrentTop:BufferCurrentTop+XX.n-1) = XX.data(:,1:XX.n) ; 
        BufferCurrentTop=BufferCurrentTop+XX.n ;
    
        % Refresh the "oscilloscope"
        % Every ~300 millisecs is OK for the CPU and good enough for our
        % brains to see how the signal is evolving.
        set(hhplot1,'ydata',MyBuffer) ;
        set(hhplot2,'xdata',BufferCurrentTop,'ydata',MyBuffer(1,BufferCurrentTop)) ;
        lastSpeed =  XX.data(1,XX.n) ;
    end;
        
    pause(.3) ;                         % wait for ~300ms    
end;

return ;    % BYE
end
% .................................................................

% Explanation about this API function ( ReadSpeed() ).

% This function provides the values of the speed sensor in a structure having these fields:
%  .data(1,1:n)    = speed measurements (m/s)
%  .tcx(1,1:n)     = sample time of the readings         ( 1 unit = 0.1 ms)
%   
%  .data is class "single"
%  .tcx  is class "uint32"  

%.......................................................................
% Questions? ==>ask via email j.guivant@unsw.edu.au or via Moodle Forum.
%.......................................................................
