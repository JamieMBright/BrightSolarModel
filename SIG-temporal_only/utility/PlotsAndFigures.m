disp('Producing plots and figures')
%example plot 1 showing the irradiance.
r=0.9*rand; %random variable
rday=round(r*num_of_days); %select a random day from those simulated
dayofyear=rday-floor(rday/365)*365; % determine what day of the year this is (instead of day 730, this would be 365)
xstart=rday*24*60; %determine the start minute
xend=xstart+1440; %determine the end minute
yticks=[0,1]; %set the ytick locations for subplot2
ytickslabels={' ',' '}; %set the labels for subplot2
xticks=[0,60*4,60*8,60*12,60*16,60*20,1440]; %set the x tick locations
xtickslabels={'0','4','8','12','16','20','24'}; %set the xaxis labels for subplot 1
xxticks=[0,4,8,12,16,20,24]; %set the x tick labels for sub plot 2 and 3
yyticks=[0,3,6,9]; %set the y tick locations for subplot 1
okta_for_plot_1hr = cloud_amount_sim;
okta_for_plot_1hr(okta_for_plot_1hr==10)=0;%alter back an okta of 10 to 0. 10 was used in simulation for indexing

figure(1); %begin figure 1
subplot(3,1,1) %create the first of 3 subplots. subplot(rows,cols,ref)
bar(okta_for_plot_1hr((xstart/60)+2:24+(xstart/60)),'blue','BarWidth', 0.5) %make a bar of the okta number in blue with half width
ylabel('Okta Number') %label y axis
axis([0 24 0 9]) %set limits
set(gca,'YTick',yyticks,'XTick',xxticks,'XTickLabel',xtickslabels); %set the y and x ticks and labels.
v = axis; %set the axis
handle=title('a)'); %give it a label
set(handle,'Position',[2 v(4)*1.05 0]); %set axis location so that the title a) is in appropriate place

subplot(3,1,2) %subplot 2.
bar(sun_obscurred_sim(xstart:xend),'black','BarWidth', 1) %make solid black bar plot of cloud cover
ylim([-0.25 1.25]) %set the y limits for asthetics
xlim([0 1440]) %set x limits
set(gca,'YTick',yticks,'YTickLabel',ytickslabels,'XTick',xticks,'XTickLabel',xtickslabels) %set the x and y ticks and labels
ylabel('Cloud Cover') % label the y axis
legend('cloud') % add a legend.
v = axis; %set the axis
handle=title('b)'); %give it a label
set(handle,'Position',[120 v(4)*1.05 0]); %set axis location so that the title b) is in appropriate place

subplot(3,1,3) %subplot 3
plot(panel_irradiance(xstart:xend),'r') %red line of panel irradiance
xlim([0 1440]) %set x axis limits
set(gca,'XTick',xticks,'XTickLabel',xtickslabels) %set the x axis ticks and labels
ylabel('Irradiance (Wm^-^2)') %label y axis
xlabel(['Hours of day number ',num2str(dayofyear)]); %label x axis with day of year included
v = axis; %set the axis
handle=title('c)'); %give it a label
set(handle,'Position',[120 v(4)*1.05 0]); %set axis location so that the title c) is in appropriate place
