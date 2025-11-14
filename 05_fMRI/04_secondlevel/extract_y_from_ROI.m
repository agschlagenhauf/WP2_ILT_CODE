%%% Extract whitened and filtered y from ROI %%%

% Open results in SPM, select cluster peak, right click, extract data,
% whitened and filtered y, current cluster, repeat for other cluster

rpe_alc_aud_left_ROI = y;
rpe_alc_aud_right_ROI = y;
rpe_alc_aud_ROI = [rpe_alc_aud_left_ROI rpe_alc_aud_right_ROI];
mean_rpe_alc_aud_roi = mean(rpe_alc_aud_ROI, 2);