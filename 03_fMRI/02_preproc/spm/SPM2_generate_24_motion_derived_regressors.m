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
    sub_rp_file_ilt1 = spm_select('List', sub_rp_path, '^rp_a.*ilt_run-1_bold.*\.txt$');
    sub_rp_file_ilt2 = spm_select('List', sub_rp_path, '^rp_a.*ilt_run-2_bold.*\.txt$');
    
    sub_rp_file_aid
    
    sub_rp_file_path_aid = fullfile(sub_rp_path, sub_rp_file_aid);
    sub_rp_file_path_ilt1 = fullfile(sub_rp_path, sub_rp_file_ilt1);
    sub_rp_file_path_ilt2 = fullfile(sub_rp_path, sub_rp_file_ilt2);
    
    %rp_file einlesen
    
       matrix_aid  = textread(sub_rp_file_path_aid);
       matrix_ilt1  = textread(sub_rp_file_path_ilt1);
       matrix_ilt2  = textread(sub_rp_file_path_ilt2);

        % squares of 6 base movement paramters
       square_base_aid= matrix_aid.^2;
       square_base_ilt1= matrix_ilt1.^2;
       square_base_ilt2= matrix_ilt2.^2;

       % temporal derivatives 6 base parameters, i.e. the difference
       % between timepoint t and t-1
       tempderiv_base_aid=[zeros(1,6); matrix_aid(2:end,1:6) - matrix_aid(1:end-1,1:6)];
       tempderiv_base_ilt1=[zeros(1,6); matrix_ilt1(2:end,1:6) - matrix_ilt1(1:end-1,1:6)];
       tempderiv_base_ilt2=[zeros(1,6); matrix_ilt2(2:end,1:6) - matrix_ilt2(1:end-1,1:6)];

       % squares of temporal derivatives
       sqrt_tempderiv_aid=tempderiv_base_aid.^2;
       sqrt_tempderiv_ilt1=tempderiv_base_ilt1.^2;
       sqrt_tempderiv_ilt2=tempderiv_base_ilt2.^2;

       new_params_aid=[matrix_aid square_base_aid tempderiv_base_aid sqrt_tempderiv_aid];
       new_params_ilt1=[matrix_ilt1 square_base_ilt1 tempderiv_base_ilt1 sqrt_tempderiv_ilt1];
       new_params_ilt2=[matrix_ilt2 square_base_ilt2 tempderiv_base_ilt2 sqrt_tempderiv_ilt2];
  
       % save as .mat file

       outfile_aid = [ '24params_' sub_rp_file_aid];
       outfile_ilt1 = [ '24params_' sub_rp_file_ilt1];
       outfile_ilt2 = [ '24params_' sub_rp_file_ilt2];

       save(fullfile(sub_rp_path,outfile_aid), 'new_params_aid', '-ascii');
       save(fullfile(sub_rp_path,outfile_ilt1), 'new_params_ilt1', '-ascii');
       save(fullfile(sub_rp_path,outfile_ilt2), 'new_params_ilt2', '-ascii');

       clear new_params_aid new_params_ilt1 new_params_ilt2
     
    

end %subject