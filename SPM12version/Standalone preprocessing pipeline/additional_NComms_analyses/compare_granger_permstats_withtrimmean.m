datapathstem = '/imaging/tc02/vespa/preprocess/SPM12_fullpipeline_fixedICA/extractedsources/';

load([datapathstem 'groups.mat']);
datapathstem = '/imaging/tc02/vespa/preprocess/SPM12_fullpipeline_fixedICA/extractedsources_tf/'; %For spoken baseline
%datapathstem = '/imaging/tc02/vespa/preprocess/SPM12_fullpipeline_fixedICA/extractedsources_tf_newinversions_newbaseline/'; %For written baseline

averagesubtracted = 1;
highfreq = 1;
timewins = [32 944];
%timewins = [32 296; 300 564; 636 900];

%analysis_type = 'Granger';
analysis_type = 'icoh';

switch(analysis_type)
    case 'Granger'
        
    case 'icoh'
        datapathstem = [datapathstem(1:end-1) '_icoh/'];
end

addpath('/imaging/tc02/toolboxes/rsatoobox/Engines/')

% datapathstem = '/imaging/tc02/vespa/preprocess/SPM12_fullpipeline_fixedICA/extractedsources_tf_null/'; %For null baseline
%
% start_times = -968;
% end_times = -56;

for t = 1:size(timewins)
    
    start_times = timewins(t,1);
    end_times = timewins(t,2);
    
    all_granger_data = zeros(2,2,1,35,6,length(group));
    all_congruency_contrasts = zeros(2,2,1,35,length(group));
    all_absolute_congruency_contrasts = zeros(2,2,1,35,length(group));
    all_clarity_contrasts = zeros(2,2,1,35,length(group));
    all_absolute_clarity_contrasts = zeros(2,2,1,35,length(group));
    all_random_granger_data = zeros(2,2,1,35,6,100,length(group));
    all_random_congruency_contrasts = zeros(2,2,1,35,100,length(group));
    all_random_clarity_contrasts = zeros(2,2,1,35,100,length(group));
    all_absolute_random_congruency_contrasts = zeros(2,2,1,35,100,length(group));
    all_absolute_random_clarity_contrasts = zeros(2,2,1,35,100,length(group));
    all_interaction_contrasts = zeros(2,2,1,35,length(group));
    all_absolute_interaction_contrasts = zeros(2,2,1,35,length(group));
    all_random_interaction_contrasts = zeros(2,2,1,35,100,length(group));
    all_absolute_random_interaction_contrasts = zeros(2,2,1,35,100,length(group));
    all_controls_granger_data = [];
    all_patients_granger_data = [];
    all_controls_congruency_contrasts = [];
    all_patients_congruency_contrasts = [];
    all_controls_clarity_contrasts = [];
    all_patients_clarity_contrasts = [];
    
    demeaned_all_granger_data = zeros(2,2,1,35,6,length(group));
    demeaned_all_congruency_contrasts = zeros(2,2,1,35,length(group));
    demeaned_all_clarity_contrasts = zeros(2,2,1,35,length(group));
    demeaned_all_controls_granger_data = [];
    demeaned_all_patients_granger_data = [];
    demeaned_all_controls_congruency_contrasts = [];
    demeaned_all_patients_congruency_contrasts = [];
    demeaned_all_controls_clarity_contrasts = [];
    demeaned_all_patients_clarity_contrasts = [];
    all_random_controls_granger_data = [];
    all_random_controls_congruency_contrasts = [];
    all_random_controls_clarity_contrasts = [];
    all_random_patients_granger_data = [];
    all_random_patients_congruency_contrasts = [];
    all_random_patients_clarity_contrasts = [];
    
    for s = 1:length(group)
        %load([datapathstem 's' num2str(s) '_evoked_grangerdata_' num2str(start_times) '_' num2str(end_times) '_overall']); %For evoked data
        if averagesubtracted == 1
            if highfreq == 1
                load([datapathstem 's' num2str(s) '_grangerdata_highfreq_' num2str(start_times) '_' num2str(end_times) '_overall']); %For timeseries data
            else
                load([datapathstem 's' num2str(s) '_grangerdata_averagesubtracted_' num2str(start_times) '_' num2str(end_times) '_overall']); %For timeseries data
            end
        else
            if highfreq == 1
                error('I havent done this analysis (highfreq and without subtracting average')
            else
                load([datapathstem 's' num2str(s) '_grangerdata_' num2str(start_times) '_' num2str(end_times) '_overall']); %For timeseries data
            end
        end
        %     if rejecteeg{s} == 1 %Biases analysis
        %         continue
        %     end
        
        %Trim final frequency (or all higher frequencies) - seems artefactually high ?filtering
        foi = foi(1:35);
        granger_data = granger_data(:,:,:,1:35,:,:);
        
        %     foi = foi(1:end-1);
        %     granger_data = granger_data(:,:,:,1:end-1,:,:);
        
        
        all_granger_data(:,:,:,:,:,s) = granger_data(:,:,:,:,:,201);
        all_random_granger_data(:,:,:,:,:,:,s) = granger_data(:,:,:,:,:,101:200); %Random permutations by trial
        demeaned_all_granger_data(:,:,:,:,:,s) = granger_data(:,:,:,:,:,201) / mean(mean(mean(nanmean(granger_data(:,:,:,:,:,201)))));
        all_congruency_contrasts(:,:,:,:,s) = mean((granger_data(:,:,:,:,[1,3,5],201)-granger_data(:,:,:,:,[2,4,6],201))/3,5);
        all_absolute_congruency_contrasts(:,:,:,:,s) = mean((abs(granger_data(:,:,:,:,[1,3,5],201))-abs(granger_data(:,:,:,:,[2,4,6],201)))/3,5);
        all_random_congruency_contrasts(:,:,:,:,:,s) = mean((granger_data(:,:,:,:,[1,3,5],1:100)-granger_data(:,:,:,:,[2,4,6],1:100))/3,5);
        all_absolute_random_congruency_contrasts(:,:,:,:,:,s) = mean((abs(granger_data(:,:,:,:,[1,3,5],1:100))-abs(granger_data(:,:,:,:,[2,4,6],1:100)))/3,5);
        demeaned_all_congruency_contrasts(:,:,:,:,s) = mean((granger_data(:,:,:,:,[1,3,5],201)-granger_data(:,:,:,:,[2,4,6],201))/3,5) / mean(mean(mean(nanmean(granger_data(:,:,:,:,:,201)))));
        all_clarity_contrasts(:,:,:,:,s) = mean((granger_data(:,:,:,:,[5,6],201)-granger_data(:,:,:,:,[1,2],201))/2,5);
        all_absolute_clarity_contrasts(:,:,:,:,s) = mean((abs(granger_data(:,:,:,:,[5,6],201))-abs(granger_data(:,:,:,:,[1,2],201)))/2,5);
        demeaned_all_clarity_contrasts(:,:,:,:,s) = mean((granger_data(:,:,:,:,[5,6],201)-granger_data(:,:,:,:,[1,2],201))/2,5) / mean(mean(mean(nanmean(granger_data(:,:,:,:,:,201)))));
        all_random_clarity_contrasts(:,:,:,:,:,s) = mean((granger_data(:,:,:,:,[5,6],1:100)-granger_data(:,:,:,:,[1,2],1:100))/3,5);
        all_absolute_random_clarity_contrasts(:,:,:,:,:,s) = mean((abs(granger_data(:,:,:,:,[1,3,5],1:100))-abs(granger_data(:,:,:,:,[2,4,6],1:100)))/3,5);
        all_interaction_contrasts(:,:,:,:,s) = mean((granger_data(:,:,:,:,[2,5],201)-granger_data(:,:,:,:,[1,6],201))/3,5); %Match4-MisMatch4+MisMatch16-Match16
        all_absolute_interaction_contrasts(:,:,:,:,s) = mean((abs(granger_data(:,:,:,:,[2,5],201))-abs(granger_data(:,:,:,:,[1,6],201)))/3,5);
        all_random_interaction_contrasts(:,:,:,:,:,s) = mean((granger_data(:,:,:,:,[2,5],1:100)-granger_data(:,:,:,:,[1,6],1:100))/3,5);
        all_absolute_random_interaction_contrasts(:,:,:,:,:,s) = mean((abs(granger_data(:,:,:,:,[2,5],1:100))-abs(granger_data(:,:,:,:,[1,6],1:100)))/3,5);
        if group(s) == 1
            all_controls_granger_data(:,:,:,:,:,end+1) = granger_data(:,:,:,:,:,201);
            all_random_controls_granger_data(:,:,:,:,:,:,end+1) = granger_data(:,:,:,:,:,101:200); %Random permutations by trial
            demeaned_all_controls_granger_data(:,:,:,:,:,end+1) = granger_data(:,:,:,:,:,201)/ mean(mean(mean(nanmean(granger_data(:,:,:,:,:,201)))));
            all_controls_congruency_contrasts(:,:,:,:,end+1) = mean((granger_data(:,:,:,:,[1,3,5],201)-granger_data(:,:,:,:,[2,4,6],201))/3,5);
            all_random_controls_congruency_contrasts(:,:,:,:,:,end+1) = mean((granger_data(:,:,:,:,[1,3,5],1:100)-granger_data(:,:,:,:,[2,4,6],1:100))/3,5);
            demeaned_all_controls_congruency_contrasts(:,:,:,:,end+1) = mean((granger_data(:,:,:,:,[1,3,5],201)-granger_data(:,:,:,:,[2,4,6],201))/3,5)/ mean(mean(mean(nanmean(granger_data(:,:,:,:,:,201)))));
            all_controls_clarity_contrasts(:,:,:,:,end+1) = mean((granger_data(:,:,:,:,[5,6],201)-granger_data(:,:,:,:,[1,2],201))/2,5);
            all_random_controls_clarity_contrasts(:,:,:,:,:,end+1) = mean((granger_data(:,:,:,:,[5,6],1:100)-granger_data(:,:,:,:,[1,2],1:100))/3,5);
            demeaned_all_controls_clarity_contrasts(:,:,:,:,end+1) = mean((granger_data(:,:,:,:,[5,6],201)-granger_data(:,:,:,:,[1,2],201))/2,5)/ mean(mean(mean(nanmean(granger_data(:,:,:,:,:,201)))));
        elseif group(s) == 2
            all_patients_granger_data(:,:,:,:,:,end+1) = granger_data(:,:,:,:,:,201);
            all_random_patients_granger_data(:,:,:,:,:,:,end+1) = granger_data(:,:,:,:,:,101:200); %Random permutations by trial
            demeaned_all_patients_granger_data(:,:,:,:,:,end+1) = granger_data(:,:,:,:,:,201)/ mean(mean(mean(nanmean(granger_data(:,:,:,:,:,201)))));
            all_patients_congruency_contrasts(:,:,:,:,end+1) = mean((granger_data(:,:,:,:,[1,3,5],201)-granger_data(:,:,:,:,[2,4,6],201))/3,5);
            all_random_patients_congruency_contrasts(:,:,:,:,:,end+1) = mean((granger_data(:,:,:,:,[1,3,5],1:100)-granger_data(:,:,:,:,[2,4,6],1:100))/3,5);
            demeaned_all_patients_congruency_contrasts(:,:,:,:,end+1) = mean((granger_data(:,:,:,:,[1,3,5],201)-granger_data(:,:,:,:,[2,4,6],201))/3,5)/ mean(mean(mean(nanmean(granger_data(:,:,:,:,:,201)))));
            all_patients_clarity_contrasts(:,:,:,:,end+1) = mean((granger_data(:,:,:,:,[5,6],201)-granger_data(:,:,:,:,[1,2],201))/2,5);
            all_random_patients_clarity_contrasts(:,:,:,:,:,end+1) = mean((granger_data(:,:,:,:,[5,6],1:100)-granger_data(:,:,:,:,[1,2],1:100))/3,5);
            demeaned_all_patients_clarity_contrasts(:,:,:,:,end+1) = mean((granger_data(:,:,:,:,[5,6],201)-granger_data(:,:,:,:,[1,2],201))/2,5)/ mean(mean(mean(nanmean(granger_data(:,:,:,:,:,201)))));
        end
        
    end
    
    switch(analysis_type)
        case 'Granger'
            
            figure
            plot(foi,squeeze(mean(mean(all_granger_data(2,1,:,:,:,:),5),6)),'g')
            hold on
            plot(foi,squeeze(mean(mean(all_granger_data(1,2,:,:,:,:),5),6)),'b')
            title(['All ' analysis_type ' time ' num2str(start_times) '-' num2str(end_times)])
            legend({'temp-front','front-temp'})
            for i = 1:35 %Compare across group permutation
                p_tf(i) = 1-relRankIn_includeValue_lowerBound(squeeze(mean(mean(all_random_granger_data(2,1,:,i,:,:,:),5),7)),squeeze(mean(mean(all_granger_data(2,1,:,i,:,:),5),6)))
                p_ft(i) = 1-relRankIn_includeValue_lowerBound(squeeze(mean(mean(all_random_granger_data(1,2,:,i,:,:,:),5),7)),squeeze(mean(mean(all_granger_data(1,2,:,i,:,:),5),6)))
                if p_tf(i)<=0.05
                    plot(foi(i),0,'g*')
                end
                if p_ft(i)<=0.05
                    plot(foi(i),0,'bx')
                end
            end
            
            figure
            plot(foi,squeeze(trimmean(mean(all_granger_data(2,1,:,:,:,:),5),25,6)),'g')
            hold on
            plot(foi,squeeze(trimmean(mean(all_granger_data(1,2,:,:,:,:),5),25,6)),'b')
            title(['All trimmed mean ' analysis_type ' time ' num2str(start_times) '-' num2str(end_times)])
            legend({'temp-front','front-temp'})
            for i = 1:35 %Compare across group permutation
                p_tf(i) = 1-relRankIn_includeValue_lowerBound(squeeze(trimmean(mean(all_random_granger_data(2,1,:,i,:,:,:),5),25,7)),squeeze(trimmean(mean(all_granger_data(2,1,:,i,:,:),5),25,6)))
                p_ft(i) = 1-relRankIn_includeValue_lowerBound(squeeze(trimmean(mean(all_random_granger_data(1,2,:,i,:,:,:),5),25,7)),squeeze(trimmean(mean(all_granger_data(1,2,:,i,:,:),5),25,6)))
                if p_tf(i)<=0.05
                    plot(foi(i),0,'g*')
                end
                if p_ft(i)<=0.05
                    plot(foi(i),0,'bx')
                end
            end
            
            figure
            plot(foi,squeeze(mean(mean(demeaned_all_granger_data(2,1,:,:,:,:),5),6)),'g')
            hold on
            plot(foi,squeeze(mean(mean(demeaned_all_granger_data(1,2,:,:,:,:),5),6)),'b')
            title(['All demeaned ' analysis_type ' time ' num2str(start_times) '-' num2str(end_times)])
            legend({'temp-front','front-temp'}) %Not yet clear how to do stats on this - XXX
            
            figure
            hold on
            plot(foi,squeeze(mean(mean(all_controls_granger_data(2,1,:,:,:,:),5),6)),'g:')
            plot(foi,squeeze(mean(mean(all_patients_granger_data(2,1,:,:,:,:),5),6)),'g--')
            plot(foi,squeeze(mean(mean(all_controls_granger_data(1,2,:,:,:,:),5),6)),'b:')
            plot(foi,squeeze(mean(mean(all_patients_granger_data(1,2,:,:,:,:),5),6)),'b--')
            legend({'temp-front control','temp-front patient','front-temp control','front-temp patient'})
            title(['By group ' analysis_type ' time ' num2str(start_times) '-' num2str(end_times)])
            for i = 1:35 %Rough initial parametric stats - better to use permutation
                [h_tf(i) p_tf(i)] = ttest2(all_controls_granger_data(2,1,:,i,:),all_patients_granger_data(2,1,:,i,:));
                [h_ft(i) p_ft(i)] = ttest2(all_controls_granger_data(1,2,:,i,:),all_patients_granger_data(1,2,:,i,:));
                if h_tf(i) == 1
                    plot(foi(i),0,'g*')
                end
                if h_ft(i) == 1
                    plot(foi(i),0,'bx')
                end
            end
            
            figure
            hold on
            plot(foi,squeeze(trimmean(mean(all_controls_granger_data(2,1,:,:,:,:),5),25,6)),'g:')
            plot(foi,squeeze(trimmean(mean(all_patients_granger_data(2,1,:,:,:,:),5),25,6)),'g--')
            plot(foi,squeeze(trimmean(mean(all_controls_granger_data(1,2,:,:,:,:),5),25,6)),'b:')
            plot(foi,squeeze(trimmean(mean(all_patients_granger_data(1,2,:,:,:,:),5),25,6)),'b--')
            legend({'temp-front control','temp-front patient','front-temp control','front-temp patient'})
            title(['By group trimmed mean ' analysis_type ' time ' num2str(start_times) '-' num2str(end_times)])
            for i = 1:35 %Rough initial parametric stats - better to use permutation
                [h_tf(i) p_tf(i)] = ttest2(all_controls_granger_data(2,1,:,i,:),all_patients_granger_data(2,1,:,i,:));
                [h_ft(i) p_ft(i)] = ttest2(all_controls_granger_data(1,2,:,i,:),all_patients_granger_data(1,2,:,i,:));
                if h_tf(i) == 1
                    plot(foi(i),0,'g*')
                end
                if h_ft(i) == 1
                    plot(foi(i),0,'bx')
                end
            end
            
            config = figure;
            patfig = figure;
            this_con = 0;
            this_pat = 0;
            
            for s = 1:length(group)
                if group(s) == 1
                    this_con = this_con+1;
                    figure(config);
                    h = subplot(4,3,this_con);
                    plot(foi,squeeze(mean(all_granger_data(2,1,:,:,:,s),5)),'g')
                    hold on
                    plot(foi,squeeze(mean(all_granger_data(1,2,:,:,:,s),5)),'b')
                    for i = 1:35 %Compare within subj permutation
                        p_tf(i) = 1-relRankIn_includeValue_lowerBound(squeeze(mean(all_random_granger_data(2,1,:,i,:,:,s),5)),squeeze(mean(all_granger_data(2,1,:,i,:,s),5)));
                        p_ft(i) = 1-relRankIn_includeValue_lowerBound(squeeze(mean(all_random_granger_data(1,2,:,i,:,:,s),5)),squeeze(mean(all_granger_data(1,2,:,i,:,s),5)));
                        if p_tf(i)<=0.05
                            plot(foi(i),0,'g*')
                        end
                        if p_ft(i)<=0.05
                            plot(foi(i),0,'bx')
                        end
                    end
                    
                elseif group(s) == 2
                    this_pat = this_pat+1;
                    figure(patfig);
                    h = subplot(4,3,this_pat);
                    plot(foi,squeeze(mean(all_granger_data(2,1,:,:,:,s),5)),'g')
                    hold on
                    plot(foi,squeeze(mean(all_granger_data(1,2,:,:,:,s),5)),'b')
                    for i = 1:35 %Compare within subj permutation
                        p_tf(i) = 1-relRankIn_includeValue_lowerBound(squeeze(mean(all_random_granger_data(2,1,:,i,:,:,s),5)),squeeze(mean(all_granger_data(2,1,:,i,:,s),5)));
                        p_ft(i) = 1-relRankIn_includeValue_lowerBound(squeeze(mean(all_random_granger_data(1,2,:,i,:,:,s),5)),squeeze(mean(all_granger_data(1,2,:,i,:,s),5)));
                        if p_tf(i)<=0.05
                            plot(foi(i),0,'g*')
                        end
                        if p_ft(i)<=0.05
                            plot(foi(i),0,'bx')
                        end
                    end
                end
            end
            figure(config)
            title(['Controls ' analysis_type ' time ' num2str(start_times) '-' num2str(end_times)])
            figure(patfig)
            title(['Patients ' analysis_type ' time ' num2str(start_times) '-' num2str(end_times)])
            
            
            figure
            plot(foi,squeeze(mean(all_congruency_contrasts(2,1,:,:,:),5)),'g')
            hold on
            plot(foi,squeeze(mean(all_congruency_contrasts(1,2,:,:,:),5)),'b')
            title(['All MisMatch-Match ' analysis_type ' time ' num2str(start_times) '-' num2str(end_times)])
            legend({'temp-front','front-temp'})
            for i = 1:35 %Compare across group permutation
                p_tf(i) = 1-relRankIn_includeValue_lowerBound(squeeze(mean(all_random_congruency_contrasts(2,1,:,i,:,:),6)),squeeze(mean(all_congruency_contrasts(2,1,:,i,:),5)));
                p_ft(i) = 1-relRankIn_includeValue_lowerBound(squeeze(mean(all_random_congruency_contrasts(1,2,:,i,:,:),6)),squeeze(mean(all_congruency_contrasts(2,1,:,i,:),5)));
                if p_tf(i)<=0.05
                    plot(foi(i),0,'g*')
                end
                if p_ft(i)<=0.05
                    plot(foi(i),0,'bx')
                end
            end
            
            figure
            plot(foi,squeeze(trimmean(all_congruency_contrasts(2,1,:,:,:),25,5)),'g')
            hold on
            plot(foi,squeeze(trimmean(all_congruency_contrasts(1,2,:,:,:),25,5)),'b')
            title(['All trimmed MisMatch-Match ' analysis_type ' time ' num2str(start_times) '-' num2str(end_times)])
            legend({'temp-front','front-temp'})
            for i = 1:35 %Compare across group permutation
                p_tf(i) = 1-relRankIn_includeValue_lowerBound(squeeze(trimmean(all_random_congruency_contrasts(2,1,:,i,:,:),25,6)),squeeze(trimmean(all_congruency_contrasts(2,1,:,i,:),25,5)));
                p_ft(i) = 1-relRankIn_includeValue_lowerBound(squeeze(trimmean(all_random_congruency_contrasts(1,2,:,i,:,:),25,6)),squeeze(trimmean(all_congruency_contrasts(2,1,:,i,:),25,5)));
                if p_tf(i)<=0.05
                    plot(foi(i),0,'g*')
                end
                if p_ft(i)<=0.05
                    plot(foi(i),0,'bx')
                end
            end
            
            figure
            plot(foi,squeeze(mean(all_clarity_contrasts(2,1,:,:,:),5)),'g')
            hold on
            plot(foi,squeeze(mean(all_clarity_contrasts(1,2,:,:,:),5)),'b')
            title(['All Clear-Unclear ' analysis_type ' time ' num2str(start_times) '-' num2str(end_times)])
            legend({'temp-front','front-temp'})
            for i = 1:35 %Compare across group permutation
                p_tf(i) = 1-relRankIn_includeValue_lowerBound(squeeze(mean(all_random_clarity_contrasts(2,1,:,i,:,:),6)),squeeze(mean(all_clarity_contrasts(2,1,:,i,:),5)));
                p_ft(i) = 1-relRankIn_includeValue_lowerBound(squeeze(mean(all_random_clarity_contrasts(1,2,:,i,:,:),6)),squeeze(mean(all_clarity_contrasts(2,1,:,i,:),5)));
                if p_tf(i)<=0.05
                    plot(foi(i),0,'g*')
                end
                if p_ft(i)<=0.05
                    plot(foi(i),0,'bx')
                end
            end
            
            figure
            plot(foi,squeeze(trimmean(all_clarity_contrasts(2,1,:,:,:),25,5)),'g')
            hold on
            plot(foi,squeeze(trimmean(all_clarity_contrasts(1,2,:,:,:),25,5)),'b')
            title(['All trimmed Clear-Unclear ' analysis_type ' time ' num2str(start_times) '-' num2str(end_times)])
            legend({'temp-front','front-temp'})
            for i = 1:35 %Compare across group permutation
                p_tf(i) = 1-relRankIn_includeValue_lowerBound(squeeze(trimmean(all_random_clarity_contrasts(2,1,:,i,:,:),25,6)),squeeze(trimmean(all_clarity_contrasts(2,1,:,i,:),25,5)));
                p_ft(i) = 1-relRankIn_includeValue_lowerBound(squeeze(trimmean(all_random_clarity_contrasts(1,2,:,i,:,:),25,6)),squeeze(trimmean(all_clarity_contrasts(2,1,:,i,:),25,5)));
                if p_tf(i)<=0.05
                    plot(foi(i),0,'g*')
                end
                if p_ft(i)<=0.05
                    plot(foi(i),0,'bx')
                end
            end
            
            
            
        case 'icoh'
            
            figure
            plot(foi,squeeze(mean(mean(abs(all_granger_data(2,1,:,:,:,:)),5),6)),'g')
            hold on
            plot(foi,squeeze(mean(mean(abs(all_granger_data(1,2,:,:,:,:)),5),6)),'b')
            title(['All abs ' analysis_type ' time ' num2str(start_times) '-' num2str(end_times)])
            legend({'temp-front','front-temp'})
            for i = 1:35 %Compare across group permutation
                p_tf(i) = 1-relRankIn_includeValue_lowerBound(squeeze(mean(mean(abs(all_random_granger_data(2,1,:,i,:,:,:)),5),7)),squeeze(mean(mean(abs(all_granger_data(2,1,:,i,:,:)),5),6)))
                p_ft(i) = 1-relRankIn_includeValue_lowerBound(squeeze(mean(mean(abs(all_random_granger_data(1,2,:,i,:,:,:)),5),7)),squeeze(mean(mean(abs(all_granger_data(1,2,:,i,:,:)),5),6)))
                if p_tf(i)<=0.05
                    plot(foi(i),0,'g*')
                end
                if p_ft(i)<=0.05
                    plot(foi(i),0,'bx')
                end
            end
            
            figure
            plot(foi,squeeze(trimmean(mean(abs(all_granger_data(2,1,:,:,:,:)),5),25,6)),'g')
            hold on
            plot(foi,squeeze(trimmean(mean(abs(all_granger_data(1,2,:,:,:,:)),5),25,6)),'b')
            title(['All trimmed mean ' analysis_type ' time ' num2str(start_times) '-' num2str(end_times)])
            legend({'temp-front','front-temp'})
            for i = 1:35 %Compare across group permutation
                p_tf(i) = 1-relRankIn_includeValue_lowerBound(squeeze(trimmean(mean(abs(all_random_granger_data(2,1,:,i,:,:,:)),5),25,7)),squeeze(trimmean(mean(abs(all_granger_data(2,1,:,i,:,:)),5),25,6)))
                p_ft(i) = 1-relRankIn_includeValue_lowerBound(squeeze(trimmean(mean(abs(all_random_granger_data(1,2,:,i,:,:,:)),5),25,7)),squeeze(trimmean(mean(abs(all_granger_data(1,2,:,i,:,:)),5),25,6)))
                if p_tf(i)<=0.05
                    plot(foi(i),0,'g*')
                end
                if p_ft(i)<=0.05
                    plot(foi(i),0,'bx')
                end
            end
            
            figure
            plot(foi,squeeze(mean(mean(abs(demeaned_all_granger_data(2,1,:,:,:,:)),5),6)),'g')
            hold on
            plot(foi,squeeze(mean(mean(abs(demeaned_all_granger_data(1,2,:,:,:,:)),5),6)),'b')
            title(['All demeaned ' analysis_type ' time ' num2str(start_times) '-' num2str(end_times)])
            legend({'temp-front','front-temp'}) %Not yet clear how to do stats on this - XXX
            
            figure
            hold on
            plot(foi,squeeze(mean(mean(abs(all_controls_granger_data(2,1,:,:,:,:)),5),6)),'g:')
            plot(foi,squeeze(mean(mean(abs(all_patients_granger_data(2,1,:,:,:,:)),5),6)),'g--')
            plot(foi,squeeze(mean(mean(abs(all_controls_granger_data(1,2,:,:,:,:)),5),6)),'b:')
            plot(foi,squeeze(mean(mean(abs(all_patients_granger_data(1,2,:,:,:,:)),5),6)),'b--')
            legend({'temp-front control','temp-front patient','front-temp control','front-temp patient'})
            title(['By group ' analysis_type ' time ' num2str(start_times) '-' num2str(end_times)])
            for i = 1:35 %Rough initial parametric stats - better to use permutation
                [h_tf(i) p_tf(i)] = ttest2(abs(all_controls_granger_data(2,1,:,i,:)),abs(all_patients_granger_data(2,1,:,i,:)));
                [h_ft(i) p_ft(i)] = ttest2(abs(all_controls_granger_data(1,2,:,i,:)),abs(all_patients_granger_data(1,2,:,i,:)));
                if h_tf(i) == 1
                    plot(foi(i),0,'g*')
                end
                if h_ft(i) == 1
                    plot(foi(i),0,'bx')
                end
            end
            
            figure
            hold on
            plot(foi,squeeze(trimmean(mean(abs(all_controls_granger_data(2,1,:,:,:,:)),5),25,6)),'g:')
            plot(foi,squeeze(trimmean(mean(abs(all_patients_granger_data(2,1,:,:,:,:)),5),25,6)),'g--')
            plot(foi,squeeze(trimmean(mean(abs(all_controls_granger_data(1,2,:,:,:,:)),5),25,6)),'b:')
            plot(foi,squeeze(trimmean(mean(abs(all_patients_granger_data(1,2,:,:,:,:)),5),25,6)),'b--')
            legend({'temp-front control','temp-front patient','front-temp control','front-temp patient'})
            title(['By group trimmed mean ' analysis_type ' time ' num2str(start_times) '-' num2str(end_times)])
            for i = 1:35 %Rough initial parametric stats - better to use permutation
                [h_tf(i) p_tf(i)] = ttest2(abs(all_controls_granger_data(2,1,:,i,:)),abs(all_patients_granger_data(2,1,:,i,:)));
                [h_ft(i) p_ft(i)] = ttest2(abs(all_controls_granger_data(1,2,:,i,:)),abs(all_patients_granger_data(1,2,:,i,:)));
                if h_tf(i) == 1
                    plot(foi(i),0,'g*')
                end
                if h_ft(i) == 1
                    plot(foi(i),0,'bx')
                end
            end
            
            config = figure;
            patfig = figure;
            this_con = 0;
            this_pat = 0;
            
            for s = 1:length(group)
                if group(s) == 1
                    this_con = this_con+1;
                    figure(config);
                    h = subplot(4,3,this_con);
                    plot(foi,squeeze(mean(abs(all_granger_data(2,1,:,:,:,s)),5)),'g')
                    hold on
                    plot(foi,squeeze(mean(abs(all_granger_data(1,2,:,:,:,s)),5)),'b')
                    for i = 1:35 %Compare within subj permutation
                        p_tf(i) = 1-relRankIn_includeValue_lowerBound(squeeze(mean(abs(all_random_granger_data(2,1,:,i,:,:,s)),5)),squeeze(mean(abs(all_granger_data(2,1,:,i,:,s)),5)));
                        p_ft(i) = 1-relRankIn_includeValue_lowerBound(squeeze(mean(abs(all_random_granger_data(1,2,:,i,:,:,s)),5)),squeeze(mean(abs(all_granger_data(1,2,:,i,:,s)),5)));
                        if p_tf(i)<=0.05
                            plot(foi(i),0,'g*')
                        end
                        if p_ft(i)<=0.05
                            plot(foi(i),0,'bx')
                        end
                    end
                    
                elseif group(s) == 2
                    this_pat = this_pat+1;
                    figure(patfig);
                    h = subplot(4,3,this_pat);
                    plot(foi,squeeze(mean(abs(all_granger_data(2,1,:,:,:,s)),5)),'g')
                    hold on
                    plot(foi,squeeze(mean(abs(all_granger_data(1,2,:,:,:,s)),5)),'b')
                    for i = 1:35 %Compare within subj permutation
                        p_tf(i) = 1-relRankIn_includeValue_lowerBound(squeeze(mean(abs(all_random_granger_data(2,1,:,i,:,:,s)),5)),squeeze(mean(abs(all_granger_data(2,1,:,i,:,s)),5)));
                        p_ft(i) = 1-relRankIn_includeValue_lowerBound(squeeze(mean(abs(all_random_granger_data(1,2,:,i,:,:,s)),5)),squeeze(mean(abs(all_granger_data(1,2,:,i,:,s)),5)));
                        if p_tf(i)<=0.05
                            plot(foi(i),0,'g*')
                        end
                        if p_ft(i)<=0.05
                            plot(foi(i),0,'bx')
                        end
                    end
                end
            end
            figure(config)
            title(['Controls ' analysis_type ' time ' num2str(start_times) '-' num2str(end_times)])
            figure(patfig)
            title(['Patients ' analysis_type ' time ' num2str(start_times) '-' num2str(end_times)])
            
            
            figure
            plot(foi,squeeze(mean(all_absolute_congruency_contrasts(2,1,:,:,:),5)),'g')
            hold on
            plot(foi,squeeze(mean(all_absolute_congruency_contrasts(1,2,:,:,:),5)),'b')
            title(['All MisMatch-Match ' analysis_type ' time ' num2str(start_times) '-' num2str(end_times)])
            legend({'temp-front','front-temp'})
            for i = 1:35 %Compare across group permutation
                p_tf(i) = 1-relRankIn_includeValue_lowerBound(squeeze(mean(all_absolute_random_congruency_contrasts(2,1,:,i,:,:),6)),squeeze(mean(all_absolute_congruency_contrasts(2,1,:,i,:),5)));
                p_ft(i) = 1-relRankIn_includeValue_lowerBound(squeeze(mean(all_absolute_random_congruency_contrasts(1,2,:,i,:,:),6)),squeeze(mean(all_absolute_congruency_contrasts(2,1,:,i,:),5)));
                if p_tf(i)<=0.05
                    plot(foi(i),0,'g*')
                end
                if p_ft(i)<=0.05
                    plot(foi(i),0,'bx')
                end
            end
            
            figure
            plot(foi,squeeze(trimmean(all_absolute_congruency_contrasts(2,1,:,:,:),25,5)),'g')
            hold on
            plot(foi,squeeze(trimmean(all_absolute_congruency_contrasts(1,2,:,:,:),25,5)),'b')
            title(['All trimmed MisMatch-Match ' analysis_type ' time ' num2str(start_times) '-' num2str(end_times)])
            legend({'temp-front','front-temp'})
            for i = 1:35 %Compare across group permutation
                p_tf(i) = 1-relRankIn_includeValue_lowerBound(squeeze(trimmean(all_absolute_random_congruency_contrasts(2,1,:,i,:,:),25,6)),squeeze(trimmean(all_absolute_congruency_contrasts(2,1,:,i,:),25,5)));
                p_ft(i) = 1-relRankIn_includeValue_lowerBound(squeeze(trimmean(all_absolute_random_congruency_contrasts(1,2,:,i,:,:),25,6)),squeeze(trimmean(all_absolute_congruency_contrasts(2,1,:,i,:),25,5)));
                if p_tf(i)<=0.05
                    plot(foi(i),0,'g*')
                end
                if p_ft(i)<=0.05
                    plot(foi(i),0,'bx')
                end
            end
            
            figure
            plot(foi,squeeze(mean(all_absolute_clarity_contrasts(2,1,:,:,:),5)),'g')
            hold on
            plot(foi,squeeze(mean(all_absolute_clarity_contrasts(1,2,:,:,:),5)),'b')
            title(['All Clear-Unclear ' analysis_type ' time ' num2str(start_times) '-' num2str(end_times)])
            legend({'temp-front','front-temp'})
            for i = 1:35 %Compare across group permutation
                p_tf(i) = 1-relRankIn_includeValue_lowerBound(squeeze(mean(all_absolute_random_clarity_contrasts(2,1,:,i,:,:),6)),squeeze(mean(all_absolute_clarity_contrasts(2,1,:,i,:),5)));
                p_ft(i) = 1-relRankIn_includeValue_lowerBound(squeeze(mean(all_absolute_random_clarity_contrasts(1,2,:,i,:,:),6)),squeeze(mean(all_absolute_clarity_contrasts(2,1,:,i,:),5)));
                if p_tf(i)<=0.05
                    plot(foi(i),0,'g*')
                end
                if p_ft(i)<=0.05
                    plot(foi(i),0,'bx')
                end
            end
            
            figure
            plot(foi,squeeze(trimmean(all_absolute_clarity_contrasts(2,1,:,:,:),25,5)),'g')
            hold on
            plot(foi,squeeze(trimmean(all_absolute_clarity_contrasts(1,2,:,:,:),25,5)),'b')
            title(['All trimmed Clear-Unclear ' analysis_type ' time ' num2str(start_times) '-' num2str(end_times)])
            legend({'temp-front','front-temp'})
            for i = 1:35 %Compare across group permutation
                p_tf(i) = 1-relRankIn_includeValue_lowerBound(squeeze(trimmean(all_absolute_random_clarity_contrasts(2,1,:,i,:,:),25,6)),squeeze(trimmean(all_absolute_clarity_contrasts(2,1,:,i,:),25,5)));
                p_ft(i) = 1-relRankIn_includeValue_lowerBound(squeeze(trimmean(all_absolute_random_clarity_contrasts(1,2,:,i,:,:),25,6)),squeeze(trimmean(all_absolute_clarity_contrasts(2,1,:,i,:),25,5)));
                if p_tf(i)<=0.05
                    plot(foi(i),0,'g*')
                end
                if p_ft(i)<=0.05
                    plot(foi(i),0,'bx')
                end
            end
            
            figure
            plot(foi,squeeze(mean(all_absolute_interaction_contrasts(2,1,:,:,:),5)),'g')
            hold on
            plot(foi,squeeze(mean(all_absolute_interaction_contrasts(1,2,:,:,:),5)),'b')
            title(['All Interaction ' analysis_type ' time ' num2str(start_times) '-' num2str(end_times)])
            legend({'temp-front','front-temp'})
            for i = 1:35 %Compare across group permutation
                p_tf(i) = 1-relRankIn_includeValue_lowerBound(squeeze(mean(all_absolute_random_interaction_contrasts(2,1,:,i,:,:),6)),squeeze(mean(all_absolute_interaction_contrasts(2,1,:,i,:),5)));
                p_ft(i) = 1-relRankIn_includeValue_lowerBound(squeeze(mean(all_absolute_random_interaction_contrasts(1,2,:,i,:,:),6)),squeeze(mean(all_absolute_interaction_contrasts(2,1,:,i,:),5)));
                if p_tf(i)<=0.05
                    plot(foi(i),0,'g*')
                end
                if p_ft(i)<=0.05
                    plot(foi(i),0,'bx')
                end
            end
            
            figure
            plot(foi,squeeze(trimmean(all_absolute_interaction_contrasts(2,1,:,:,:),25,5)),'g')
            hold on
            plot(foi,squeeze(trimmean(all_absolute_interaction_contrasts(1,2,:,:,:),25,5)),'b')
            title(['All trimmed Interaction ' analysis_type ' time ' num2str(start_times) '-' num2str(end_times)])
            legend({'temp-front','front-temp'})
            for i = 1:35 %Compare across group permutation
                p_tf(i) = 1-relRankIn_includeValue_lowerBound(squeeze(trimmean(all_absolute_random_interaction_contrasts(2,1,:,i,:,:),25,6)),squeeze(trimmean(all_absolute_interaction_contrasts(2,1,:,i,:),25,5)));
                p_ft(i) = 1-relRankIn_includeValue_lowerBound(squeeze(trimmean(all_absolute_random_interaction_contrasts(1,2,:,i,:,:),25,6)),squeeze(trimmean(all_absolute_interaction_contrasts(2,1,:,i,:),25,5)));
                if p_tf(i)<=0.05
                    plot(foi(i),0,'g*')
                end
                if p_ft(i)<=0.05
                    plot(foi(i),0,'bx')
                end
            end
    end
    
end