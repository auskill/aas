% ---------------------------------------------------------------------
% Example: shows how to read from a LMS2XX laser scanner.  
% Description: Periodically reads and plots the last arrived scans from a LMS200 unit.
% Provided by Jose Guivant/Alicia Robledo - 2015.

% NEEDED resources:  
%       * Possum.exe running;
%       * Simulator.exe running or connection to real UGV system.
%       * Possum API for Matlab (provided "mex" and "p" files):
%       ( API_PossumUGV.p ; API_Possum_LowLevel.p ;  possumDB.mexw64/possumDB.mexw32 )

%   Read this program for understanding how to use the data, and also about some
%   basic processing and plotting in  Matlab.
% ---------------------------------------------------------------------

function ExampleReadLMS200()

AAA = API_PossumUGV2(1) ;
if (AAA.Ok<1), return ; end;   % this is usually done just once, when your program starts



MyContext.run=1;
CreateFigureToPlot(25) ;        % application specific, for plotting


fprintf('Infinite loop (control-C for breaking it.....\n') ;
while 1, 

    
    r = AAA.ReadLMS200(2,10) ;      
    %API: read LMS200, unit #2, up to 10 of the newly arrived scans.
    % depending how frequently I run this loop, I would read more or less.
    
    % you may read other sensor or estimates as well
    % See example "ExampleReadingManySensors.m"
    
    ShowData(r);    % application specfic, for plotting, etc.
    pause(0.2) ; 
end;

return;



%.......................................................................

%application specfic, for plotting, etc.    
% it create the "plot" objects, etc. The handles are preserved to be used
% later.

function CreateFigureToPlot(k)
   figure(k); clf;
   
   angles = single([0:360]'/360 *pi) ;  %LMS200 has 361 ranges/scan
   MyContext.cosinesAngles = cos(angles);
   MyContext.sinesAngles = sin(angles);
   MyContext.Mask0FFF = uint16(2^13-1);
   angles = angles*180/pi;
   
   subplot(211) ; MyContext.h1 = plot(angles,angles*0,'.') ; axis([angles(1),angles(end),0,7000]);
   xlabel('angle [POLAR]') ; ylabel('range (cm)') ;
   subplot(212) ; MyContext.h2 = plot(0,0,'.') ; axis([-800,800,0,1600]);
   zoom on; xlabel('x (cm) [Cartesian]') ; ylabel('y (cm)') ;
   subplot(211) ; 
   title('Learn how to use the Laser data!!!');
   
return;
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



function ShowData(r)
    
    if r.n>0,
        
        % see how We extract the data of interest
        % in this example We just plot the very last laser scan.
        j = r.n ;   % We choose the last one of the "n" new scans, to be plotted.
                    % You may use all of them, depending on what you need to do.
        
        
        Range = single(bitand(r.Ranges(:,j),MyContext.Mask0FFF));   
        % The first 13 bits are the actual range, in cm. <--API data format!!!!
        % See document "LMS2XX_data.pdf" for more details.
        
        set(MyContext.h1,'ydata',Range);
        xx = Range.* MyContext.cosinesAngles;
        yy = Range.* MyContext.sinesAngles;
        set(MyContext.h2,'xdata',xx,'ydata',yy);
        
        timestamp = r.times(j);                 
        % Associated timestamp of this laser scan
        % Read document "PossumTimestamps.pdf" for extra comments.
        
        fprintf('New arrived Laser records:  [%d]; time=[%d]\n',r.n,timestamp) ;
    
    end;

    % if you have read "r.n" records you can use each one in
    % this way:
        %ranges of scan #i  : r.Ranges(:,i)
        %timestamp  : r.times(i)
        % for all i \ 1<=i<=r.n
        % The highest 3 bits of each range correspond to the intensity of
        % the reflection, and the lower 13 bits the range itself (as used in
        % the plotting function) :  range = bitand(r.Ranges(:,i),8191)
        % btw:  8191 is 0x0FFF
        % This is because we usually use the LMS2XX's in that mode of operation.
        
        % Read document "PossumTimestamps.pdf" for extra comments.
        
    return;
end
%.......................................................................


end
%.......................................................................
% Questions? ==>ask via email j.guivant@unsw.edu.au or via Moodle Forum.
%.......................................................................