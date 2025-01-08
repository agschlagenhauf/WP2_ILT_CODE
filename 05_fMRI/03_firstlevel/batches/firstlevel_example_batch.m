% List of open inputs
nrun = X; % enter the number of runs here
jobfile = {'C:\Users\musialm\OneDrive - Charité - Universitätsmedizin Berlin\PhD\04_B01\ILT\WP2_ILT_CODE\03_fMRI\03_firstlevel\batches\firstlevel_example_batch_job_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(0, nrun);
for crun = 1:nrun
end
spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
