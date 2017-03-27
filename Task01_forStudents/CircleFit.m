%Author: Karan Narula 16/03/2016
%this script is an example of how to fit circle to a set of values that has an 
%underlying center and radius which follow the equation of a circle. this is
%done by recasting the non-linear optimisation problem into a linear one
%using a small trick explained in the pdf documentation

%if you want the result to be replicated in each run, you should uncomment below
% seed = 0;
% rng(seed);

%true values
x_c = 0.1; y_c = -3.5;
center_real = [x_c;y_c];
radius_real = 3;

%make a set of values that follow the equation defined by the variables above
angle = 0:0.01:2*pi; angle = angle';
num_points = 10;
random_angles = angle(randperm(length(angle), num_points));
X = x_c + radius_real*cos(random_angles);
Y = y_c + radius_real*sin(random_angles);

%pollute the points with some random error
std = 1e-3;
X = X + std*randn(num_points,1);
Y = Y + std*randn(num_points,1);

%obtain a set of equations to obtain the experimental center and radius
timing = tic();
A = -2*[X(1:end-1) - X(2:end), Y(1:end-1)-Y(2:end)];
C = Y(2:end).^2 - Y(1:end-1).^2 + X(2:end).^2 - X(1:end-1).^2;
center_exp = A\C;
radius_exp = mean(sqrt((X - center_exp(1)).^2 + (Y - center_exp(2)).^2));
timing = toc(timing);

%display the results on screen
fprintf('Theoretical centers are (%f,%f) \n', center_real(1), center_real(2));
fprintf('Experimental centers are (%f,%f) \n', center_exp(1), center_exp(2));
fprintf('Theoretical radius is %f \n', radius_real);
fprintf('Experimental radius is %f \n\n', radius_exp);
fprintf('Time Taken to fit a circle for %d points is %f \n', num_points, timing);

%show result graphically
figure(1);clf; hold on;
plot(X, Y, 'rx', 'MarkerSize', 15);
plot(center_real(1),center_real(2), 'bx', 'MarkerSize', 15);
plot(center_exp(1),center_exp(2), 'gx',  'MarkerSize', 15);
x = center_real(1) + radius_real*cos(angle);
y = center_real(2) + radius_real*sin(angle);
plot(x,y, '--b');
x = center_exp(1) + radius_exp*cos(angle);
y = center_exp(2) + radius_exp*sin(angle);
plot(x,y, '--g');
legend('Points to be fitted in a circle', 'Real Center', 'Experimental Center', 'The real Circle', 'Experimental Circle');
axis equal;
