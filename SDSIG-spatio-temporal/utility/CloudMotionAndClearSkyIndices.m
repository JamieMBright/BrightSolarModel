%% Extract Coefficients of KC distributions from Smith et al. 2017 inclusive of further extrapolation
disp('Loading kc=f(okta,solar elevation) distributions');
% the information is stored in the .txt file
filename = 'clear-sky-distribution-coefficients.txt';
delimiter = ',';
startRow = 2;
formatSpec = '%s%f%f%s%f%f%f%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false);
fclose(fileID);

% create a struct of the differnt variables
coeff.obstype = dataArray{1,1}; %manual, auto observation reference
coeff.okta1 = dataArray{1,2}; % okta reference
coeff.elevmin =  dataArray{1,3}; %elevation reference
coeff.disttype =  dataArray{1,4}; % distribution type (burrIII or generalised Gamma)
coeff.scale =  dataArray{1,5}; % parameters
coeff.shape1 =  dataArray{1,6};
coeff.shape2 =  dataArray{1,7};
%select range to draw distributions from. if started at 0, Nan would be given and would disrupt future script. 2 is a contingency and highly rare except at low zeniths.
distribution_range=0.01:0.01:2; 

% L=3600; % a constant in determining the resolution of which the spline'd line will be applied
% kc_residual=0; %the start residual value for the clear sky, it is used in first loop.
% xx=1:1:temporal_res*hours; % length of simulation in minutes, used in spline function
% Y=0.5; % pre allocation is too variable, so is redefined each iteration. Inefficient but practical.
% x=0.5; % pre allocation is too variable, so is redefined each iteration. Inefficient but practical.
% okta_hourly(okta_hourly==10)=0; %return all okta 0 moments to be represented by 0, not 10.


%% Cloud motion and clear-sky time series production
disp('Moving cloud fields across spatial domain. This may take some time')
disp(' Process: ')
disp('  1) select cloud field')
disp('  2) assign clear-sky indices to each cloud based of distribution')
disp('  3) move the cloud field across the houses and record time series')
disp('  4) persist each house values to disk, easier to manage many sites')

% Clear the temporary files.
delete(['supportingfiles',filesep,'temporary_files',filesep,'*']);

for Hour =1:length(time) %loop every hour in the simulation
    
    %     reporting every 10% completion
    if mod((100*Hour/length(time)),10)==0
        disp([num2str(round(100*Hour/length(time))),'% complete'])
    end
    
     %extract the okta for that hour
    this_hour_okta=cloud_amount_sim(Hour);    
    %determine the lowest elevation within that hour (from the 1-min-res vector) rounded to nearest 10.
    elev_hour=round(min(elevation(Hour*temporal_res-(temporal_res-1):Hour*temporal_res))/10)*10;
    
    if Hour>1 % For all hours after the very first in the simulation..
        %the current cloud field is set the previous hour's future cloud field, and so only need to load new xyr2
        xyr=xyr2; 
    else %for the first hour, create the cloud field.
        %extract the weather data to select appropriate cloud field.
        u_ref=wind_speed_sim(Hour); %cloudspeed
        c_ref=coverage_sim(Hour); %coverage
        n_ref=cloud_field_sample_sim(Hour); %random variate for the hour
        dir_ref=cloud_dir_sim(Hour); %cloud direction
        
        %Extract a cloud field
        switch c_ref
            case 0
                xyr=cov0(u_ref*max_num_of_clouds-(max_num_of_clouds-1):u_ref*max_num_of_clouds,3*n_ref-2:3*n_ref);
            case 1
                xyr=cov1(u_ref*max_num_of_clouds-(max_num_of_clouds-1):u_ref*max_num_of_clouds,3*n_ref-2:3*n_ref);
            case 2
                xyr=cov2(u_ref*max_num_of_clouds-(max_num_of_clouds-1):u_ref*max_num_of_clouds,3*n_ref-2:3*n_ref);
            case 3
                xyr=cov3(u_ref*max_num_of_clouds-(max_num_of_clouds-1):u_ref*max_num_of_clouds,3*n_ref-2:3*n_ref);
            case 4
                xyr=cov4(u_ref*max_num_of_clouds-(max_num_of_clouds-1):u_ref*max_num_of_clouds,3*n_ref-2:3*n_ref);
            case 5
                xyr=cov5(u_ref*max_num_of_clouds-(max_num_of_clouds-1):u_ref*max_num_of_clouds,3*n_ref-2:3*n_ref);
            case 6
                xyr=cov6(u_ref*max_num_of_clouds-(max_num_of_clouds-1):u_ref*max_num_of_clouds,3*n_ref-2:3*n_ref);
            case 7
                xyr=cov7(u_ref*max_num_of_clouds-(max_num_of_clouds-1):u_ref*max_num_of_clouds,3*n_ref-2:3*n_ref);
            case 8
                xyr=cov8(u_ref*max_num_of_clouds-(max_num_of_clouds-1):u_ref*max_num_of_clouds,3*n_ref-2:3*n_ref);
            case 9
                xyr=cov9(u_ref*max_num_of_clouds-(max_num_of_clouds-1):u_ref*max_num_of_clouds,3*n_ref-2:3*n_ref);
            case 10
                xyr=cov10(u_ref*max_num_of_clouds-(max_num_of_clouds-1):u_ref*max_num_of_clouds,3*n_ref-2:3*n_ref);
        end
    end
    
    %ignore empty cloud slots (there can be 0:max_num_of_clouds in each tile), extract only present clouds for computational efficiency and accuracy
    r1=xyr(:,3); r1=r1(r1>0);
    x1=xyr(:,1); x1=x1(r1>0);
    y1=xyr(:,2); y1=y1(r1>0);
    kc1 = zeros(1,numel(r1>0)); 
        
    %% Assign kc values to each cloud
    if elev_hour<0 %if the elevation angle is below 0, the sun is set and it is unimportant, so skip and save time
    else
        CompoundConditionInd= ((coeff.elevmin==elev_hour) & (coeff.okta1==this_hour_okta)); %find the appropriate row reference for the distribution parameters within the coefficients.csv file using compound logical statment
        switch this_hour_okta 
            case {0,1,2,3} %okta 0:3 all use a BurrIII distribution

                %extract the shape and scale parameters from coefficients.csv using the indicator CompoundConditionalInd
                alpha_ScaleParameter=coeff.scale(CompoundConditionInd==1); 
                c_ShapeParameter=coeff.shape1(CompoundConditionInd==1);
                k_ShapeParameter=coeff.shape2(CompoundConditionInd==1);

                %Create the BurrIII distribution PDF using the paramaters above
                burrIIIPDF=((c_ShapeParameter.*k_ShapeParameter)./alpha_ScaleParameter).*(distribution_range./alpha_ScaleParameter).^(-c_ShapeParameter-1).*(1+(distribution_range./alpha_ScaleParameter).^(-c_ShapeParameter)).^(-k_ShapeParameter-1);
                burrIIICDF=cumsum(burrIIIPDF)./100; %make CDF.
              
                %assign each cloud a kc value from the new distribution
                for ii=1:numel(r1>0)
                    kc1(ii)=sum(burrIIICDF<rand)./100;
                end
                
            case {4,5,6,7,8,9} %okta 4:9 use a generalised Gamma function
                %extract the shape and scale parameters from coefficients.csv using the indicator CompoundConditionalInd
                a_ScaleParameter=coeff.scale(CompoundConditionInd==1);
                p_ShapeParameter=coeff.shape1(CompoundConditionInd==1);
                d_ShapeParameter=coeff.shape2(CompoundConditionInd==1);
                %create the Genralised Gamma distribution PDF using the above parameters.
                genGammaPDF=(p_ShapeParameter.*distribution_range.^(d_ShapeParameter-1).*exp(-(distribution_range./a_ScaleParameter).^p_ShapeParameter))./(a_ScaleParameter.^d_ShapeParameter.*gamma(d_ShapeParameter./p_ShapeParameter));
                genGammaCDF=cumsum(genGammaPDF)./100; %make CDF
                
                %assign each cloud a kc value from the new distribution
                for ii=1:numel(r1>0)
                    kc1(ii)=sum(genGammaCDF<rand)./100; 
                end
        end
    end
    
%% Now perform the same for the future hour.
    if Hour<(length(time)-1) %so long as it is not the end of the simulation...
        
        u_ref=wind_speed_sim(Hour+1); %cloudspeed
        c_ref=coverage_sim(Hour+1); %coverage
        n_ref=cloud_field_sample_sim(Hour+1); %random variate for the hour
        dir_ref=cloud_dir_sim(Hour+1); %cloud direction
        
        switch c_ref_next
            case 0
                xyr2=cov0(u_ref_next*max_num_of_clouds-(max_num_of_clouds-1):u_ref_next*max_num_of_clouds,3*n_ref_next-2:3*n_ref_next);
            case 1
                xyr2=cov1(u_ref_next*max_num_of_clouds-(max_num_of_clouds-1):u_ref_next*max_num_of_clouds,3*n_ref_next-2:3*n_ref_next);
            case 2
                xyr2=cov2(u_ref_next*max_num_of_clouds-(max_num_of_clouds-1):u_ref_next*max_num_of_clouds,3*n_ref_next-2:3*n_ref_next);
            case 3
                xyr2=cov3(u_ref_next*max_num_of_clouds-(max_num_of_clouds-1):u_ref_next*max_num_of_clouds,3*n_ref_next-2:3*n_ref_next);
            case 4
                xyr2=cov4(u_ref_next*max_num_of_clouds-(max_num_of_clouds-1):u_ref_next*max_num_of_clouds,3*n_ref_next-2:3*n_ref_next);
            case 5
                xyr2=cov5(u_ref_next*max_num_of_clouds-(max_num_of_clouds-1):u_ref_next*max_num_of_clouds,3*n_ref_next-2:3*n_ref_next);
            case 6
                xyr2=cov6(u_ref_next*max_num_of_clouds-(max_num_of_clouds-1):u_ref_next*max_num_of_clouds,3*n_ref_next-2:3*n_ref_next);
            case 7
                xyr2=cov7(u_ref_next*max_num_of_clouds-(max_num_of_clouds-1):u_ref_next*max_num_of_clouds,3*n_ref_next-2:3*n_ref_next);
            case 8
                xyr2=cov8(u_ref_next*max_num_of_clouds-(max_num_of_clouds-1):u_ref_next*max_num_of_clouds,3*n_ref_next-2:3*n_ref_next);
            case 9
                xyr2=cov9(u_ref_next*max_num_of_clouds-(max_num_of_clouds-1):u_ref_next*max_num_of_clouds,3*n_ref_next-2:3*n_ref_next);
            case 10
                xyr2=cov10(u_ref_next*max_num_of_clouds-(max_num_of_clouds-1):u_ref_next*max_num_of_clouds,3*n_ref_next-2:3*n_ref_next);
        end
        
        r2=xyr2(:,3); r2=r2(r2>0);
        x2=xyr2(:,1); x2=x2(r2>0);
        y2=xyr2(:,2); y2=y2(r2>0);
        kc2 = zeros(1,numel(r2>0));
        
        %% Apply KC
        if elev_hour<0             
        else
            CompoundConditionInd= (coeff.elevmin==elev_hour) & (coeff.okta1==this_hour_okta); 
            switch this_hour_okta %loop through each moment within the temporary, hourly okta factored vector
                case {0,1,2,3} %okta 0:3 all use a BurrIII distribution
                    alpha_ScaleParameter=coeff.scale(CompoundConditionInd==1);
                    c_ShapeParameter=coeff.shape1(CompoundConditionInd==1);
                    k_ShapeParameter=coeff.shape2(CompoundConditionInd==1);
                    burrIIIPDF= ((c_ShapeParameter.*k_ShapeParameter)./alpha_ScaleParameter).*...
                        (distribution_range./alpha_ScaleParameter).^(-c_ShapeParameter-1).*...
                        (1+(distribution_range./alpha_ScaleParameter).^(-c_ShapeParameter)).^(-k_ShapeParameter-1);
                    burrIIICDF=cumsum(burrIIIPDF)./100; 
                    for ii=1:numel(r2>0)
                        kc2(ii)=sum(burrIIICDF<rand)./100;
                    end
                    
                case {4,5,6,7,8,9} %okta 4:9 use a generalised Gamma function
                    a_ScaleParameter=coeff.scale(CompoundConditionInd==1); 
                    p_ShapeParameter=coeff.shape1(CompoundConditionInd==1);
                    d_ShapeParameter=coeff.shape2(CompoundConditionInd==1);
                    genGammaPDF=(p_ShapeParameter.*distribution_range.^(d_ShapeParameter-1).*...
                        exp(-(distribution_range./a_ScaleParameter).^p_ShapeParameter))./...
                        (a_ScaleParameter.^d_ShapeParameter.*gamma(d_ShapeParameter./p_ShapeParameter));
                    genGammaCDF=cumsum(genGammaPDF)./100; 
                    for ii=1:numel(r2>0)
                        kc2(ii)=sum(genGammaCDF<rand)./100;
                    end
            end
        end
        
    end
        
%% Move the clouds for this hour
        %pre allocate for computational efficiency. 
        separation=zeros(number_of_houses,60); %1 row per location
        house_coverages=zeros(number_of_houses,60);%60 mins=cols
        house_kcvalues=zeros(number_of_houses,60); 
        
    
    for cloudmovement=1:temporal_res %move the clouds looping each time step
        
        for house=1:number_of_houses %take each house at a time
            %orientate by the cloud direction
            [XY_rotated(:,1),XY_rotated(:,2)]=MatricesRotation(dir_ref,round(house_info(:,2)),round(house_info(:,1)),spatial_res); 
            dxd=spatial_res-XY_rotated(house,1); %distance: house x location to far edge of domain edge
            dX=cloudmovement*(3600/temporal_res)*u_ref_next; %Distance: house domain and cloud domain overlap
            dxeC2=dxd-dX+u_ref*3600; %distance: house to far edge of cloud field
            separation(house,cloudmovement)=XY_rotated(house,1);
            
            % attach together the cloud fields
            r_C1=[r1;r2]; %combine the radii from both cloud fields
            x_C1=[x1-3600*u_ref;x2]; %combine coordinates of clouds adjusting x by the size of the cloud field domain
            y_C1=[y1;y2]; %combine y coordinates of two fields
            kc_C1=[kc1';kc2']; %combine kc values of all.
                
            clouds=length(r_C1(r_C1>0)); %determine the number of clouds within the cloud domain
            if clouds>0 %so long as clouds are present...
                dx=dxd+x_C1-dX; % distance along x axis from house to cloud centre
                dy=XY_rotated(house,2)-y_C1; %distance in y direction of house to cloud
                d=sqrt(dx.^2+dy.^2); %direct line from house to cloud
                house_coverages(house,cloudmovement)=sum(d<r_C1(r_C1>0)); %record how many clouds are covering the house
                kcs1=kc_C1(d<r_C1); %extract appropriate kc values that cover the house
                if isempty(kcs1)==0
                    house_kcvalues(house,cloudmovement)=mean(kcs1); %take a mean of the kc values
                end
            end
        end
    end
    
   %% write separation house_kcvalues and house_coverages
   for house=1:number_of_houses
            dlmwrite(['supportingfiles',filesep,'temporary_files',filesep,num2str(house),'_separation.mat'],separation(house,:),'-append');
            dlmwrite(['supportingfiles',filesep,'temporary_files',filesep,'_house_kcvalues.mat'],house_kcvalues(house,:),'-append');
            dlmwrite(['supportingfiles',filesep,'temporary_files',filesep,'_house_coverages.mat'],house_coverages(house,:),'-append');
   end
end
