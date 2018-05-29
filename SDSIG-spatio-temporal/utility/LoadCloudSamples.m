

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
    
    user_input = input('Could not detect the cloud field samples, unzip them within into supporting_files. Want to reproduce? Y/N')
    if strcmpi(user_input,'Y')
        % if they dont exist, produce them
        ProduceVectorCloudFieldSamples
        
        disp('Loading store of cloud samples')
        for i=0:10
            name=['V2_clouds_vectors_sample',num2str(i),'__temporal_res_',num2str(temporal_res),'__spatial_res_',num2str(spatial_res),'__',num2str(num_of_samples),'_num_of_samples__',num2str(max_num_of_clouds),'max_num_of_clouds'];
            x=dlmread(fullfile('supportingfiles',name));
            assignin('base',['cov',num2str(i)],x);
        end
    else
        error('Did not remake cloudfields, try unzipping them as they exist within the git repo')
    end
end
