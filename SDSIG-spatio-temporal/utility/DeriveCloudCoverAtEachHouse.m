
%% produce coverage for each house
disp('Deriving cloud cover at each house')
disp('  this can take some time as it must loop through each hour')
disp('  and simulate the cloud fields passing above')

number_of_houses = size(house_info,1);
house_coverages=zeros(number_of_houses,length(time_1min_resolution)); %different rows of coverage, 1 for each property.

% preliminarily rotate houses to start from 0 degre cloud direction
Xs = house_info(:,1);
Ys = house_info(:,2);
[Xs,Ys]=MatricesRotation(90,Xs,Ys,spatial_res); %as the tiles will approach from the right, and 0deg is a northerly cloud direction, rotate the XY 90, so that north now points to the direction of the approaching cloud tile. This essentially "zeros" the cloud angle.

cloudmovement=0;
for min =1:size(house_coverages,2)
    
%     reporting every 10%
    if mod((100*min/size(house_coverages,2)),10)==0
        disp([num2str(round(100*min/size(house_coverages,2))),'% complete'])
    end
    
    if min>1
        xyr=xyr2;
    else
        
        u_ref=wind_speed_sim(ceil(min/temporal_res));
        c_ref=cloud_amount_sim(ceil(min/temporal_res));
        n_ref=cloud_field_sample_sim(ceil(min/temporal_res));
        dir_ref=cloud_dir_sim(ceil(min/temporal_res));
        
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
    
    r1=xyr(:,3); r1=r1(r1>0);
    x1=xyr(:,1); x1=x1(r1>0);
    y1=xyr(:,2); y1=y1(r1>0);
    
    
    if min<(length(time)-1)*temporal_res
        
        u_ref_next=wind_speed_sim(ceil(min/temporal_res)+1);
        c_ref_next=cloud_amount_sim(ceil(min/temporal_res)+1);
        n_ref_next=cloud_field_sample_sim(ceil(min/temporal_res)+1);
        dir_ref_next=cloud_dir_sim(ceil(min/temporal_res)+1);
        
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
        
    end
    
    
    for house=1:number_of_houses
        [XY_rotated(:,1),XY_rotated(:,2)]=MatricesRotation(dir_ref,round(Ys),round(Xs),spatial_res); %a list of the XY coordiantes rotated around the centrepoint by the cloud direction.
        dxd=spatial_res-XY_rotated(house,1); %distance: house to domain edge
        a=((u_ref*3600)/temporal_res)*cloudmovement; %distance of endge of domain to edge of cloud environment
        dxe=dxd-a; %distance of house to edge of cloud environment
        
        if dxe>=0 %if the house is witihn this particular cloud environment, use xyr1..........
            
            clouds=length(r1(r1>0));
            if clouds>0
                dxcd=ones(clouds,1).*(u_ref*3600)-x1; %distance from cloud to edge of clouds environment
                dxc=dxe-dxcd; %distance in x direction of house to cloud
                dyc=XY_rotated(house,2)-y1; %distance in y direction of house to cloud
                d=sqrt(dxc.^2+dyc.^2); %direct line from house to cloud
                
                house_coverages(house,min)=sum(d<r1(r1>0));
            end
        else %............else use xyr2
            
            clouds=length(r2(r2>0));
            if clouds>0
                dxcd=ones(clouds,1).*(u_ref*3600)-x2; %distance from cloud to edge of clouds environment
                dxc=dxe-dxcd; %distance in x direction of house to cloud
                dyc=XY_rotated(house,2)-y2; %distance in y direction of house to cloud
                d=sqrt(dxc.^2+dyc.^2); %direct line from house to cloud
                
                house_coverages(house,min)=sum(d<r2(r2>0));
            end
        end
        
    end
    
    cloudmovement=cloudmovement+1;
    if floor(min/temporal_res)==min/temporal_res % at the end of the hour, reset the movement
        cloudmovement=0;
    end
end


