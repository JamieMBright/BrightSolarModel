

% typically, it seems that there are at least 90% unique cloud samples
% per bin across all speeds with 100 options.
name=['V2_clouds_vectors_sample0__temporal_res_',num2str(temporal_res),'__spatial_res_',num2str(spatial_res),'__',num2str(num_of_samples),'_num_of_samples__',num2str(max_num_of_clouds),'max_num_of_clouds'];

if exist(name,'file')
    disp('Loading store of cloud samples')
    for i=0:10
        if ~exist(['cov',num2str(i)],'var')
            name=['V2_clouds_vectors_sample',num2str(i),'__temporal_res_',num2str(temporal_res),'__spatial_res_',num2str(spatial_res),'__',num2str(num_of_samples),'_num_of_samples__',num2str(max_num_of_clouds),'max_num_of_clouds'];
            x=dlmread(fullfile('supportingfiles',name));
            assignin('base',['cov',num2str(i)],x);
            disp(['Loaded cloud sample for ',num2str(i),' /10 coverage'])
        end
    end
else
    
    % if they dont exist, produce them
    disp('The cloud fields did not exist, they will be produced.')
    disp('  note: this can take some time depending on the SDSIG settings')
    disp(['  there are ',num2str(u_range),' different wind speeds'])
    disp(['  there are ',num2str(c_range),' different cloud cover scenarios'])
    disp(['  there are ',num2str(num_of_samples),' number of cloud samples'])
    disp(['  each with ',num2str(num_of_clouds),' clouds in each'])
    disp([' the result is ',num2str(c_range),' files, each of',num2str(u_range*num_of_samples*3*num_of_clouds),' double elements in size'])
    disp([' the memory demanded is, therefore, ',num2str(c_range*u_range*num_of_samples*3*num_of_clouds*8), ' Bytes'])
    disp([' each file is ',num2str(u_range*num_of_samples*3*num_of_clouds*8), ' Bytes'])
    ProduceVectorCloudFieldSamples
    
    disp('Loading store of cloud samples')
    for i=0:10
        name=['V2_clouds_vectors_sample',num2str(i),'__temporal_res_',num2str(temporal_res),'__spatial_res_',num2str(spatial_res),'__',num2str(num_of_samples),'_num_of_samples__',num2str(max_num_of_clouds),'max_num_of_clouds'];
        x=dlmread(fullfile('supportingfiles',name));
        assignin('base',['cov',num2str(i)],x);
    end
    
end
