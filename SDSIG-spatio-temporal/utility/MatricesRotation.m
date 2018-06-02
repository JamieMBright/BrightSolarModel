%% The Matrix Rotation Function
% function that circularly rotates xy values within a square matrix 
% clockwise about its centre point by defined angle. 
% Created by : Jamie Brght
% Created : 27th February 2015 
%
% [x2 y2] = MatricesRotation(theta,x1,y1,m,n)
% Where:
% theta    is the angle (degs) to rotate coordinates by
% x1       is the list of x coordinates (n index)
% y1       is the list of corresponding y coordinates (m index)
% m        is the number of rows in the matrix to rotate
% n        is the number rof columns in the matrix to rotate
% x2       is the rotated n-index of the corresponding x1 input
% y2       is the rotated m-index of the corresponding y1 input

%% The function
function [x2 y2] = MatricesRotation(theta,x1,y1,mat_size)
%convert theta for clockwise rotation, clockwise seems more natural
theta = -theta;

%determine centre point from input m and n values
C=round(mat_size/2);

%convert to cartesian coordinates using new centrepoint
dx1=x1-C; 
dy1=y1-C;

%calculate the x' and y' values using the rotational matrices 
dx2=dx1.*cos(degtorad(theta)) - dy1.*sin(degtorad(theta));
dy2=dx1.*sin(degtorad(theta)) + dy1.*cos(degtorad(theta));


x2=dx2+C;
y2=dy2+C;

% %recalculated the original xy values, roudn them so that indexing is
% %logical
% x2=round(dx2+C); 
% y2=round(dy2+C);

%if the rotation takes the point outside of the defined m-by-n matrix, set it at the nearest point. 
x2(x2<1)=1; 
x2(x2>mat_size)=mat_size;
y2(y2<1)=1;
y2(y2>mat_size)=mat_size;

end


%% Use this to test the function
% % clear all
% % 
% % % Define
% % num_of_points=100; % number of points to place within matrix
% % mat_size=100; %define size of square matrix (mat_size -by- mat_size)
% % 
% % %%
% % x1=round(1+rand(num_of_points,1)*(mat_size/2-1)); %select random x locations
% % y1=round(1+rand(num_of_points,1)*(mat_size/2-1)); %select random y locations
% % 
% % theta=360*rand; %select an angle of rotation
% % 
% % [x2 y2]=MatricesRotation(theta,x1,y1,mat_size); %use the MatricesRotation function to get rotated x y values
% % 
% % 
% % X1=zeros(mat_size,mat_size); %make the matrix for initial xy values
% % X2=zeros(mat_size,mat_size); %make the matrix for rotated xy values
% % X3=zeros(mat_size,mat_size); %make matrix for showing both before and after
% % 
% % 
% % for i=1:num_of_points % plot the x values into the matrices
% %     X1(x1(i),y1(i))=1; %populate X1
% %     X2(x2(i),y2(i))=1; %populate X2
% %     
% %     X3(x1(i),y1(i))=1; %populate X3
% %     X3(x2(i),y2(i))=2; 
% % end
% % 
% % %plot a figure with subplots to show the before and after
% % figure(1)
% % subplot(2,1,1) %produce subplot
% % imagesc(X1) %tile plot of before
% % colormap gray %gray with binary plots black and white
% % title('original') %title
% % subplot(2,1,2) %produce second subplot
% % imagesc(X2) %tile plot of afte
% % colormap gray %also black and white
% % title(['rotated clockwise by ',num2str(theta),'deg']) %title it displaying the angle rotated by
% % 
% % figure(2) % produce a second plot
% % imagesc(X3) %plot both on same tile plot
% % colormap hot %jet wil give 3 different values
% % title(['original = orange :::: ','rotated clockwise by ',num2str(round(theta)),'deg = white']);
