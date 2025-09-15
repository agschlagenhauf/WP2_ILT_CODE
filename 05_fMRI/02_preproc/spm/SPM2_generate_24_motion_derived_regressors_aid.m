% generate set of 24 motion-derived regressors
% script takes the 6 realignment paramter .txt file generated in spm during
% preproc and creates a 24 parameter file suitable to be added as “multiple regressors” 
% in a first level SPM fMRI analysis

% The first 6 are copies of the input (6 rigid body motion parameters),
% the next 6 columns are the squares of these parameters,
% the next 6 columns are the temporal derivatives of the motion parameters,
% and the final 6 columns are the squares of  the temporal derivatives. 

% 30-08-22 Claudia Ebrahimi 25-01-2024 Milena Musial

clear all; clc;

mainpath='S:\AG\AG-Schlagenhauf_TRR265\Daten\B01\WP2_DATA\04_derivatives_spm'; 

list_sub_data_paths = spm_select(inf, 'dir', 'Choose subject folders','',  mainpath); 


for sub=1:size(list_sub_data_paths,1)
      
    sub_rp_path = fullfile(list_sub_data_paths(sub,:), 'func');
    
    sub_rp_file_aid = spm_select('List', sub_rp_path, '^rp_a.*aid_bold.*\.txt$');
    
    sub_rp_file_aid
    
    sub_rp_file_path_aid = fullfile(sub_rp_path, sub_rp_file_aid);
    
    %rp_file einlesen
    
       matrix_aid  = textread(sub_rp_file_path_aid);
       
        % squares of 6 base movement paramters
       square_base_aid= matrix_aid.^2;
       
       % temporal derivatives 6 base parameters, i.e. the difference
       % between timepoint t and t-1
       tempderiv_base_aid=[zeros(1,6); matrix_aid(2:end,1:6) - matrix_aid(1:end-1,1:6)];
       
       % squares of temporal derivatives
       sqrt_tempderiv_aid=tempderiv_base_aid.^2;
       
       new_params_aid=[matrix_aid square_base_aid tempderiv_base_aid sqrt_tempderiv_aid];
       
       % save as .mat file

       outfile_aid = [ '24params_' sub_rp_file_aid];
       
       save(fullfile(sub_rp_path,outfile_aid), 'new_params_aid', '-ascii');
       
       clear new_params_aid 
    

end %subject