%××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××
% create and run contrasts for 7 parameter Daw  model 
% 28-06-2022
%××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××××

clc; clear;warning off;
addpath ('S:\AG\AG-Schlagenhauf_TRR265\Daten\B01\Analysen\WP1_fMRI\Scripts\functs')
% =====================================================================
paMeta_epi            = 'S:\AG\AG-Schlagenhauf_TRR265\Daten\B01\Analysen\WP1_fMRI\';

einzelstatspath=fullfile(paMeta_epi, 'einzelstats_Daw_7param_2ndstage&reward_02thresh_masking_6movpar\');
%S:\AG\AG-Schlagenhauf_TRR265\Daten\B01\Analysen\WP1_fMRI\einzelstats_Daw_7param_2ndstage&reward_02thresh_masking_6movpar
gui=1; %open GUI

% =====================================================================
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tb={};

         N =0 ;%NstatTest-Iterator
  
           
    %%%%%%%% Contrasts  Model 1, replicate over SESSIONS %%%%%%%%%
    
    N=N+1; tb(N,:)={ N 'Tcon' 'none' 'TD_error_MF'            [0 0 1] };
    N=N+1; tb(N,:)={ N 'Tcon' 'none' 'TD_error_MB'            [0 0 0 0 1] };
    N=N+1; tb(N,:)={ N 'Tcon' 'none' 'visuell'                [1 0 0 0 0 0 0 0 1] };
  

    %============================================================
    %           CREATE SPM-STRUCT
    %============================================================
    matlabbatch={};
    matlabbatch{1}.spm.stats.con.consess=[];
    for i=1:size(tb,1)
        thiscon=tb(i,:);
        if strcmp(thiscon{2},'Tcon')
            matlabbatch{1}.spm.stats.con.consess{thiscon{1}}.tcon.name =thiscon{4};
            matlabbatch{1}.spm.stats.con.consess{thiscon{1}}.tcon.convec = thiscon{5};
         matlabbatch{1}.spm.stats.con.consess{thiscon{1}}.tcon.sessrep =thiscon{3};
        elseif strcmp(thiscon{2},'Fcon')
            matlabbatch{1}.spm.stats.con.consess{thiscon{1}}.fcon.name = thiscon{4};
            matlabbatch{1}.spm.stats.con.consess{thiscon{1}}.fcon.convec = thiscon{5};
            matlabbatch{1}.spm.stats.con.consess{thiscon{1}}.fcon.sessrep = thiscon{3};
        end
    end
    contrasts=tb; %SAVE CONTRAST
    save(fullfile( einzelstatspath  ,['contrasts' ]) ,'contrasts');
 
% delete former contrasts?
matlabbatch{1}.spm.stats.con.delete = 1 ;




% #########################################################
% LOOP OVER SUBJECTS
% #########################################################

%if j==1 %open gui only ONCE
 [subject fold2 pbnfolder]=p_getSubFolder(einzelstatspath,'',gui  ,'sep');
%end

IDS      =strrep(pbnfolder,'\',''); %keep subjectID (only)
%[fi1 fi2]=fileparts(einzelstatspath); %(nim das)split foldername (get LAST TOKEN)-->kriterium
%pbnfolder= cellfun(@(IDS) {[IDS fi2 filesep ]} , IDS ); %replace mit NIMDASS with last TOKEN (e.g pav_1x6_d1\-->pav_1x6_d3\)
%pbnfolder= {fi2}; %replace mit NIMDASS with last TOKEN (e.g pav_1x6_d1\-->pav_1x6_d3\)

 
for pb=1:length(pbnfolder) % loop pbn

    pasub=fullfile(einzelstatspath, IDS{pb}) ;%SPM.mat-destination
    matlabbatch{1}.spm.stats.con.spmmat = {[pasub '\SPM.mat']};

    % #### DELETE F/T/CON-IMAGES & delete 'SPM.xcon'-fieldname from existing SPM.mat
    delete(fullfile(pasub, [ 'spmF_*'  ]  ));
    delete(fullfile(pasub, [ 'spmT_*'  ]  ));
    delete(fullfile(pasub, [ 'con_*'  ]  ));
    load(fullfile(pasub, [ 'SPM.mat'  ]  ));%load and delete xCON-field
    SPM.xCon=struct([]);
    save(fullfile(pasub, [ 'SPM.mat'  ]  ),'SPM');
    clear SPM


    %••••• RUN SPM JOB •••••
    spm('defaults', 'FMRI');
    spm_jobman('run',matlabbatch );
    
    
end%
  
% ########################################################################
