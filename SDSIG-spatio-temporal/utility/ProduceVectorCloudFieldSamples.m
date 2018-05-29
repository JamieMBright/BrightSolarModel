%% Vector Methodod to producing cloud tiles of different coverage, C, at different cloud speeds, u.
%% input variables

B=1.66; % Power Law Exponent /// p(x)=Cx^-B ///  (Wood & Field, 2011, Journal of Climate, Volume 24, p4800).
cloud_x_min=20;%minimum cloud length (decameters). Power law applicible to 0.1-1500km (Wood & Field,2011)
cloud_x_max=20;%maximum cloud length (decameters). (decameters selected as 10m=1 element resolution within vector)

%% make the blank arrays to pre-allocate memory.
samples0=zeros(max_num_of_clouds*u_range,3*num_of_samples); %make output arrays (filled with 3(xyr) x max_num_of_clouds options)
samples1=zeros(max_num_of_clouds*u_range,3*num_of_samples);
samples2=zeros(max_num_of_clouds*u_range,3*num_of_samples);
samples3=zeros(max_num_of_clouds*u_range,3*num_of_samples);
samples4=zeros(max_num_of_clouds*u_range,3*num_of_samples);
samples5=zeros(max_num_of_clouds*u_range,3*num_of_samples);
samples6=zeros(max_num_of_clouds*u_range,3*num_of_samples);
samples7=zeros(max_num_of_clouds*u_range,3*num_of_samples);
samples8=zeros(max_num_of_clouds*u_range,3*num_of_samples);
samples9=zeros(max_num_of_clouds*u_range,3*num_of_samples);
samples10=zeros(max_num_of_clouds*u_range,3*num_of_samples);

%% The Loop
% for u=1:u_range; % cycle through each cloud speed, u
%
%     tic
%     %set maximum x length. This is an hours distance, x=u*t. where t=number of seconds in an hour = 3600.
%x=u(m/s)*s/h, therefore in metres per hour.
%
%     coverage_bins=ones(1,coverage_range); %to keep a tally of the number of options.
% %     checker=1;
%     while sum(coverage_bins)~=(num_of_samples+1)*coverage_range %while each coverage value does not have the required number of samples, repeat until this is so. REINTRODUCE
%
%         %% set number of clouds
%         num_of_clouds=2000;%round((max_num_of_clouds-((u_range-u)*6.4))*rand);
%
%         % Make the output array (all these output arrays are uniform, so that referencing them within the solar model is also uniform)

%
clouds_store=zeros(u_range*c_range*num_of_samples,1);
u_store=zeros(u_range*c_range*num_of_samples,1);
C_store=zeros(u_range*c_range*num_of_samples,1);


error_flag=0;
rejections=0;
for u=1:u_range
    domain_x_max=u*3600;
    uTic=tic;
    disp(['u = ',num2str(u)]);
    for C=1:10
        samples=0;
        tic
        
        cloud_x_min=5;%minimum cloud length (decameters). Power law applicible to 0.1-1500km (Wood & Field,2011)
        cloud_x_max=200;%maximum cloud length (decameters). (decameters selected as 10m=1 element resolution within vector)
        
        alpha=cloud_x_max^(1-B); %to set power law {p(x)=Cx^-B} between limits and select random value...
        beta=cloud_x_min^(1-B) - alpha; % powerlaw becomes x=(alpha+beta*rand)^(1/(1-B)). rand==0 gives x_max. rand==1 gives x_min.
        %
        %         switch C
        %             case {0}
        %                 cloud_x_min=1;%minimum cloud length (decameters). Power law applicible to 0.1-1500km (Wood & Field,2011)
        %                 cloud_x_max=150;%maximum cloud length (decameters). (decameters selected as 10m=1 element resolution within vector)
        
        %             case {1,2}%1,2
        %                 cloud_x_min=1+u/3;%minimum cloud length (decameters). Power law applicible to 0.1-1500km (Wood & Field,2011)
        %                 cloud_x_max=150+u;%maximum cloud length (decameters). (decameters selected as 10m=1 element resolution within vector)
        %                 alpha=cloud_x_max^(1-B); %to set power law {p(x)=Cx^-B} between limits and select random value...
        %                 beta=cloud_x_min^(1-B) - alpha; % powerlaw becomes x=(alpha+beta*rand)^(1/(1-B)). rand==0 gives x_max. rand==1 gives x_min.
        %
        %
        %             case {3}%4,5,6
        %                 cloud_x_min=5+u/3;
        %                 cloud_x_max=175+u;
        %                 alpha=cloud_x_max^(1-B); %to set power law {p(x)=Cx^-B} between limits and select random value...
        %                 beta=cloud_x_min^(1-B) - alpha; % powerlaw becomes x=(alpha+beta*rand)^(1/(1-B)). rand==0 gives x_max. rand==1 gives x_min.
        %
        %
        %             case {6,7}
        %                 cloud_x_min=10+u/3;
        %                 cloud_x_max=200+u;
        %                 alpha=cloud_x_max^(1-B); %to set power law {p(x)=Cx^-B} between limits and select random value...
        %                 beta=cloud_x_min^(1-B) - alpha; % powerlaw becomes x=(alpha+beta*rand)^(1/(1-B)). rand==0 gives x_max. rand==1 gives x_min.
        %             case {9}
        %                 cloud_x_min=20+u/3;
        %                 cloud_x_max=250+u*2;
        %                 alpha=cloud_x_max^(1-B); %to set power law {p(x)=Cx^-B} between limits and select random value...
        %                 beta=cloud_x_min^(1-B) - alpha; % powerlaw becomes x=(alpha+beta*rand)^(1/(1-B)). rand==0 gives x_max. rand==1 gives x_min.
        %
        %             case {10}
        if C==10
            cloud_x_min=30+u;
            cloud_x_max=400+u;
            alpha=cloud_x_max^(1-B); %to set power law {p(x)=Cx^-B} between limits and select random value...
            beta=cloud_x_min^(1-B) - alpha; % powerlaw becomes x=(alpha+beta*rand)^(1/(1-B)). rand==0 gives x_max. rand==1 gives x_min.
            
        end
        
        
        while samples < num_of_samples
            coverage = -1;
            iterations_of_cloud_additions = 0;
            output_x=zeros(max_num_of_clouds,1);
            output_y=zeros(max_num_of_clouds,1);
            output_r=zeros(max_num_of_clouds,1);
            %             if C==0; C=C+0.4*rand;end %nature of while loop will end the sample on first addition of clouds, set target >0 by shifting to to 0:0.4 randomly,will introduce more variety in clearsky.
            while coverage < C
                
                
                %Add clouds cloud
                clouds_per_time=1;
                iterations_of_cloud_additions=iterations_of_cloud_additions+1;
                num_of_clouds=clouds_per_time*iterations_of_cloud_additions;
                if num_of_clouds>max_num_of_clouds;error_flag=1; end
                if error_flag==1;
                    disp('ERROR: max number of clouds exceeded');
                    break
                end
                
                for i=num_of_clouds-(clouds_per_time-1):num_of_clouds;
                    output_x(i,1)=rand*domain_x_max; %place the centrepoint within the x domain
                    output_y(i,1)=rand*domain_y_max; %place the centerpoint within the y domain
                    output_r(i,1)=1000;%10*0.5*((alpha+beta*rand)^(1/(1-B))); %radius according to power law. in meters.
                end
                %Analyse Coverage Value
                %the coverage will be calculated by regarding the domain area to be a set of xy coordinates. The exact area covered within the
                %domain can be calculated, however it requires compex surface integrations, and so a simple counting squares approach will
                %suffice
                
                xref=0;%the first x coordinate to check
                yref=0;%the first y coordinate to check
                %%%%%%%%%%% RES MUST BE A FACTOR OF LENGTH OF DOMAIN X and Y max
                %Factors of 1500: 1,2,3,4,5,6,10,12,15,20,25,30,50,60,75,100,125,150,250,300,375,500,750,1500,
                %Factors of 3600: 1,2,3,4,5,6,8,9,10,12,15,16,18,20,24,25,30,36,40,45,48,50,60,72,75,80,90,100,120,144,150,180,200,225,240,300,360,400,450,600,720,900,1200,1800,3600.
                %Shared factors: 1 2 3 4 5 6 10 12 15 20 25 30 50 60 75 100 150 300
                xres=250;%is u*3600 m long. take a reading every "xres" metres along the x-axis of the domain. minimum 3600 long, maximum 108000 long. Accuracy and speed lives or dies here.
                yres=250;%is 1500 m long. will check every "yres" metres along the y-axis of the domain.
                covered_tally=0; %reset the tally of covered points
                total_xys=(domain_x_max/xres)*(domain_y_max/yres); %total number of points within the domain. resembles an area. X/res * Y/res
                
                while xref<domain_x_max && yref<domain_y_max %once xref and y ref == the limits of the domain, every point has been checked.
                    
                    distances_to_cloud_centres=sqrt((output_x(1:num_of_clouds)-xref).^2+(output_y(1:num_of_clouds)-yref).^2); %find the distances to the centre point of each circle using pythagoras to find the hypotenuse of a right angled triangle with sides of dx and dy
                    
                    if max(distances_to_cloud_centres<output_r(1:num_of_clouds))==1; %  dist_to_cloud<chekr returns a binary array with 1 if the distance to cloud centre is less than r, and 0 if not. therefore the max of this array will return 1 or 0. If the answer is 1 then the (xref,yref) coordinate is within a cloud's radius, and therefore covered.
                        covered_tally=covered_tally+1; %if it is covered, add a point to the tally
                    end
                    
                    yref=yref+yres; %add an increment to the x axis for the next coordinate to check.
                    if yref==domain_y_max %if the coordinate is at the end of the row...
                        xref=xref+xres; %.. then increase the column yref by the one increment==yres...
                        yref=0; %... and reset the xref back to 0. The while loop will end once xref and yref are at their max.
                    end
                end
                
                coverage=round(10*covered_tally/total_xys); %(the number of (xref,yref) coordinates covered, divided by the total number of (xref,yref) coordinates within the domain = the coverage fraction*10 and rounded=integer of coverage.
                
                if coverage>C %if the sample is larger than C, then reset the sample and start again
                    iterations_of_cloud_additions = 0;
                    coverage=-1;
                    output_x=zeros(max_num_of_clouds,1);
                    output_y=zeros(max_num_of_clouds,1);
                    output_r=zeros(max_num_of_clouds,1);
                    rejections=rejections+1;
                    %                     disp(['     total rejections=',num2str(rejections),'| C=',num2str(C),'  u=',num2str(u)]);
                end
                
            end
            
            
            samples=samples+1;
            clouds_store((u-1)*c_range*num_of_samples+C*num_of_samples+samples,1)=num_of_clouds;
            C_store((u-1)*c_range*num_of_samples+C*num_of_samples+samples,1)=coverage;
            u_store((u-1)*c_range*num_of_samples+C*num_of_samples+samples,1)=u;
            %% Allocate into bins
            
            switch C
                case 0
                    samples0(max_num_of_clouds*u-(max_num_of_clouds-1):max_num_of_clouds*u,samples*3-2:samples*3)=[output_x,output_y,output_r]; %samplesx(x:x+500,y:y+3)=xyr.
                case 1
                    samples1(max_num_of_clouds*u-(max_num_of_clouds-1):max_num_of_clouds*u,samples*3-2:samples*3)=[output_x,output_y,output_r]; %samplesx(x:x+500,y:y+3)=xyr.
                case 2
                    samples2(max_num_of_clouds*u-(max_num_of_clouds-1):max_num_of_clouds*u,samples*3-2:samples*3)=[output_x,output_y,output_r]; %samplesx(x:x+500,y:y+3)=xyr.
                case 3
                    samples3(max_num_of_clouds*u-(max_num_of_clouds-1):max_num_of_clouds*u,samples*3-2:samples*3)=[output_x,output_y,output_r]; %samplesx(x:x+500,y:y+3)=xyr.
                case 4
                    samples4(max_num_of_clouds*u-(max_num_of_clouds-1):max_num_of_clouds*u,samples*3-2:samples*3)=[output_x,output_y,output_r]; %samplesx(x:x+500,y:y+3)=xyr.
                case 5
                    samples5(max_num_of_clouds*u-(max_num_of_clouds-1):max_num_of_clouds*u,samples*3-2:samples*3)=[output_x,output_y,output_r]; %samplesx(x:x+500,y:y+3)=xyr.
                case 6
                    samples6(max_num_of_clouds*u-(max_num_of_clouds-1):max_num_of_clouds*u,samples*3-2:samples*3)=[output_x,output_y,output_r]; %samplesx(x:x+500,y:y+3)=xyr.
                case 7
                    samples7(max_num_of_clouds*u-(max_num_of_clouds-1):max_num_of_clouds*u,samples*3-2:samples*3)=[output_x,output_y,output_r]; %samplesx(x:x+500,y:y+3)=xyr.
                case 8
                    samples8(max_num_of_clouds*u-(max_num_of_clouds-1):max_num_of_clouds*u,samples*3-2:samples*3)=[output_x,output_y,output_r]; %samplesx(x:x+500,y:y+3)=xyr.
                case 9
                    samples9(max_num_of_clouds*u-(max_num_of_clouds-1):max_num_of_clouds*u,samples*3-2:samples*3)=[output_x,output_y,output_r]; %samplesx(x:x+500,y:y+3)=xyr.
                case 10
                    samples10(max_num_of_clouds*u-(max_num_of_clouds-1):max_num_of_clouds*u,samples*3-2:samples*3)=[output_x,output_y,output_r]; %samplesx(x:x+500,y:y+3)=xyr.
            end
            
            if error_flag==1;break ;end
        end
        timer=toc;
        disp(['  C=',num2str(C),' time=',num2str(timer/60),'mins'])
        
        if error_flag==1;break ;end
    end
    toc(uTic)
    if error_flag==1;break ;end
end
if error_flag==0
    disp(['     total rejections=',num2str(rejections)]);
    %make summarry array
    u_mean=zeros(length(u_store)/num_of_samples,1);
    C_mean=zeros(length(u_store)/num_of_samples,1);
    n_mean=zeros(length(u_store)/num_of_samples,1);
    
    for i=1:length(u_mean)
        %take mean across all n
        u_mean(i)=mean(u_store((i-1)*num_of_samples+1:i*num_of_samples));
        C_mean(i)=mean(C_store((i-1)*num_of_samples+1:i*num_of_samples));
        n_mean(i)=mean(clouds_store((i-1)*num_of_samples+1:i*num_of_samples));
    end
    
    
    figure(1)
    hold on
    clear legends
    for i=1:u
        C=C_mean(u_mean==i);
        n=n_mean(u_mean==i);
        
        plot(C,n)
        legends{i}=num2str(i);
    end
    hold off
    xlabel('Coverage [fraction C/10]')
    ylabel('number of clouds')
    legend(legends)
    title(['clouds required at cloud size range ',num2str(cloud_x_min*10),':',num2str(cloud_x_max*10),'m'])
    
    
    
    %write the files out from matrix "samples"
    disp('Writing Files')
    for i=0:c_range-1
        string=['samples',num2str(i)];
        X=eval(string);
        dlmwrite(['V2_clouds_vectors_sample',num2str(i),'__temporal_res_',num2str(temporal_res),'__spatial_res_',num2str(spatial_res),'__',num2str(num_of_samples),'_num_of_samples','__',num2str(max_num_of_clouds),'max_num_of_clouds'],X)
    end

end