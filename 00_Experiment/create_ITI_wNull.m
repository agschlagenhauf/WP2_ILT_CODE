clear all

%% for ITIs with null_events
% adapt for nr of trials
Z.Ntrials = 50;
TR = 2.09;

% ITI = ITI_final(randperm(Z.Ntrials));

Z.p_null_events = 0.3;                                          % probability of 
Z.N_null_events = Z.Ntrials*Z.p_null_events; 
pos_null        = sort(randperm(Z.Ntrials,Z.N_null_events))';
db = zeros(length(pos_null),1);

while pos_null(1) ==1 
      pos_null        = sort(randperm(Z.Ntrials,Z.N_null_events))';
end

for i = 1:length(pos_null(1:end-1))
    db(i) = pos_null(i+1)- pos_null(i);
    if db(i)<2
       pos_null(i+1)=pos_null(i+1)+1 ; 
    end
end
  ITI=exprnd(TR,Z.Ntrials,1);
  
  while any(ITI>6)==1
   ITI=exprnd(TR,Z.Ntrials,1);
  end
 
 
do_null = zeros(Z.Ntrials,1);
do_null(pos_null) = 1;
do_null=do_null+1;

ITI_wnull=do_null.*ITI; do_null=do_null-1; ITI_w_null=ITI_wnull+do_null.*2; null_pos = do_null;

save ITI_w_null.mat ITI_w_null null_pos


% %% for ISI with null_events
% 
% % adapt for nr of trials
% Z.Ntrials = 50;%length(state);
% TR = 2.09;
% 
% % ITI = ITI_final(randperm(Z.Ntrials));
% 
% Z.p_null_events = 0.3;
% Z.N_null_events = Z.Ntrials*Z.p_null_events; 
% pos_null        = sort(randperm(Z.Ntrials,Z.N_null_events))';
% db = zeros(length(pos_null),1);
% 
% while pos_null(1) ==1 
%       pos_null        = sort(randperm(Z.Ntrials,Z.N_null_events))';
% end
% 
% for i = 1:length(pos_null(1:end-1))
%     db(i) = pos_null(i+1)- pos_null(i);
%     if db(i)<2
%        pos_null(i+1)=pos_null(i+1)+1 ; 
%     end
% end
% 
%   ISI=exprnd(TR,Z.Ntrials,1);
%   figure; hist(ISI)
%   while any(ISI>4)==1
%    ISI=exprnd(TR,Z.Ntrials,1);
%   end
%  
%  
% do_null = ones(Z.Ntrials,1);
% % % do_null(pos_null) = 1;
% % % do_null=do_null+1;
% 
% ISI_wnull=do_null.*ISI; do_null=do_null-1; ISI_w_null=ISI_wnull+do_null.*2; null_pos = do_null;
% figure; hist(ISI_wnull)
% %save ISI_w_null.mat ISI_w_null null_pos
