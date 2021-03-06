%Latest stats requires Matlab2015a or greater with statistics toolbox

datapathstem = '/imaging/tc02/vespa/preprocess/SPM12_fullpipeline_fixedICA/extractedsources/';

load([datapathstem 'groups.mat']);
datapathstem = '/imaging/tc02/vespa_followup/preprocess/SPM12_fullpipeline_tf/extractedsources_tf_icoh/'; %For spoken baseline
%datapathstem = '/imaging/tc02/vespa/preprocess/SPM12_fullpipeline_fixedICA/extractedsources_tf_newinversions_newbaseline/'; %For written baseline
addpath(['/group/language/data/thomascope/vespa/SPM12version/Standalone preprocessing pipeline/tc_source_stats/ojwoodford-export_fig-216b30e'])

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

addpath('/imaging/tc02/toolboxes/rsatoolbox/Engines/')

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
    all_random_granger_data = zeros(2,2,1,35,6,1000,length(group));
    all_random_congruency_contrasts = zeros(2,2,1,35,1000,length(group));
    all_random_clarity_contrasts = zeros(2,2,1,35,1000,length(group));
    all_absolute_random_congruency_contrasts = zeros(2,2,1,35,1000,length(group));
    all_absolute_random_clarity_contrasts = zeros(2,2,1,35,1000,length(group));
    all_interaction_contrasts = zeros(2,2,1,35,length(group));
    all_absolute_interaction_contrasts = zeros(2,2,1,35,length(group));
    all_random_interaction_contrasts = zeros(2,2,1,35,1000,length(group));
    all_absolute_random_interaction_contrasts = zeros(2,2,1,35,1000,length(group));
    all_controls_granger_data = [];
    all_patients_granger_data = [];
    all_controls_congruency_contrasts = [];
    all_patients_congruency_contrasts = [];
    all_controls_clarity_contrasts = [];
    all_patients_clarity_contrasts = [];
    all_controls_interaction_contrasts = [];
    all_patients_interaction_contrasts = [];
    
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
    all_random_controls_interaction_contrasts = [];
    all_random_patients_interaction_contrasts = [];
    all_absolute_controls_congruency_contrasts = [];
    all_absolute_patients_congruency_contrasts = [];
    all_absolute_random_controls_congruency_contrasts = [];
    all_absolute_random_patients_congruency_contrasts = [];
    
    for s = 1:length(group)
        %load([datapathstem 's' num2str(s) '_evoked_grangerdata_' num2str(start_times) '_' num2str(end_times) '_overall']); %For evoked data
        if averagesubtracted == 1
            if highfreq == 1
                load([datapathstem 's' num2str(s) '_grangerdata_highfreq_averagesubtracted_1000_' num2str(start_times) '_' num2str(end_times) '_overall']); %For timeseries data
            else
                load([datapathstem 's' num2str(s) '_grangerdata_averagesubtracted_' num2str(start_times) '_' num2str(end_times) '_overall']); %For timeseries data
            end
        else
            if highfreq == 1
                %error('I havent done this analysis (highfreq and without subtracting average')
                load([datapathstem 's' num2str(s) '_grangerdata_highfreq_averagenotsubtracted_' num2str(start_times) '_' num2str(end_times) '_overall']); %For timeseries data
            else
                load([datapathstem 's' num2str(s) '_grangerdata_averagenotsubj_' num2str(start_times) '_' num2str(end_times) '_overall']); %For timeseries data
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
        switch(analysis_type)
            case 'icoh'
                granger_data = abs(granger_data);
        end
        
        all_granger_data(:,:,:,:,:,s) = granger_data(:,:,:,:,:,2001);
        all_random_granger_data(:,:,:,:,:,:,s) = granger_data(:,:,:,:,:,1001:2000); %Random permutations by trial
        demeaned_all_granger_data(:,:,:,:,:,s) = granger_data(:,:,:,:,:,2001) / mean(mean(mean(nanmean(granger_data(:,:,:,:,:,2001)))));
        all_congruency_contrasts(:,:,:,:,s) = mean((granger_data(:,:,:,:,[1,3,5],2001)-granger_data(:,:,:,:,[2,4,6],2001))/3,5);
        all_absolute_congruency_contrasts(:,:,:,:,s) = mean((abs(granger_data(:,:,:,:,[1,3,5],2001))-abs(granger_data(:,:,:,:,[2,4,6],2001)))/3,5);
        all_random_congruency_contrasts(:,:,:,:,:,s) = mean((granger_data(:,:,:,:,[1,3,5],1:1000)-granger_data(:,:,:,:,[2,4,6],1:1000))/3,5);
        all_absolute_random_congruency_contrasts(:,:,:,:,:,s) = mean((abs(granger_data(:,:,:,:,[1,3,5],1:1000))-abs(granger_data(:,:,:,:,[2,4,6],1:1000)))/3,5);
        demeaned_all_congruency_contrasts(:,:,:,:,s) = mean((granger_data(:,:,:,:,[1,3,5],2001)-granger_data(:,:,:,:,[2,4,6],2001))/3,5) / mean(mean(mean(nanmean(granger_data(:,:,:,:,:,2001)))));
        all_clarity_contrasts(:,:,:,:,s) = mean((granger_data(:,:,:,:,[5,6],2001)-granger_data(:,:,:,:,[1,2],2001))/2,5);
        all_absolute_clarity_contrasts(:,:,:,:,s) = mean((abs(granger_data(:,:,:,:,[5,6],2001))-abs(granger_data(:,:,:,:,[1,2],2001)))/2,5);
        demeaned_all_clarity_contrasts(:,:,:,:,s) = mean((granger_data(:,:,:,:,[5,6],2001)-granger_data(:,:,:,:,[1,2],2001))/2,5) / mean(mean(mean(nanmean(granger_data(:,:,:,:,:,2001)))));
        all_random_clarity_contrasts(:,:,:,:,:,s) = mean((granger_data(:,:,:,:,[5,6],1:1000)-granger_data(:,:,:,:,[1,2],1:1000))/3,5);
        all_absolute_random_clarity_contrasts(:,:,:,:,:,s) = mean((abs(granger_data(:,:,:,:,[1,3,5],1:1000))-abs(granger_data(:,:,:,:,[2,4,6],1:1000)))/3,5);
        all_interaction_contrasts(:,:,:,:,s) = mean((granger_data(:,:,:,:,[2,5],2001)-granger_data(:,:,:,:,[1,6],2001))/3,5); %Match4-MisMatch4+MisMatch16-Match16
        all_absolute_interaction_contrasts(:,:,:,:,s) = mean((abs(granger_data(:,:,:,:,[2,5],2001))-abs(granger_data(:,:,:,:,[1,6],2001)))/3,5);
        all_random_interaction_contrasts(:,:,:,:,:,s) = mean((granger_data(:,:,:,:,[2,5],1:1000)-granger_data(:,:,:,:,[1,6],1:1000))/3,5);
        all_absolute_random_interaction_contrasts(:,:,:,:,:,s) = mean((abs(granger_data(:,:,:,:,[2,5],1:1000))-abs(granger_data(:,:,:,:,[1,6],1:1000)))/3,5);
        if group(s) == 1
            all_controls_granger_data(:,:,:,:,:,end+1) = granger_data(:,:,:,:,:,2001);
            all_random_controls_granger_data(:,:,:,:,:,:,end+1) = granger_data(:,:,:,:,:,1001:2000); %Random permutations by trial
            demeaned_all_controls_granger_data(:,:,:,:,:,end+1) = granger_data(:,:,:,:,:,2001)/ mean(mean(mean(nanmean(granger_data(:,:,:,:,:,2001)))));
            all_controls_congruency_contrasts(:,:,:,:,end+1) = mean((granger_data(:,:,:,:,[1,3,5],2001)-granger_data(:,:,:,:,[2,4,6],2001))/3,5);
            all_absolute_controls_congruency_contrasts(:,:,:,:,end+1) = mean((abs(granger_data(:,:,:,:,[1,3,5],2001))-abs(granger_data(:,:,:,:,[2,4,6],2001)))/3,5);
            all_absolute_random_controls_congruency_contrasts(:,:,:,:,:,end+1) = mean((abs(granger_data(:,:,:,:,[1,3,5],1:1000))-abs(granger_data(:,:,:,:,[2,4,6],1:1000)))/3,5);
            all_random_controls_congruency_contrasts(:,:,:,:,:,end+1) = mean((granger_data(:,:,:,:,[1,3,5],1:1000)-granger_data(:,:,:,:,[2,4,6],1:1000))/3,5);
            demeaned_all_controls_congruency_contrasts(:,:,:,:,end+1) = mean((granger_data(:,:,:,:,[1,3,5],2001)-granger_data(:,:,:,:,[2,4,6],2001))/3,5)/ mean(mean(mean(nanmean(granger_data(:,:,:,:,:,2001)))));
            all_controls_clarity_contrasts(:,:,:,:,end+1) = mean((granger_data(:,:,:,:,[5,6],2001)-granger_data(:,:,:,:,[1,2],2001))/2,5);
            all_random_controls_clarity_contrasts(:,:,:,:,:,end+1) = mean((granger_data(:,:,:,:,[5,6],1:1000)-granger_data(:,:,:,:,[1,2],1:1000))/3,5);
            demeaned_all_controls_clarity_contrasts(:,:,:,:,end+1) = mean((granger_data(:,:,:,:,[5,6],2001)-granger_data(:,:,:,:,[1,2],2001))/2,5)/ mean(mean(mean(nanmean(granger_data(:,:,:,:,:,2001)))));
            all_controls_interaction_contrasts(:,:,:,:,end+1) = mean((granger_data(:,:,:,:,[2,5],2001)-granger_data(:,:,:,:,[1,6],2001))/3,5); %Match4-MisMatch4+MisMatch16-Match16
            all_random_controls_interaction_contrasts(:,:,:,:,:,end+1) = mean((granger_data(:,:,:,:,[2,5],1:1000)-granger_data(:,:,:,:,[1,6],1:1000))/3,5);
        elseif group(s) == 2
            all_patients_granger_data(:,:,:,:,:,end+1) = granger_data(:,:,:,:,:,2001);
            all_random_patients_granger_data(:,:,:,:,:,:,end+1) = granger_data(:,:,:,:,:,1001:2000); %Random permutations by trial
            demeaned_all_patients_granger_data(:,:,:,:,:,end+1) = granger_data(:,:,:,:,:,2001)/ mean(mean(mean(nanmean(granger_data(:,:,:,:,:,2001)))));
            all_patients_congruency_contrasts(:,:,:,:,end+1) = mean((granger_data(:,:,:,:,[1,3,5],2001)-granger_data(:,:,:,:,[2,4,6],2001))/3,5);
            all_absolute_patients_congruency_contrasts(:,:,:,:,end+1) = mean((abs(granger_data(:,:,:,:,[1,3,5],2001))-abs(granger_data(:,:,:,:,[2,4,6],2001)))/3,5);
            all_absolute_random_patients_congruency_contrasts(:,:,:,:,:,end+1) = mean((abs(granger_data(:,:,:,:,[1,3,5],1:1000))-abs(granger_data(:,:,:,:,[2,4,6],1:1000)))/3,5);
            all_random_patients_congruency_contrasts(:,:,:,:,:,end+1) = mean((granger_data(:,:,:,:,[1,3,5],1:1000)-granger_data(:,:,:,:,[2,4,6],1:1000))/3,5);
            demeaned_all_patients_congruency_contrasts(:,:,:,:,end+1) = mean((granger_data(:,:,:,:,[1,3,5],2001)-granger_data(:,:,:,:,[2,4,6],2001))/3,5)/ mean(mean(mean(nanmean(granger_data(:,:,:,:,:,2001)))));
            all_patients_clarity_contrasts(:,:,:,:,end+1) = mean((granger_data(:,:,:,:,[5,6],2001)-granger_data(:,:,:,:,[1,2],2001))/2,5);
            all_random_patients_clarity_contrasts(:,:,:,:,:,end+1) = mean((granger_data(:,:,:,:,[5,6],1:1000)-granger_data(:,:,:,:,[1,2],1:1000))/3,5);
            demeaned_all_patients_clarity_contrasts(:,:,:,:,end+1) = mean((granger_data(:,:,:,:,[5,6],2001)-granger_data(:,:,:,:,[1,2],2001))/2,5)/ mean(mean(mean(nanmean(granger_data(:,:,:,:,:,2001)))));
            all_patients_interaction_contrasts(:,:,:,:,end+1) = mean((granger_data(:,:,:,:,[2,5],2001)-granger_data(:,:,:,:,[1,6],2001))/3,5); %Match4-MisMatch4+MisMatch16-Match16
            all_random_patients_interaction_contrasts(:,:,:,:,:,end+1) = mean((granger_data(:,:,:,:,[2,5],1:1000)-granger_data(:,:,:,:,[1,6],1:1000))/3,5);
        end
        
    end
       
    %Account for stupid zero matrices in first line of end+1
    these_lines_to_strip = {
        'all_controls_granger_data(:,:,:,:,:,end+1) = granger_data(:,:,:,:,:,2001);'
        'all_random_controls_granger_data(:,:,:,:,:,:,end+1) = granger_data(:,:,:,:,:,1001:2000);'
        'demeaned_all_controls_granger_data(:,:,:,:,:,end+1) = granger_data(:,:,:,:,:,2001)/ mean(mean(mean(nanmean(granger_data(:,:,:,:,:,2001)))));'
        'all_controls_congruency_contrasts(:,:,:,:,end+1) = mean((granger_data(:,:,:,:,[1,3,5],2001)-granger_data(:,:,:,:,[2,4,6],2001))/3,5);'
        'all_absolute_controls_congruency_contrasts(:,:,:,:,end+1) = mean((abs(granger_data(:,:,:,:,[1,3,5],2001))-abs(granger_data(:,:,:,:,[2,4,6],2001)))/3,5);'
        'all_absolute_random_controls_congruency_contrasts(:,:,:,:,:,end+1) = mean((abs(granger_data(:,:,:,:,[1,3,5],1:1000))-abs(granger_data(:,:,:,:,[2,4,6],1:1000)))/3,5);'
        'all_random_controls_congruency_contrasts(:,:,:,:,:,end+1) = mean((granger_data(:,:,:,:,[1,3,5],1:1000)-granger_data(:,:,:,:,[2,4,6],1:1000))/3,5);'
        'demeaned_all_controls_congruency_contrasts(:,:,:,:,end+1) = mean((granger_data(:,:,:,:,[1,3,5],2001)-granger_data(:,:,:,:,[2,4,6],2001))/3,5)/ mean(mean(mean(nanmean(granger_data(:,:,:,:,:,2001)))));'
        'all_controls_clarity_contrasts(:,:,:,:,end+1) = mean((granger_data(:,:,:,:,[5,6],2001)-granger_data(:,:,:,:,[1,2],2001))/2,5);'
        'all_random_controls_clarity_contrasts(:,:,:,:,:,end+1) = mean((granger_data(:,:,:,:,[5,6],1:1000)-granger_data(:,:,:,:,[1,2],1:1000))/3,5);'
        'demeaned_all_controls_clarity_contrasts(:,:,:,:,end+1) = mean((granger_data(:,:,:,:,[5,6],2001)-granger_data(:,:,:,:,[1,2],2001))/2,5)/ mean(mean(mean(nanmean(granger_data(:,:,:,:,:,2001)))));'
        'all_patients_granger_data(:,:,:,:,:,end+1) = granger_data(:,:,:,:,:,2001);'
        'all_random_patients_granger_data(:,:,:,:,:,:,end+1) = granger_data(:,:,:,:,:,1001:2000);'
        'demeaned_all_patients_granger_data(:,:,:,:,:,end+1) = granger_data(:,:,:,:,:,2001)/ mean(mean(mean(nanmean(granger_data(:,:,:,:,:,2001)))));'
        'all_patients_congruency_contrasts(:,:,:,:,end+1) = mean((granger_data(:,:,:,:,[1,3,5],2001)-granger_data(:,:,:,:,[2,4,6],2001))/3,5);'
        'all_absolute_patients_congruency_contrasts(:,:,:,:,end+1) = mean((abs(granger_data(:,:,:,:,[1,3,5],2001))-abs(granger_data(:,:,:,:,[2,4,6],2001)))/3,5);'
        'all_absolute_random_patients_congruency_contrasts(:,:,:,:,:,end+1) = mean((abs(granger_data(:,:,:,:,[1,3,5],1:1000))-abs(granger_data(:,:,:,:,[2,4,6],1:1000)))/3,5);'
        'all_random_patients_congruency_contrasts(:,:,:,:,:,end+1) = mean((granger_data(:,:,:,:,[1,3,5],1:1000)-granger_data(:,:,:,:,[2,4,6],1:1000))/3,5);'
        'demeaned_all_patients_congruency_contrasts(:,:,:,:,end+1) = mean((granger_data(:,:,:,:,[1,3,5],2001)-granger_data(:,:,:,:,[2,4,6],2001))/3,5)/ mean(mean(mean(nanmean(granger_data(:,:,:,:,:,2001)))));'
        'all_patients_clarity_contrasts(:,:,:,:,end+1) = mean((granger_data(:,:,:,:,[5,6],2001)-granger_data(:,:,:,:,[1,2],2001))/2,5);'
        'all_random_patients_clarity_contrasts(:,:,:,:,:,end+1) = mean((granger_data(:,:,:,:,[5,6],1:1000)-granger_data(:,:,:,:,[1,2],1:1000))/3,5);'
        'demeaned_all_patients_clarity_contrasts(:,:,:,:,end+1) = mean((granger_data(:,:,:,:,[5,6],2001)-granger_data(:,:,:,:,[1,2],2001))/2,5)/ mean(mean(mean(nanmean(granger_data(:,:,:,:,:,2001)))));'
        'all_controls_interaction_contrasts(:,:,:,:,end+1) = mean((granger_data(:,:,:,:,[2,5],2001)-granger_data(:,:,:,:,[1,6],2001))/3,5);'
        'all_patients_interaction_contrasts(:,:,:,:,end+1) = mean((granger_data(:,:,:,:,[2,5],2001)-granger_data(:,:,:,:,[1,6],2001))/3,5);'
        'all_random_controls_interaction_contrasts(:,:,:,:,:,end+1) = mean((granger_data(:,:,:,:,[2,5],1:1000)-granger_data(:,:,:,:,[1,6],1:1000))/3,5);'
        'all_random_patients_interaction_contrasts(:,:,:,:,:,end+1) = mean((granger_data(:,:,:,:,[2,5],1:1000)-granger_data(:,:,:,:,[1,6],1:1000))/3,5);'
        };
    
    for this_line = 1:size(these_lines_to_strip,1)
        target_string = '(:,:,';
        variable_blocks = strsplit(these_lines_to_strip{this_line},target_string);
        variable_indices = strsplit(variable_blocks{2},'=');
        variable_indices{1}(ismember(variable_indices{1},' ')) = [];
        eval([variable_blocks{1} '=' variable_blocks{1} target_string variable_indices{1}(1:end-6) '2:end);'])
    end
        
                    
                    
%     switch(analysis_type)
%         case 'Granger'
            
            figure
            plot(foi,squeeze(mean(mean(all_granger_data(2,1,:,:,:,:),5),6)),'g','LineWidth',7)
            hold on
            plot(foi,squeeze(mean(mean(all_granger_data(1,2,:,:,:,:),5),6)),'b','LineWidth',7)
            plot(foi,squeeze(mean(mean(all_random_granger_data(2,1,:,:,:,:,:),5),7)),'k')
            plot(foi,squeeze(mean(mean(all_random_granger_data(1,2,:,:,:,:,:),5),7)),'k')
            plot(foi,squeeze(mean(mean(all_granger_data(2,1,:,:,:,:),5),6)),'g','LineWidth',7)
            plot(foi,squeeze(mean(mean(all_granger_data(1,2,:,:,:,:),5),6)),'b','LineWidth',7)
            title(['All ' analysis_type ' time ' num2str(start_times) '-' num2str(end_times)])
            legend({'temp-front','front-temp'})
            for i = 1:35 %Compare across group permutation
                p_tf(i) = 1-relRankIn_includeValue_lowerBound(squeeze(mean(mean(all_random_granger_data(2,1,:,i,:,:,:),5),7)),squeeze(mean(mean(all_granger_data(2,1,:,i,:,:),5),6)))
                p_ft(i) = 1-relRankIn_includeValue_lowerBound(squeeze(mean(mean(all_random_granger_data(1,2,:,i,:,:,:),5),7)),squeeze(mean(mean(all_granger_data(1,2,:,i,:,:),5),6)))
                if p_tf(i)<=0.05 || p_tf(i)>=0.95
                    plot(foi(i),0,'g*')
                end
                if p_ft(i)<=0.05 || p_ft(i)>=0.95
                    plot(foi(i),0,'bx')
                end
            end
            
                        
            figure
            plot(foi,squeeze(mean(mean(all_granger_data(2,1,:,:,:,:),5),6)),'g','LineWidth',7)
            hold on
            plot(foi,squeeze(mean(mean(all_granger_data(1,2,:,:,:,:),5),6)),'b','LineWidth',7)
            title(['By direction ' analysis_type ' time ' num2str(start_times) '-' num2str(end_times)])
            legend({'temp-front','front-temp'})
            for i = 1:35
                thisarray = [repmat(sort(repmat([1:21],1,6))',2,1),repmat([1:6]',21*2,1),[ones(21*6,1);2*ones(21*6,1)],[reshape(all_granger_data(2,1,:,i,:,:),[126,1]);reshape(all_granger_data(1,2,:,i,:,:),[126,1])]];
                t1=array2table(thisarray,'VariableNames',{'Subject','Condition','Direction','Response'});
                thistest = fitglm(t1,'Response ~ Direction + Condition + Subject');
                p_tf(i) = thistest.Coefficients{4,4};
                if p_tf(i) < 0.05
                    if mean(mean(all_granger_data(2,1,:,i,:,:),5),6)>mean(mean(all_granger_data(1,2,:,i,:,:),5),6)
                        plot(foi(i),0,'g*')
                    else
                        plot(foi(i),0,'bx')
                    end
                end
            end
            savestring = ['All_mean_' analysis_type '_time_' num2str(start_times) '-' num2str(end_times) '.pdf'];
            eval(['export_fig ' savestring ' -transparent'])
            
            figure
            plot(foi,squeeze(median(mean(all_granger_data(2,1,:,:,:,:),5),6)),'g','LineWidth',7)
            hold on
            plot(foi,squeeze(median(mean(all_granger_data(1,2,:,:,:,:),5),6)),'b','LineWidth',7)
            plot(foi,squeeze(median(mean(all_random_granger_data(2,1,:,:,:,:,:),5),7)),'k')
            plot(foi,squeeze(median(mean(all_random_granger_data(1,2,:,:,:,:,:),5),7)),'k')
            plot(foi,squeeze(median(mean(all_granger_data(2,1,:,:,:,:),5),6)),'g','LineWidth',7)
            plot(foi,squeeze(median(mean(all_granger_data(1,2,:,:,:,:),5),6)),'b','LineWidth',7)
            title(['All median ' analysis_type ' time ' num2str(start_times) '-' num2str(end_times)])
            legend({'temp-front','front-temp'})
            for i = 1:35 %Compare across group permutation
                p_tf(i) = 1-relRankIn_includeValue_lowerBound(squeeze(median(mean(all_random_granger_data(2,1,:,i,:,:,:),5),7)),squeeze(median(mean(all_granger_data(2,1,:,i,:,:),5),6)))
                p_ft(i) = 1-relRankIn_includeValue_lowerBound(squeeze(median(mean(all_random_granger_data(1,2,:,i,:,:,:),5),7)),squeeze(median(mean(all_granger_data(1,2,:,i,:,:),5),6)))
                if p_tf(i)<=0.05 || p_tf(i)>=0.95
                    plot(foi(i),0,'g*')
                end
                if p_ft(i)<=0.05 || p_ft(i)>=0.95
                    plot(foi(i),0,'bx')
                end
            end
            savestring = ['All_median_' analysis_type '_time_' num2str(start_times) '-' num2str(end_times) '.pdf'];
            eval(['export_fig ' savestring ' -transparent'])
            
            figure
            plot(foi,squeeze(mean(mean(demeaned_all_granger_data(2,1,:,:,:,:),5),6)),'g','LineWidth',7)
            hold on
            plot(foi,squeeze(mean(mean(demeaned_all_granger_data(1,2,:,:,:,:),5),6)),'b','LineWidth',7)
            title(['All demeaned ' analysis_type ' time ' num2str(start_times) '-' num2str(end_times)])
            legend({'temp-front','front-temp'}) %Not yet clear how to do stats on this - XXX
%             for i = 1:35 %Rough initial parametric stats - better to use permutation
%                 %[h_tf(i) p_tf(i)] = ttest(mean(demeaned_all_granger_data(2,1,:,i,:,:),5)-mean(demeaned_all_granger_data(1,2,:,i,:,:),5));
%                 [h_tf(i) p_tf(i)] = ttest(reshape(demeaned_all_granger_data(2,1,:,i,:,:),[126,1]),reshape(demeaned_all_granger_data(1,2,:,i,:,:),[126,1]))
%                 if h_tf(i) == 1
%                     if mean(mean(demeaned_all_granger_data(2,1,:,i,:,:),5),6)>mean(mean(demeaned_all_granger_data(1,2,:,i,:,:),5),6)
%                         plot(foi(i),0,'g*')
%                     else
%                         plot(foi(i),0,'bx')
%                     end
%                 end
%             end
            % Fit GLMs with subject and condition. NB: I know that this
            % isn't quite right as subject isn't treated as a random
            % effect, but I can't figure out how to do this and the
            % Bonferroni correction is stringent and should more than
            % compensate
            for i = 1:35
                thisarray = [repmat(sort(repmat([1:21],1,6))',2,1),repmat([1:6]',21*2,1),[ones(21*6,1);2*ones(21*6,1)],[reshape(demeaned_all_granger_data(2,1,:,i,:,:),[126,1]);reshape(demeaned_all_granger_data(1,2,:,i,:,:),[126,1])]];
                t1=array2table(thisarray,'VariableNames',{'Subject','Condition','Direction','Response'});
                thistest = fitglm(t1,'Response ~ Direction + Condition + Subject');
                p_tf(i) = thistest.Coefficients{4,4};
                SEM(i) = thistest.Coefficients{4,2};
                if p_tf(i) < 0.05
                    if mean(mean(demeaned_all_granger_data(2,1,:,i,:,:),5),6)>mean(mean(demeaned_all_granger_data(1,2,:,i,:,:),5),6)
                        plot(foi(i),0,'g*')
                    else
                        plot(foi(i),0,'bx')
                    end
                end
            end
            savestring = ['All_demeaned_' analysis_type '_time_' num2str(start_times) '-' num2str(end_times) '.pdf'];
            eval(['export_fig ' savestring ' -transparent'])
            
            figure
            difference_demeaned = demeaned_all_granger_data(2,1,:,:,:,:)-demeaned_all_granger_data(1,2,:,:,:,:);
            hold on
            fill([foi,fliplr(foi)],[squeeze(mean(mean(difference_demeaned(1,1,:,:,:,:),5),6))-SEM';flipud(squeeze(mean(mean(difference_demeaned(1,1,:,:,:,:),5),6))+SEM')]','g');
            plot(foi,squeeze(mean(mean(difference_demeaned(1,1,:,:,:,:),5),6)),'b','LineWidth',7);
            ylim([-1 1]);
            plot([0 40],[0 0],'k--','LineWidth',1);
            savestring = ['Difference_demeaned_' analysis_type '_time_' num2str(start_times) '-' num2str(end_times) '.pdf'];
            eval(['export_fig ' savestring ' -transparent'])
            
            %             figure
%             plot(foi,squeeze(mean(mean(demeaned_all_controls_granger_data(2,1,:,:,:,:),5),6)),'g:','LineWidth',7)
%             hold on
%             plot(foi,squeeze(mean(mean(demeaned_all_patients_granger_data(2,1,:,:,:,:),5),6)),'g--','LineWidth',7)
%             plot(foi,squeeze(mean(mean(demeaned_all_controls_granger_data(1,2,:,:,:,:),5),6)),'b:','LineWidth',7)
%             plot(foi,squeeze(mean(mean(demeaned_all_patients_granger_data(1,2,:,:,:,:),5),6)),'b--','LineWidth',7)
%             legend({'temp-front control','temp-front patient','front-temp control','front-temp patient'})
%             title(['By group demeaned ' analysis_type ' time ' num2str(start_times) '-' num2str(end_times)])
%             legend({'temp-front','front-temp'}) %Not yet clear how to do stats on this - XXX
%             for i = 1:35 %Rough initial parametric stats - better to use permutation
%                 [h_tf(i) p_tf(i)] = ttest2(mean(demeaned_all_controls_granger_data(2,1,:,i,:,:),5),mean(demeaned_all_patients_granger_data(2,1,:,i,:,:),5));
%                 [h_ft(i) p_ft(i)] = ttest2(mean(demeaned_all_controls_granger_data(1,2,:,i,:,:),5),mean(demeaned_all_patients_granger_data(1,2,:,i,:,:),5));
%                 if h_tf(i) == 1
%                     plot(foi(i),0,'g*')
%                 end
%                 if h_ft(i) == 1
%                     plot(foi(i),0,'bx')
%                 end
%             end
            
            
            figure
            hold on
            plot(foi,squeeze(mean(mean(all_controls_granger_data(2,1,:,:,:,2:end),5),6)),'g:','LineWidth',7)
            plot(foi,squeeze(mean(mean(all_patients_granger_data(2,1,:,:,:,2:end),5),6)),'g--','LineWidth',7)
            plot(foi,squeeze(mean(mean(all_controls_granger_data(1,2,:,:,:,2:end),5),6)),'b:','LineWidth',7)
            plot(foi,squeeze(mean(mean(all_patients_granger_data(1,2,:,:,:,2:end),5),6)),'b--','LineWidth',7)
            legend({'temp-front control','temp-front patient','front-temp control','front-temp patient'})
            title(['By group ' analysis_type ' time ' num2str(start_times) '-' num2str(end_times)])
            for i = 1:35 %Rough initial parametric stats - better to use permutation
                [h_tf(i) p_tf(i)] = ttest2(mean(all_controls_granger_data(2,1,:,i,:,:),5),mean(all_patients_granger_data(2,1,:,i,:,:),5));
                [h_ft(i) p_ft(i)] = ttest2(mean(all_controls_granger_data(1,2,:,i,:,:),5),mean(all_patients_granger_data(1,2,:,i,:,:),5));
                if h_tf(i) == 1
                    plot(foi(i),0,'g*')
                end
                if h_ft(i) == 1
                    plot(foi(i),0,'bx')
                end
            end
            
            
%             control_test = [];
%             patient_test = [];
%             for i = 2:34 % A little bit of 'frequency smoothing'
%                 control_test(i-1,:) = squeeze(mean(mean(all_controls_granger_data(2,1,:,i-1:i+1,:,:),5),4));
%                 patient_test(i-1,:) = squeeze(mean(mean(all_patients_granger_data(2,1,:,i-1:i+1,:,:),5),4));
%                 [h_tf(i) p_tf(i)] = ttest2(control_test(i-1,:),patient_test(i-1,:));
%                 control_test(i-1,:) = squeeze(mean(mean(all_controls_granger_data(1,2,:,i-1:i+1,:,:),5),4));
%                 patient_test(i-1,:) = squeeze(mean(mean(all_patients_granger_data(1,2,:,i-1:i+1,:,:),5),4));
%                 [h_ft(i) p_ft(i)] = ttest2(control_test(i-1,:),patient_test(i-1,:));
%                 
%                 
%                 if h_tf(i) == 1
%                     plot(foi(i),0,'g*')
%                 end
%                 if h_ft(i) == 1
%                     plot(foi(i),0,'bx')
%                 end
%             end
            savestring = ['By_group_mean_' analysis_type '_time_' num2str(start_times) '-' num2str(end_times) '.pdf'];
            eval(['export_fig ' savestring ' -transparent'])
           
            
                        figure
            hold on
            patient_SEMs = std(squeeze(mean(all_patients_granger_data(2,1,:,:,:,2:end),5))')/sqrt(10);
            control_SEMs = std(squeeze(mean(all_controls_granger_data(2,1,:,:,:,2:end),5))')/sqrt(11);
            fill([foi,fliplr(foi)],[squeeze(mean(mean(all_controls_granger_data(1,2,:,:,:,2:end),5),6))-control_SEMs';flipud(squeeze(mean(mean(all_controls_granger_data(1,2,:,:,:,2:end),5),6))+control_SEMs')]','c');
            fill([foi,fliplr(foi)],[squeeze(mean(mean(all_patients_granger_data(1,2,:,:,:,2:end),5),6))-patient_SEMs';flipud(squeeze(mean(mean(all_patients_granger_data(1,2,:,:,:,2:end),5),6))+patient_SEMs')]','m');
            plot(foi,squeeze(mean(mean(all_controls_granger_data(1,2,:,:,:,2:end),5),6)),'k','LineWidth',7)
            plot(foi,squeeze(mean(mean(all_patients_granger_data(1,2,:,:,:,2:end),5),6)),'y','LineWidth',7)
            legend({'temp-front control','temp-front patient','front-temp control','front-temp patient'})
            title(['By group ' analysis_type ' time ' num2str(start_times) '-' num2str(end_times)])
            for i = 1:35 %Rough initial parametric stats - better to use permutation
                [h_tf(i) p_tf(i)] = ttest2(mean(all_controls_granger_data(2,1,:,i,:,:),5),mean(all_patients_granger_data(2,1,:,i,:,:),5));
                [h_ft(i) p_ft(i)] = ttest2(mean(all_controls_granger_data(1,2,:,i,:,:),5),mean(all_patients_granger_data(1,2,:,i,:,:),5));
                if h_tf(i) == 1
                    plot(foi(i),0,'g*')
                end
                if h_ft(i) == 1
                    plot(foi(i),0,'bx')
                end
            end
            savestring = ['By_group_mean_withSEM_' analysis_type '_time_' num2str(start_times) '-' num2str(end_times) '.pdf'];
            eval(['export_fig ' savestring ' -transparent'])
           
            
            figure
            hold on
            plot(foi,squeeze(median(mean(all_controls_granger_data(2,1,:,:,:,:),5),6)),'g:','LineWidth',7)
            plot(foi,squeeze(median(mean(all_patients_granger_data(2,1,:,:,:,:),5),6)),'g--','LineWidth',7)
            plot(foi,squeeze(median(mean(all_controls_granger_data(1,2,:,:,:,:),5),6)),'b:','LineWidth',7)
            plot(foi,squeeze(median(mean(all_patients_granger_data(1,2,:,:,:,:),5),6)),'b--','LineWidth',7)
            legend({'temp-front control','temp-front patient','front-temp control','front-temp patient'})
            title(['By group median ' analysis_type ' time ' num2str(start_times) '-' num2str(end_times)])
            for i = 1:35 %Rough initial parametric stats - better to use permutation
                [p_tf(i) h_tf(i)] = ranksum(squeeze(mean(all_controls_granger_data(2,1,:,i,:,:),5)),squeeze(mean(all_patients_granger_data(2,1,:,i,:,:),5)));
                [p_ft(i) h_ft(i)] = ranksum(squeeze(mean(all_controls_granger_data(1,2,:,i,:,:),5)),squeeze(mean(all_patients_granger_data(1,2,:,i,:,:),5)));
                if h_tf(i) == 1
                    plot(foi(i),0,'g*')
                end
                if h_ft(i) == 1
                    plot(foi(i),0,'bx')
                end
            end
            
            savestring = ['By_group_median_' analysis_type '_time_' num2str(start_times) '-' num2str(end_times) '.pdf'];
            eval(['export_fig ' savestring ' -transparent'])
            
            
            figure
            hold on
            plot(foi,squeeze(mean(mean(demeaned_all_controls_granger_data(2,1,:,:,:,2:end),5),6)),'g:','LineWidth',7)
            plot(foi,squeeze(mean(mean(demeaned_all_patients_granger_data(2,1,:,:,:,2:end),5),6)),'g--','LineWidth',7)
            plot(foi,squeeze(mean(mean(demeaned_all_controls_granger_data(1,2,:,:,:,2:end),5),6)),'b:','LineWidth',7)
            plot(foi,squeeze(mean(mean(demeaned_all_patients_granger_data(1,2,:,:,:,2:end),5),6)),'b--','LineWidth',7)
         
            title(['By group demeaned ' analysis_type ' time ' num2str(start_times) '-' num2str(end_times)])
             legend({'temp-front control','temp-front patient','front-temp control','front-temp patient'})
         
%             con_tf_lowfreq = squeeze(mean(median(mean(all_controls_granger_data(2,1,:,4:5,:,:),5),6),4));
%             pat_tf_lowfreq = squeeze(mean(median(mean(all_patients_granger_data(2,1,:,4:5,:,:),5),6),4));
%             con_ft_lowfreq = squeeze(mean(median(mean(all_controls_granger_data(1,2,:,4:5,:,:),5),6),4));
%             pat_ft_lowfreq = squeeze(mean(median(mean(all_patients_granger_data(1,2,:,4:5,:,:),5),6),4));
%             
%             con_tf_highfreq = squeeze(mean(median(mean(all_controls_granger_data(2,1,:,7:10,:,:),5),6),4));
%             pat_tf_highfreq = squeeze(mean(median(mean(all_patients_granger_data(2,1,:,7:10,:,:),5),6),4));
%             con_ft_highfreq = squeeze(mean(median(mean(all_controls_granger_data(1,2,:,7:10,:,:),5),6),4));
%             pat_ft_highfreq = squeeze(mean(median(mean(all_patients_granger_data(1,2,:,7:10,:,:),5),6),4));
            
continue

            config = figure;
            patfig = figure;
            con_contrastfig = figure;
            pat_contrastfig = figure;
            con_interactionfig = figure;
            pat_interactionfig = figure;
            this_con = 0;
            this_pat = 0;
            
            for s = 1:length(group)
                if group(s) == 1
                    this_con = this_con+1;
                    figure(config);
                    h = subplot(4,3,this_con);
                    plot(foi,squeeze(mean(all_granger_data(2,1,:,:,:,s),5)),'g','LineWidth',7)
                    hold on
                    plot(foi,squeeze(mean(all_granger_data(1,2,:,:,:,s),5)),'b','LineWidth',7)
                    for i = 1:35 %Compare within subj permutation
                        p_tf(i) = 1-relRankIn_includeValue_lowerBound(squeeze(mean(all_random_granger_data(2,1,:,i,:,:,s),5)),squeeze(mean(all_granger_data(2,1,:,i,:,s),5)));
                        p_ft(i) = 1-relRankIn_includeValue_lowerBound(squeeze(mean(all_random_granger_data(1,2,:,i,:,:,s),5)),squeeze(mean(all_granger_data(1,2,:,i,:,s),5)));
                        if p_tf(i)<=0.05 || p_tf(i)>=0.95
                            plot(foi(i),0,'g*')
                        end
                        if p_ft(i)<=0.05 || p_ft(i)>=0.95
                            plot(foi(i),0,'bx')
                        end
                    end
                    
                    figure(con_contrastfig);
                    h = subplot(4,3,this_con);
                    hold on
                    plot(foi,squeeze(mean(all_congruency_contrasts(2,1,:,:,s),5)),'g','LineWidth',7)
                    
                    plot(foi,squeeze(mean(all_congruency_contrasts(1,2,:,:,s),5)),'b','LineWidth',7)
                    plot(foi,squeeze(mean(all_random_congruency_contrasts(2,1,:,:,:,s),6)),'k')
                    plot(foi,squeeze(mean(all_random_congruency_contrasts(1,2,:,:,:,s),6)),'k')
                    plot(foi,squeeze(mean(all_congruency_contrasts(2,1,:,:,s),5)),'g','LineWidth',7)
                    
                    plot(foi,squeeze(mean(all_congruency_contrasts(1,2,:,:,s),5)),'b','LineWidth',7)

                    %legend({'temp-front','front-temp'})
                    for i = 1:35 %Compare across group permutation
                        p_tf(i) = 1-relRankIn_includeValue_lowerBound(squeeze(mean(all_random_congruency_contrasts(2,1,:,i,:,s),6)),squeeze(mean(all_congruency_contrasts(2,1,:,i,s),5)));
                        p_ft(i) = 1-relRankIn_includeValue_lowerBound(squeeze(mean(all_random_congruency_contrasts(1,2,:,i,:,s),6)),squeeze(mean(all_congruency_contrasts(1,2,:,i,s),5)));
                        if p_tf(i)<=0.05 || p_tf(i)>=0.95
                            plot(foi(i),0,'g*')
                        end
                        if p_ft(i)<=0.05 || p_ft(i)>=0.95
                            plot(foi(i),0,'bx')
                        end
                    end
                    
                    figure(con_interactionfig);
                    h = subplot(4,3,this_con);
                    hold on
                    plot(foi,squeeze(mean(all_interaction_contrasts(2,1,:,:,s),5)),'g','LineWidth',7)
                    
                    plot(foi,squeeze(mean(all_interaction_contrasts(1,2,:,:,s),5)),'b','LineWidth',7)
                    plot(foi,squeeze(mean(all_random_interaction_contrasts(2,1,:,:,:,s),6)),'k')
                    plot(foi,squeeze(mean(all_random_interaction_contrasts(1,2,:,:,:,s),6)),'k')
                    plot(foi,squeeze(mean(all_interaction_contrasts(2,1,:,:,s),5)),'g','LineWidth',7)
                    
                    plot(foi,squeeze(mean(all_interaction_contrasts(1,2,:,:,s),5)),'b','LineWidth',7)

                    %legend({'temp-front','front-temp'})
                    for i = 1:35 %Compare across group permutation
                        p_tf(i) = 1-relRankIn_includeValue_lowerBound(squeeze(mean(all_random_interaction_contrasts(2,1,:,i,:,s),6)),squeeze(mean(all_interaction_contrasts(2,1,:,i,s),5)));
                        p_ft(i) = 1-relRankIn_includeValue_lowerBound(squeeze(mean(all_random_interaction_contrasts(1,2,:,i,:,s),6)),squeeze(mean(all_interaction_contrasts(1,2,:,i,s),5)));
                        if p_tf(i)<=0.05 || p_tf(i)>=0.95
                            plot(foi(i),0,'g*')
                        end
                        if p_ft(i)<=0.05 || p_ft(i)>=0.95
                            plot(foi(i),0,'bx')
                        end
                    end
                    
                    
                    
                elseif group(s) == 2
                    this_pat = this_pat+1;
                    figure(patfig);
                    h = subplot(4,3,this_pat);
                    plot(foi,squeeze(mean(all_granger_data(2,1,:,:,:,s),5)),'g','LineWidth',7)
                    hold on
                    plot(foi,squeeze(mean(all_granger_data(1,2,:,:,:,s),5)),'b','LineWidth',7)
                    for i = 1:35 %Compare within subj permutation
                        p_tf(i) = 1-relRankIn_includeValue_lowerBound(squeeze(mean(all_random_granger_data(2,1,:,i,:,:,s),5)),squeeze(mean(all_granger_data(2,1,:,i,:,s),5)));
                        p_ft(i) = 1-relRankIn_includeValue_lowerBound(squeeze(mean(all_random_granger_data(1,2,:,i,:,:,s),5)),squeeze(mean(all_granger_data(1,2,:,i,:,s),5)));
                        if p_tf(i)<=0.05 || p_tf(i)>=0.95
                            plot(foi(i),0,'g*')
                        end
                        if p_ft(i)<=0.05 || p_ft(i)>=0.95
                            plot(foi(i),0,'bx')
                        end
                    end
                    
                    figure(pat_contrastfig);
                    h = subplot(4,3,this_pat);
                    hold on
                    plot(foi,squeeze(mean(all_congruency_contrasts(2,1,:,:,s),5)),'g','LineWidth',7)
                    
                    plot(foi,squeeze(mean(all_congruency_contrasts(1,2,:,:,s),5)),'b','LineWidth',7)
                    plot(foi,squeeze(mean(all_random_congruency_contrasts(2,1,:,:,:,s),6)),'k')
                    plot(foi,squeeze(mean(all_random_congruency_contrasts(1,2,:,:,:,s),6)),'k')
                    plot(foi,squeeze(mean(all_congruency_contrasts(2,1,:,:,s),5)),'g','LineWidth',7)
                    
                    plot(foi,squeeze(mean(all_congruency_contrasts(1,2,:,:,s),5)),'b','LineWidth',7)

                    %legend({'temp-front','front-temp'})
                    for i = 1:35 %Compare across group permutation
                        p_tf(i) = 1-relRankIn_includeValue_lowerBound(squeeze(mean(all_random_congruency_contrasts(2,1,:,i,:,s),6)),squeeze(mean(all_congruency_contrasts(2,1,:,i,s),5)));
                        p_ft(i) = 1-relRankIn_includeValue_lowerBound(squeeze(mean(all_random_congruency_contrasts(1,2,:,i,:,s),6)),squeeze(mean(all_congruency_contrasts(1,2,:,i,s),5)));
                        if p_tf(i)<=0.05 || p_tf(i)>=0.95
                            plot(foi(i),0,'g*')
                        end
                        if p_ft(i)<=0.05 || p_ft(i)>=0.95
                            plot(foi(i),0,'bx')
                        end
                    end
                    
                     figure(pat_interactionfig);
                    h = subplot(4,3,this_pat);
                    hold on
                    plot(foi,squeeze(mean(all_interaction_contrasts(2,1,:,:,s),5)),'g','LineWidth',7)
                    
                    plot(foi,squeeze(mean(all_interaction_contrasts(1,2,:,:,s),5)),'b','LineWidth',7)
                    plot(foi,squeeze(mean(all_random_interaction_contrasts(2,1,:,:,:,s),6)),'k')
                    plot(foi,squeeze(mean(all_random_interaction_contrasts(1,2,:,:,:,s),6)),'k')
                    plot(foi,squeeze(mean(all_interaction_contrasts(2,1,:,:,s),5)),'g','LineWidth',7)
                    
                    plot(foi,squeeze(mean(all_interaction_contrasts(1,2,:,:,s),5)),'b','LineWidth',7)

                    %legend({'temp-front','front-temp'})
                    for i = 1:35 %Compare across group permutation
                        p_tf(i) = 1-relRankIn_includeValue_lowerBound(squeeze(mean(all_random_interaction_contrasts(2,1,:,i,:,s),6)),squeeze(mean(all_interaction_contrasts(2,1,:,i,s),5)));
                        p_ft(i) = 1-relRankIn_includeValue_lowerBound(squeeze(mean(all_random_interaction_contrasts(1,2,:,i,:,s),6)),squeeze(mean(all_interaction_contrasts(1,2,:,i,s),5)));
                        if p_tf(i)<=0.05 || p_tf(i)>=0.95
                            plot(foi(i),0,'g*')
                        end
                        if p_ft(i)<=0.05 || p_ft(i)>=0.95
                            plot(foi(i),0,'bx')
                        end
                    end
                    
                end
            end
            figure(config)
            title(['Controls ' analysis_type ' time ' num2str(start_times) '-' num2str(end_times)])
            figure(patfig)
            title(['Patients ' analysis_type ' time ' num2str(start_times) '-' num2str(end_times)])
            figure(con_contrastfig);
            title(['Controls Match-Mismatch ' analysis_type])
            figure(pat_contrastfig);
            title(['Patients Match-Mismatch ' analysis_type])
            figure(con_interactionfig);
            title(['Controls Interaction ' analysis_type])
            figure(pat_interactionfig);
            title(['Patients Interaction ' analysis_type])
            
            
            figure
            hold on
            plot(foi,squeeze(mean(all_congruency_contrasts(2,1,:,:,:),5)),'g','LineWidth',7)
            
            plot(foi,squeeze(mean(all_congruency_contrasts(1,2,:,:,:),5)),'b','LineWidth',7)
            plot(foi,squeeze(mean(all_random_congruency_contrasts(2,1,:,:,:,:),6)),'k')
            plot(foi,squeeze(mean(all_random_congruency_contrasts(1,2,:,:,:,:),6)),'k')
            plot(foi,squeeze(mean(all_congruency_contrasts(2,1,:,:,:),5)),'g','LineWidth',7)
            
            plot(foi,squeeze(mean(all_congruency_contrasts(1,2,:,:,:),5)),'b','LineWidth',7)
            title(['All MisMatch-Match ' analysis_type ' time ' num2str(start_times) '-' num2str(end_times)])
            legend({'temp-front','front-temp'})
            for i = 1:35 %Compare across group permutation
                p_tf(i) = 1-relRankIn_includeValue_lowerBound(squeeze(mean(all_random_congruency_contrasts(2,1,:,i,:,:),6)),squeeze(mean(all_congruency_contrasts(2,1,:,i,:),5)));
                p_ft(i) = 1-relRankIn_includeValue_lowerBound(squeeze(mean(all_random_congruency_contrasts(1,2,:,i,:,:),6)),squeeze(mean(all_congruency_contrasts(1,2,:,i,:),5)));
                if p_tf(i)<=0.05 || p_tf(i)>=0.95
                    plot(foi(i),0,'g*')
                end
                if p_ft(i)<=0.05 || p_ft(i)>=0.95
                    plot(foi(i),0,'bx')
                end
            end
            
            figure
            hold on
            plot(foi,squeeze(median(all_congruency_contrasts(2,1,:,:,:),5)),'g','LineWidth',7)
            
            plot(foi,squeeze(median(all_congruency_contrasts(1,2,:,:,:),5)),'b','LineWidth',7)
            plot(foi,squeeze(median(all_random_congruency_contrasts(2,1,:,:,:,:),6)),'k')
            plot(foi,squeeze(median(all_random_congruency_contrasts(1,2,:,:,:,:),6)),'k')
            plot(foi,squeeze(median(all_congruency_contrasts(2,1,:,:,:),5)),'g','LineWidth',7)
            
            plot(foi,squeeze(median(all_congruency_contrasts(1,2,:,:,:),5)),'b','LineWidth',7)
            title(['All median MisMatch-Match ' analysis_type ' time ' num2str(start_times) '-' num2str(end_times)])
            legend({'temp-front','front-temp'})
            for i = 1:35 %Compare across group permutation
                p_tf(i) = 1-relRankIn_includeValue_lowerBound(squeeze(median(all_random_congruency_contrasts(2,1,:,i,:,:),6)),squeeze(median(all_congruency_contrasts(2,1,:,i,:),5)));
                p_ft(i) = 1-relRankIn_includeValue_lowerBound(squeeze(median(all_random_congruency_contrasts(1,2,:,i,:,:),6)),squeeze(median(all_congruency_contrasts(1,2,:,i,:),5)));
                if p_tf(i)<=0.05 || p_tf(i)>=0.95
                    plot(foi(i),0,'g*')
                end
                if p_ft(i)<=0.05 || p_ft(i)>=0.95
                    plot(foi(i),0,'bx')
                end
            end
            
            figure
            hold on
            plot(foi,squeeze(mean(all_clarity_contrasts(2,1,:,:,:),5)),'g','LineWidth',7)
            
            plot(foi,squeeze(mean(all_clarity_contrasts(1,2,:,:,:),5)),'b','LineWidth',7)
            plot(foi,squeeze(mean(all_random_clarity_contrasts(2,1,:,:,:,:),6)),'k')
            plot(foi,squeeze(mean(all_random_clarity_contrasts(1,2,:,:,:,:),6)),'k')
            plot(foi,squeeze(mean(all_clarity_contrasts(2,1,:,:,:),5)),'g','LineWidth',7)
            
            plot(foi,squeeze(mean(all_clarity_contrasts(1,2,:,:,:),5)),'b','LineWidth',7)
            title(['All Clear-Unclear ' analysis_type ' time ' num2str(start_times) '-' num2str(end_times)])
            legend({'temp-front','front-temp'})
            for i = 1:35 %Compare across group permutation
                p_tf(i) = 1-relRankIn_includeValue_lowerBound(squeeze(mean(all_random_clarity_contrasts(2,1,:,i,:,:),6)),squeeze(mean(all_clarity_contrasts(2,1,:,i,:),5)));
                p_ft(i) = 1-relRankIn_includeValue_lowerBound(squeeze(mean(all_random_clarity_contrasts(1,2,:,i,:,:),6)),squeeze(mean(all_clarity_contrasts(1,2,:,i,:),5)));
                if p_tf(i)<=0.05 || p_tf(i)>=0.95
                    plot(foi(i),0,'g*')
                end
                if p_ft(i)<=0.05 || p_ft(i)>=0.95
                    plot(foi(i),0,'bx')
                end
            end
            
            figure
            hold on
            plot(foi,squeeze(median(all_clarity_contrasts(2,1,:,:,:),5)),'g','LineWidth',7)
            
            plot(foi,squeeze(median(all_clarity_contrasts(1,2,:,:,:),5)),'b','LineWidth',7)
            plot(foi,squeeze(median(all_random_clarity_contrasts(2,1,:,:,:,:),6)),'k')
            plot(foi,squeeze(median(all_random_clarity_contrasts(1,2,:,:,:,:),6)),'k')
            plot(foi,squeeze(median(all_clarity_contrasts(2,1,:,:,:),5)),'g','LineWidth',7)
            
            plot(foi,squeeze(median(all_clarity_contrasts(1,2,:,:,:),5)),'b','LineWidth',7)
            title(['All median Clear-Unclear ' analysis_type ' time ' num2str(start_times) '-' num2str(end_times)])
            legend({'temp-front','front-temp'})
            for i = 1:35 %Compare across group permutation
                p_tf(i) = 1-relRankIn_includeValue_lowerBound(squeeze(median(all_random_clarity_contrasts(2,1,:,i,:,:),6)),squeeze(median(all_clarity_contrasts(2,1,:,i,:),5)));
                p_ft(i) = 1-relRankIn_includeValue_lowerBound(squeeze(median(all_random_clarity_contrasts(1,2,:,i,:,:),6)),squeeze(median(all_clarity_contrasts(1,2,:,i,:),5)));
                if p_tf(i)<=0.05 || p_tf(i)>=0.95
                    plot(foi(i),0,'g*')
                end
                if p_ft(i)<=0.05 || p_ft(i)>=0.95
                    plot(foi(i),0,'bx')
                end
            end
            
            figure
            hold on
            plot(foi,squeeze(mean(mean(all_controls_congruency_contrasts(2,1,:,:,:),5),6)),'g:','LineWidth',7)
            plot(foi,squeeze(mean(mean(all_patients_congruency_contrasts(2,1,:,:,:),5),6)),'g--','LineWidth',7)
            plot(foi,squeeze(mean(mean(all_controls_congruency_contrasts(1,2,:,:,:),5),6)),'b:','LineWidth',7)
            plot(foi,squeeze(mean(mean(all_patients_congruency_contrasts(1,2,:,:,:),5),6)),'b--','LineWidth',7)
            title(['By group Mean Mismatch-Match' analysis_type ])
            legend({'temp-front control','temp-front patient','front-temp control','front-temp patient'})
            for i = 1:35 %Rough initial parametric stats - better to use permutation
                [h_tf(i) p_tf(i)] = ttest2(squeeze(all_patients_congruency_contrasts(2,1,:,i,:)),squeeze(all_controls_congruency_contrasts(2,1,:,i,:)));
                [p_tf(i) h_tf(i)] = ttest2(squeeze(all_absolute_patients_congruency_contrasts(2,1,:,i,:)),squeeze(all_absolute_controls_congruency_contrasts(2,1,:,i,:)));
                [h_ft(i) p_ft(i)] = ttest2(squeeze(all_patients_congruency_contrasts(1,2,:,i,:)),squeeze(all_controls_congruency_contrasts(1,2,:,i,:)));
                if h_tf(i) == 1
                    plot(foi(i),0,'g*')
                end
                if h_ft(i) == 1
                    plot(foi(i),0,'bx')
                end
            end
            
            figure
            hold on
            plot(foi,squeeze(median(all_controls_congruency_contrasts(2,1,:,:,:),5)),'g:','LineWidth',7)
            plot(foi,squeeze(median(all_patients_congruency_contrasts(2,1,:,:,:),5)),'g--','LineWidth',7)
            plot(foi,squeeze(median(all_controls_congruency_contrasts(1,2,:,:,:),5)),'b:','LineWidth',7)
            plot(foi,squeeze(median(all_patients_congruency_contrasts(1,2,:,:,:),5)),'b--','LineWidth',7)
            title(['By group Median Mismatch-Match' analysis_type ])
            legend({'temp-front control','temp-front patient','front-temp control','front-temp patient'})
            for i = 1:35 %Rough initial parametric stats - better to use permutation
                [p_tf(i) h_tf(i)] = ranksum(squeeze(all_patients_congruency_contrasts(2,1,:,i,:)),squeeze(all_controls_congruency_contrasts(2,1,:,i,:)));
                [p_ft(i) h_ft(i)] = ranksum(squeeze(all_patients_congruency_contrasts(1,2,:,i,:)),squeeze(all_controls_congruency_contrasts(1,2,:,i,:)));
                if h_tf(i) == 1
                    plot(foi(i),0,'g*')
                end
                if h_ft(i) == 1
                    plot(foi(i),0,'bx')
                end
            end
            
            figure
            plot(foi,squeeze(mean(all_interaction_contrasts(2,1,:,:,:),5)),'g','LineWidth',7)
            hold on
            plot(foi,squeeze(mean(all_interaction_contrasts(1,2,:,:,:),5)),'b','LineWidth',7)
            plot(foi,squeeze(mean(all_random_interaction_contrasts(2,1,:,:,:,:),6)),'k')
            plot(foi,squeeze(mean(all_random_interaction_contrasts(1,2,:,:,:,:),6)),'k')
            plot(foi,squeeze(mean(all_interaction_contrasts(2,1,:,:,:),5)),'g','LineWidth',7)
            plot(foi,squeeze(mean(all_interaction_contrasts(1,2,:,:,:),5)),'b','LineWidth',7)
            title(['All Interaction ' analysis_type ' time ' num2str(start_times) '-' num2str(end_times)])
            legend({'temp-front','front-temp'})
            for i = 1:35 %Compare across group permutation
                p_tf(i) = 1-relRankIn_includeValue_lowerBound(squeeze(mean(all_random_interaction_contrasts(2,1,:,i,:,:),6)),squeeze(mean(all_interaction_contrasts(2,1,:,i,:),5)));
                p_ft(i) = 1-relRankIn_includeValue_lowerBound(squeeze(mean(all_random_interaction_contrasts(1,2,:,i,:,:),6)),squeeze(mean(all_interaction_contrasts(1,2,:,i,:),5)));
                if p_tf(i)<=0.05 || p_tf(i)>=0.95
                    plot(foi(i),0,'g*')
                end
                if p_ft(i)<=0.05 || p_ft(i)>=0.95
                    plot(foi(i),0,'bx')
                end
            end
            
            figure
            plot(foi,squeeze(median(all_interaction_contrasts(2,1,:,:,:),5)),'g','LineWidth',7)
            hold on
            plot(foi,squeeze(median(all_interaction_contrasts(1,2,:,:,:),5)),'b','LineWidth',7)
            plot(foi,squeeze(median(all_random_interaction_contrasts(2,1,:,:,:,:),6)),'k')
            plot(foi,squeeze(median(all_random_interaction_contrasts(1,2,:,:,:,:),6)),'k')
            plot(foi,squeeze(median(all_interaction_contrasts(2,1,:,:,:),5)),'g','LineWidth',7)
            
            plot(foi,squeeze(median(all_interaction_contrasts(1,2,:,:,:),5)),'b','LineWidth',7)
            title(['All median Interaction ' analysis_type ' time ' num2str(start_times) '-' num2str(end_times)])
            legend({'temp-front','front-temp'})
            for i = 1:35 %Compare across group permutation
                p_tf(i) = 1-relRankIn_includeValue_lowerBound(squeeze(median(all_random_interaction_contrasts(2,1,:,i,:,:),6)),squeeze(median(all_interaction_contrasts(2,1,:,i,:),5)));
                p_ft(i) = 1-relRankIn_includeValue_lowerBound(squeeze(median(all_random_interaction_contrasts(1,2,:,i,:,:),6)),squeeze(median(all_interaction_contrasts(1,2,:,i,:),5)));
                if p_tf(i)<=0.05 || p_tf(i)>=0.95
                    plot(foi(i),0,'g*')
                end
                if p_ft(i)<=0.05 || p_ft(i)>=0.95
                    plot(foi(i),0,'bx')
                end
            end
            
            figure
            hold on
            plot(foi,squeeze(median(mean(all_controls_congruency_contrasts(2,1,:,:,:),5),6)),'g:','LineWidth',7)
            plot(foi,squeeze(median(mean(all_patients_congruency_contrasts(2,1,:,:,:),5),6)),'g--','LineWidth',7)
            plot(foi,squeeze(median(mean(all_controls_congruency_contrasts(1,2,:,:,:),5),6)),'b:','LineWidth',7)
            plot(foi,squeeze(median(mean(all_patients_congruency_contrasts(1,2,:,:,:),5),6)),'b--','LineWidth',7)
            plot(foi,squeeze(mean(all_random_controls_congruency_contrasts(2,1,:,:,:,:),6)),'k:')
            plot(foi,squeeze(mean(all_random_patients_congruency_contrasts(2,1,:,:,:,:),6)),'k--')
            plot(foi,squeeze(mean(all_random_controls_congruency_contrasts(1,2,:,:,:,:),6)),'k:')
            plot(foi,squeeze(mean(all_random_patients_congruency_contrasts(1,2,:,:,:,:),6)),'k--')
            plot(foi,squeeze(median(mean(all_controls_congruency_contrasts(2,1,:,:,:),5),6)),'g:','LineWidth',7)
            plot(foi,squeeze(median(mean(all_patients_congruency_contrasts(2,1,:,:,:),5),6)),'g--','LineWidth',7)
            plot(foi,squeeze(median(mean(all_controls_congruency_contrasts(1,2,:,:,:),5),6)),'b:','LineWidth',7)
            plot(foi,squeeze(median(mean(all_patients_congruency_contrasts(1,2,:,:,:),5),6)),'b--','LineWidth',7)
            title(['By group sig Mean Mismatch-Match' analysis_type ])
            legend({'temp-front control','temp-front patient','front-temp control','front-temp patient'})
            for i = 1:35 %Rough initial parametric stats - better to use permutation
                p_tf_c(i) = 1-relRankIn_includeValue_lowerBound(squeeze(mean(all_random_controls_congruency_contrasts(2,1,i,:,:,:),6)),squeeze(mean(all_controls_congruency_contrasts(2,1,:,i,:),5)));
                p_ft_c(i) = 1-relRankIn_includeValue_lowerBound(squeeze(mean(all_random_controls_congruency_contrasts(1,2,i,:,:,:),6)),squeeze(mean(all_controls_congruency_contrasts(1,2,:,i,:),5)));
                if p_tf_c(i)<=0.05 || p_ft_c(i)>=0.95
                    plot(foi(i),0,'go')
                end
                if p_ft_c(i)<=0.05 || p_ft_c(i)>=0.95
                    plot(foi(i),0,'b.')
                end
                p_tf_p(i) = 1-relRankIn_includeValue_lowerBound(squeeze(mean(all_random_patients_congruency_contrasts(2,1,i,:,:,:),6)),squeeze(mean(all_patients_congruency_contrasts(2,1,:,i,:),5)));
                p_ft_p(i) = 1-relRankIn_includeValue_lowerBound(squeeze(mean(all_random_patients_congruency_contrasts(1,2,i,:,:,:),6)),squeeze(mean(all_patients_congruency_contrasts(1,2,:,i,:),5)));
                if p_tf_p(i)<=0.05 || p_ft_p(i)>=0.95
                    plot(foi(i),0,'gp')
                end
                if p_ft_p(i)<=0.05 || p_ft_p(i)>=0.95
                    plot(foi(i),0,'bs')
                end
            end
            
            figure
            hold on
            plot(foi,squeeze(median(median(all_controls_congruency_contrasts(2,1,:,:,:),5),6)),'g:','LineWidth',7)
            plot(foi,squeeze(median(median(all_patients_congruency_contrasts(2,1,:,:,:),5),6)),'g--','LineWidth',7)
            plot(foi,squeeze(median(median(all_controls_congruency_contrasts(1,2,:,:,:),5),6)),'b:','LineWidth',7)
            plot(foi,squeeze(median(median(all_patients_congruency_contrasts(1,2,:,:,:),5),6)),'b--','LineWidth',7)
            plot(foi,squeeze(median(all_random_controls_congruency_contrasts(2,1,:,:,:,:),6)),'k:')
            plot(foi,squeeze(median(all_random_patients_congruency_contrasts(2,1,:,:,:,:),6)),'k--')
            plot(foi,squeeze(median(all_random_controls_congruency_contrasts(1,2,:,:,:,:),6)),'k:')
            plot(foi,squeeze(median(all_random_patients_congruency_contrasts(1,2,:,:,:,:),6)),'k--')
            plot(foi,squeeze(median(median(all_controls_congruency_contrasts(2,1,:,:,:),5),6)),'g:','LineWidth',7)
            plot(foi,squeeze(median(median(all_patients_congruency_contrasts(2,1,:,:,:),5),6)),'g--','LineWidth',7)
            plot(foi,squeeze(median(median(all_controls_congruency_contrasts(1,2,:,:,:),5),6)),'b:','LineWidth',7)
            plot(foi,squeeze(median(median(all_patients_congruency_contrasts(1,2,:,:,:),5),6)),'b--','LineWidth',7)
            title(['By group sig Median Mismatch-Match' analysis_type ])
            legend({'temp-front control','temp-front patient','front-temp control','front-temp patient'})
            for i = 1:35 %Rough initial parametric stats - better to use permutation
                p_tf_c(i) = 1-relRankIn_includeValue_lowerBound(squeeze(median(all_random_controls_congruency_contrasts(2,1,i,:,:,:),6)),squeeze(median(all_controls_congruency_contrasts(2,1,:,i,:),5)));
                p_ft_c(i) = 1-relRankIn_includeValue_lowerBound(squeeze(median(all_random_controls_congruency_contrasts(1,2,i,:,:,:),6)),squeeze(median(all_controls_congruency_contrasts(1,2,:,i,:),5)));
                if p_tf_c(i)<=0.05 || p_ft_c(i)>=0.95
                    plot(foi(i),0,'go')
                end
                if p_ft_c(i)<=0.05 || p_ft_c(i)>=0.95
                    plot(foi(i),0,'b.')
                end
                p_tf_p(i) = 1-relRankIn_includeValue_lowerBound(squeeze(median(all_random_patients_congruency_contrasts(2,1,i,:,:,:),6)),squeeze(median(all_patients_congruency_contrasts(2,1,:,i,:),5)));
                p_ft_p(i) = 1-relRankIn_includeValue_lowerBound(squeeze(median(all_random_patients_congruency_contrasts(1,2,i,:,:,:),6)),squeeze(median(all_patients_congruency_contrasts(1,2,:,i,:),5)));
                if p_tf_p(i)<=0.05 || p_ft_p(i)>=0.95
                    plot(foi(i),0,'gp')
                end
                if p_ft_p(i)<=0.05 || p_ft_p(i)>=0.95
                    plot(foi(i),0,'bs')
                end
            end
            
            figure
            hold on
            plot(foi,squeeze(median(mean(all_controls_interaction_contrasts(2,1,:,:,:),5),6)),'g:','LineWidth',7)
            plot(foi,squeeze(median(mean(all_patients_interaction_contrasts(2,1,:,:,:),5),6)),'g--','LineWidth',7)
            plot(foi,squeeze(median(mean(all_controls_interaction_contrasts(1,2,:,:,:),5),6)),'b:','LineWidth',7)
            plot(foi,squeeze(median(mean(all_patients_interaction_contrasts(1,2,:,:,:),5),6)),'b--','LineWidth',7)
            plot(foi,squeeze(mean(all_random_controls_interaction_contrasts(2,1,:,:,:,:),6)),'k:')
            plot(foi,squeeze(mean(all_random_patients_interaction_contrasts(2,1,:,:,:,:),6)),'k--')
            plot(foi,squeeze(mean(all_random_controls_interaction_contrasts(1,2,:,:,:,:),6)),'k:')
            plot(foi,squeeze(mean(all_random_patients_interaction_contrasts(1,2,:,:,:,:),6)),'k--')
            plot(foi,squeeze(median(mean(all_controls_interaction_contrasts(2,1,:,:,:),5),6)),'g:','LineWidth',7)
            plot(foi,squeeze(median(mean(all_patients_interaction_contrasts(2,1,:,:,:),5),6)),'g--','LineWidth',7)
            plot(foi,squeeze(median(mean(all_controls_interaction_contrasts(1,2,:,:,:),5),6)),'b:','LineWidth',7)
            plot(foi,squeeze(median(mean(all_patients_interaction_contrasts(1,2,:,:,:),5),6)),'b--','LineWidth',7)
            title(['By group Interaction ' analysis_type ])
            legend({'temp-front control','temp-front patient','front-temp control','front-temp patient'})
            for i = 1:35 %Rough initial parametric stats - better to use permutation
                p_tf_c(i) = 1-relRankIn_includeValue_lowerBound(squeeze(mean(all_random_controls_interaction_contrasts(2,1,i,:,:,:),6)),squeeze(mean(all_controls_interaction_contrasts(2,1,:,i,:),5)));
                p_ft_c(i) = 1-relRankIn_includeValue_lowerBound(squeeze(mean(all_random_controls_interaction_contrasts(1,2,i,:,:,:),6)),squeeze(mean(all_controls_interaction_contrasts(1,2,:,i,:),5)));
                if p_tf_c(i)<=0.05 || p_tf_c(i)>=0.95
                    plot(foi(i),0,'go')
                end
                if p_ft_c(i)<=0.05 || p_ft_c(i)>=0.95
                    plot(foi(i),0,'b.')
                end
                p_tf_p(i) = 1-relRankIn_includeValue_lowerBound(squeeze(mean(all_random_patients_interaction_contrasts(2,1,i,:,:,:),6)),squeeze(mean(all_patients_interaction_contrasts(2,1,:,i,:),5)));
                p_ft_p(i) = 1-relRankIn_includeValue_lowerBound(squeeze(mean(all_random_patients_interaction_contrasts(1,2,i,:,:,:),6)),squeeze(mean(all_patients_interaction_contrasts(1,2,:,i,:),5)));
                if p_tf_p(i)<=0.05 || p_ft_p(i)>=0.95
                    plot(foi(i),0,'gp')
                end
                if p_ft_p(i)<=0.05 || p_ft_p(i)>=0.95
                    plot(foi(i),0,'bs')
                end
            end
            
            figure
            hold on
            plot(foi,squeeze(median(mean(all_controls_clarity_contrasts(2,1,:,:,:),5),6)),'g:','LineWidth',7)
            plot(foi,squeeze(median(mean(all_patients_clarity_contrasts(2,1,:,:,:),5),6)),'g--','LineWidth',7)
            plot(foi,squeeze(median(mean(all_controls_clarity_contrasts(1,2,:,:,:),5),6)),'b:','LineWidth',7)
            plot(foi,squeeze(median(mean(all_patients_clarity_contrasts(1,2,:,:,:),5),6)),'b--','LineWidth',7)
            plot(foi,squeeze(mean(all_random_controls_clarity_contrasts(2,1,:,:,:,:),6)),'k:')
            plot(foi,squeeze(mean(all_random_patients_clarity_contrasts(2,1,:,:,:,:),6)),'k--')
            plot(foi,squeeze(mean(all_random_controls_clarity_contrasts(1,2,:,:,:,:),6)),'k:')
            plot(foi,squeeze(mean(all_random_patients_clarity_contrasts(1,2,:,:,:,:),6)),'k--')
            plot(foi,squeeze(median(mean(all_controls_clarity_contrasts(2,1,:,:,:),5),6)),'g:','LineWidth',7)
            plot(foi,squeeze(median(mean(all_patients_clarity_contrasts(2,1,:,:,:),5),6)),'g--','LineWidth',7)
            plot(foi,squeeze(median(mean(all_controls_clarity_contrasts(1,2,:,:,:),5),6)),'b:','LineWidth',7)
            plot(foi,squeeze(median(mean(all_patients_clarity_contrasts(1,2,:,:,:),5),6)),'b--','LineWidth',7)
            title(['By group Clarity ' analysis_type ])
            legend({'temp-front control','temp-front patient','front-temp control','front-temp patient'})
            for i = 1:35 %Rough initial parametric stats - better to use permutation
                p_tf_c(i) = 1-relRankIn_includeValue_lowerBound(squeeze(mean(all_random_controls_clarity_contrasts(2,1,i,:,:,:),6)),squeeze(mean(all_controls_clarity_contrasts(2,1,:,i,:),5)));
                p_ft_c(i) = 1-relRankIn_includeValue_lowerBound(squeeze(mean(all_random_controls_clarity_contrasts(1,2,i,:,:,:),6)),squeeze(mean(all_controls_clarity_contrasts(1,2,:,i,:),5)));
                if p_tf_c(i)<=0.05 || p_tf_c(i)>=0.95
                    plot(foi(i),0,'go')
                end
                if p_ft_c(i)<=0.05 || p_ft_c(i)>=0.95
                    plot(foi(i),0,'b.')
                end
                p_tf_p(i) = 1-relRankIn_includeValue_lowerBound(squeeze(mean(all_random_patients_clarity_contrasts(2,1,i,:,:,:),6)),squeeze(mean(all_patients_clarity_contrasts(2,1,:,i,:),5)));
                p_ft_p(i) = 1-relRankIn_includeValue_lowerBound(squeeze(mean(all_random_patients_clarity_contrasts(1,2,i,:,:,:),6)),squeeze(mean(all_patients_clarity_contrasts(1,2,:,i,:),5)));
                if p_tf_p(i)<=0.05 || p_ft_p(i)>=0.95
                    plot(foi(i),0,'gp')
                end
                if p_ft_p(i)<=0.05 || p_ft_p(i)>=0.95
                    plot(foi(i),0,'bs')
                end
            end
%             
            
%         case 'icoh'
%             
%             figure
%             plot(foi,squeeze(mean(mean(abs(all_granger_data(2,1,:,:,:,:)),5),6)),'g','LineWidth',7)
%             hold on
%             plot(foi,squeeze(mean(mean(abs(all_granger_data(1,2,:,:,:,:)),5),6)),'b','LineWidth',7)
%             plot(foi,squeeze(mean(mean(abs(all_random_granger_data(2,1,:,:,:,:,:)),5),7)),'k')
%             plot(foi,squeeze(mean(mean(abs(all_random_granger_data(1,2,:,:,:,:,:)),5),7)),'k')
%             plot(foi,squeeze(mean(mean(abs(all_granger_data(2,1,:,:,:,:)),5),6)),'g','LineWidth',7)
%             plot(foi,squeeze(mean(mean(abs(all_granger_data(1,2,:,:,:,:)),5),6)),'b','LineWidth',7)
%             
%             title(['All abs ' analysis_type ' time ' num2str(start_times) '-' num2str(end_times)])
%             legend({'temp-front','front-temp'})
%             for i = 1:35 %Compare across group permutation
%                 p_tf(i) = 1-relRankIn_includeValue_lowerBound(squeeze(mean(mean(abs(all_random_granger_data(2,1,:,i,:,:,:)),5),7)),squeeze(mean(mean(abs(all_granger_data(2,1,:,i,:,:)),5),6)))
%                 p_ft(i) = 1-relRankIn_includeValue_lowerBound(squeeze(mean(mean(abs(all_random_granger_data(1,2,:,i,:,:,:)),5),7)),squeeze(mean(mean(abs(all_granger_data(1,2,:,i,:,:)),5),6)))
%                 if p_tf(i)<=0.05 || p_tf(i)>=0.95
%                     plot(foi(i),0,'g*')
%                 end
%                 if p_ft(i)<=0.05 || p_ft(i)>=0.95
%                     plot(foi(i),0,'bx')
%                 end
%             end
%             
%             figure
%             plot(foi,squeeze(median(mean(abs(all_granger_data(2,1,:,:,:,:)),5),6)),'g','LineWidth',7)
%             hold on
%             plot(foi,squeeze(median(mean(abs(all_granger_data(1,2,:,:,:,:)),5),6)),'b','LineWidth',7)
%             plot(foi,squeeze(median(mean(abs(all_random_granger_data(2,1,:,:,:,:,:)),5),7)),'k')
%             plot(foi,squeeze(median(mean(abs(all_random_granger_data(1,2,:,:,:,:,:)),5),7)),'k')
%             plot(foi,squeeze(median(mean(abs(all_granger_data(2,1,:,:,:,:)),5),6)),'g','LineWidth',7)
%             plot(foi,squeeze(median(mean(abs(all_granger_data(1,2,:,:,:,:)),5),6)),'b','LineWidth',7)
%             
%             title(['All median ' analysis_type ' time ' num2str(start_times) '-' num2str(end_times)])
%             legend({'temp-front','front-temp'})
%             for i = 1:35 %Compare across group permutation
%                 p_tf(i) = 1-relRankIn_includeValue_lowerBound(squeeze(median(mean(abs(all_random_granger_data(2,1,:,i,:,:,:)),5),7)),squeeze(median(mean(abs(all_granger_data(2,1,:,i,:,:)),5),6)))
%                 p_ft(i) = 1-relRankIn_includeValue_lowerBound(squeeze(median(mean(abs(all_random_granger_data(1,2,:,i,:,:,:)),5),7)),squeeze(median(mean(abs(all_granger_data(1,2,:,i,:,:)),5),6)))
%                 if p_tf(i)<=0.05 || p_tf(i)>=0.95
%                     plot(foi(i),0,'g*')
%                 end
%                 if p_ft(i)<=0.05 || p_ft(i)>=0.95
%                     plot(foi(i),0,'bx')
%                 end
%             end
%             
%             figure
%             hold on
%             plot(foi,squeeze(mean(mean(abs(all_controls_granger_data(2,1,:,:,:,:)),5),6)),'g:','LineWidth',7)
%             plot(foi,squeeze(mean(mean(abs(all_patients_granger_data(2,1,:,:,:,:)),5),6)),'g--','LineWidth',7)
%             plot(foi,squeeze(mean(mean(abs(all_controls_granger_data(1,2,:,:,:,:)),5),6)),'b:','LineWidth',7)
%             plot(foi,squeeze(mean(mean(abs(all_patients_granger_data(1,2,:,:,:,:)),5),6)),'b--','LineWidth',7)
%             legend({'temp-front control','temp-front patient','front-temp control','front-temp patient'})
%             title(['By group ' analysis_type ' time ' num2str(start_times) '-' num2str(end_times)])
%             for i = 1:35 %Rough initial parametric stats - better to use permutation
%                 [h_tf(i) p_tf(i)] = ttest2(mean(abs(all_controls_granger_data(2,1,:,i,:,:)),5),mean(abs(all_patients_granger_data(2,1,:,i,:,:)),5));
%                 [h_ft(i) p_ft(i)] = ttest2(mean(abs(all_controls_granger_data(1,2,:,i,:,:)),5),mean(abs(all_patients_granger_data(1,2,:,i,:,:)),5));
%                 if h_tf(i) == 1
%                     plot(foi(i),0,'g*')
%                 end
%                 if h_ft(i) == 1
%                     plot(foi(i),0,'bx')
%                 end
%             end
%             
%             figure
%             hold on
%             plot(foi,squeeze(median(mean(abs(all_controls_granger_data(2,1,:,:,:,:)),5),6)),'g:','LineWidth',7)
%             plot(foi,squeeze(median(mean(abs(all_patients_granger_data(2,1,:,:,:,:)),5),6)),'g--','LineWidth',7)
%             plot(foi,squeeze(median(mean(abs(all_controls_granger_data(1,2,:,:,:,:)),5),6)),'b:','LineWidth',7)
%             plot(foi,squeeze(median(mean(abs(all_patients_granger_data(1,2,:,:,:,:)),5),6)),'b--','LineWidth',7)
%             legend({'temp-front control','temp-front patient','front-temp control','front-temp patient'})
%             title(['By group median ' analysis_type ' time ' num2str(start_times) '-' num2str(end_times)])
%             for i = 1:35 %Rough initial parametric stats - better to use permutation
%                 [p_tf(i) h_tf(i)] = ranksum(squeeze(mean(abs(all_controls_granger_data(2,1,:,i,:,:)),5)),squeeze(mean(abs(all_patients_granger_data(2,1,:,i,:,:)),5)));
%                 [p_ft(i) h_ft(i)] = ranksum(squeeze(mean(abs(all_controls_granger_data(1,2,:,i,:,:)),5)),squeeze(mean(abs(all_patients_granger_data(1,2,:,i,:,:)),5)));
%                 if h_tf(i) == 1
%                     plot(foi(i),0,'g*')
%                 end
%                 if h_ft(i) == 1
%                     plot(foi(i),0,'bx')
%                 end
%             end
%             
%             config = figure;
%             patfig = figure;
%             this_con = 0;
%             this_pat = 0;
%             
%             for s = 1:length(group)
%                 if group(s) == 1
%                     this_con = this_con+1;
%                     figure(config);
%                     h = subplot(4,3,this_con);
%                     plot(foi,squeeze(mean(abs(all_granger_data(2,1,:,:,:,s)),5)),'g','LineWidth',7)
%                     hold on
%                     plot(foi,squeeze(mean(abs(all_granger_data(1,2,:,:,:,s)),5)),'b','LineWidth',7)
%                     for i = 1:35 %Compare within subj permutation
%                         p_tf(i) = 1-relRankIn_includeValue_lowerBound(squeeze(mean(abs(all_random_granger_data(2,1,:,i,:,:,s)),5)),squeeze(mean(abs(all_granger_data(2,1,:,i,:,s)),5)));
%                         p_ft(i) = 1-relRankIn_includeValue_lowerBound(squeeze(mean(abs(all_random_granger_data(1,2,:,i,:,:,s)),5)),squeeze(mean(abs(all_granger_data(1,2,:,i,:,s)),5)));
%                         if p_tf(i)<=0.05 || p_tf(i)>=0.95
%                             plot(foi(i),0,'g*')
%                         end
%                         if p_ft(i)<=0.05 || p_ft(i)>=0.95
%                             plot(foi(i),0,'bx')
%                         end
%                     end
%                     
%                 elseif group(s) == 2
%                     this_pat = this_pat+1;
%                     figure(patfig);
%                     h = subplot(4,3,this_pat);
%                     plot(foi,squeeze(mean(abs(all_granger_data(2,1,:,:,:,s)),5)),'g','LineWidth',7)
%                     hold on
%                     plot(foi,squeeze(mean(abs(all_granger_data(1,2,:,:,:,s)),5)),'b','LineWidth',7)
%                     for i = 1:35 %Compare within subj permutation
%                         p_tf(i) = 1-relRankIn_includeValue_lowerBound(squeeze(mean(abs(all_random_granger_data(2,1,:,i,:,:,s)),5)),squeeze(mean(abs(all_granger_data(2,1,:,i,:,s)),5)));
%                         p_ft(i) = 1-relRankIn_includeValue_lowerBound(squeeze(mean(abs(all_random_granger_data(1,2,:,i,:,:,s)),5)),squeeze(mean(abs(all_granger_data(1,2,:,i,:,s)),5)));
%                         if p_tf(i)<=0.05 || p_tf(i)>=0.95
%                             plot(foi(i),0,'g*')
%                         end
%                         if p_ft(i)<=0.05 || p_ft(i)>=0.95
%                             plot(foi(i),0,'bx')
%                         end
%                     end
%                 end
%             end
%             figure(config)
%             title(['Controls ' analysis_type ' time ' num2str(start_times) '-' num2str(end_times)])
%             figure(patfig)
%             title(['Patients ' analysis_type ' time ' num2str(start_times) '-' num2str(end_times)])
%             
%             
%             figure
%             plot(foi,squeeze(mean(all_absolute_congruency_contrasts(2,1,:,:,:),5)),'g','LineWidth',7)
%             hold on
%             plot(foi,squeeze(mean(all_absolute_congruency_contrasts(1,2,:,:,:),5)),'b','LineWidth',7)
%             plot(foi,squeeze(mean(all_absolute_random_congruency_contrasts(2,1,:,:,:,:),6)),'k')
%             plot(foi,squeeze(mean(all_absolute_random_congruency_contrasts(1,2,:,:,:,:),6)),'k')
%             plot(foi,squeeze(mean(all_absolute_congruency_contrasts(2,1,:,:,:),5)),'g','LineWidth',7)
%             
%             plot(foi,squeeze(mean(all_absolute_congruency_contrasts(1,2,:,:,:),5)),'b','LineWidth',7)
%             
%             title(['All MisMatch-Match ' analysis_type ' time ' num2str(start_times) '-' num2str(end_times)])
%             legend({'temp-front','front-temp'})
%             for i = 1:35 %Compare across group permutation
%                 p_tf(i) = 1-relRankIn_includeValue_lowerBound(squeeze(mean(all_absolute_random_congruency_contrasts(2,1,:,i,:,:),6)),squeeze(mean(all_absolute_congruency_contrasts(2,1,:,i,:),5)));
%                 p_ft(i) = 1-relRankIn_includeValue_lowerBound(squeeze(mean(all_absolute_random_congruency_contrasts(1,2,:,i,:,:),6)),squeeze(mean(all_absolute_congruency_contrasts(1,2,:,i,:),5)));
%                 if p_tf(i)<=0.05 || p_tf(i)>=0.95
%                     plot(foi(i),0,'g*')
%                 end
%                 if p_ft(i)<=0.05 || p_ft(i)>=0.95
%                     plot(foi(i),0,'bx')
%                 end
%             end
%             
%             figure
%             plot(foi,squeeze(median(all_absolute_congruency_contrasts(2,1,:,:,:),5)),'g','LineWidth',7)
%             hold on
%             plot(foi,squeeze(median(all_absolute_congruency_contrasts(1,2,:,:,:),5)),'b','LineWidth',7)
%             plot(foi,squeeze(median(all_absolute_random_congruency_contrasts(2,1,:,:,:,:),6)),'k')
%             plot(foi,squeeze(median(all_absolute_random_congruency_contrasts(1,2,:,:,:,:),6)),'k')
%             plot(foi,squeeze(median(all_absolute_congruency_contrasts(2,1,:,:,:),5)),'g','LineWidth',7)
%             
%             plot(foi,squeeze(median(all_absolute_congruency_contrasts(1,2,:,:,:),5)),'b','LineWidth',7)
%            
%             title(['All median MisMatch-Match ' analysis_type ' time ' num2str(start_times) '-' num2str(end_times)])
%             legend({'temp-front','front-temp'})
%             for i = 1:35 %Compare across group permutation
%                 p_tf(i) = 1-relRankIn_includeValue_lowerBound(squeeze(median(all_absolute_random_congruency_contrasts(2,1,:,i,:,:),6)),squeeze(median(all_absolute_congruency_contrasts(2,1,:,i,:),5)));
%                 p_ft(i) = 1-relRankIn_includeValue_lowerBound(squeeze(median(all_absolute_random_congruency_contrasts(1,2,:,i,:,:),6)),squeeze(median(all_absolute_congruency_contrasts(1,2,:,i,:),5)));
%                 if p_tf(i)<=0.05 || p_tf(i)>=0.95
%                     plot(foi(i),0,'g*')
%                 end
%                 if p_ft(i)<=0.05 || p_ft(i)>=0.95
%                     plot(foi(i),0,'bx')
%                 end
%             end
%             
%             figure
%             plot(foi,squeeze(mean(all_absolute_clarity_contrasts(2,1,:,:,:),5)),'g','LineWidth',7)
%             hold on
%             plot(foi,squeeze(mean(all_absolute_clarity_contrasts(1,2,:,:,:),5)),'b','LineWidth',7)
%             plot(foi,squeeze(mean(all_absolute_random_clarity_contrasts(2,1,:,:,:,:),6)),'k')
%             plot(foi,squeeze(mean(all_absolute_random_clarity_contrasts(1,2,:,:,:,:),6)),'k')
%             plot(foi,squeeze(mean(all_absolute_clarity_contrasts(2,1,:,:,:),5)),'g','LineWidth',7)
%             
%             plot(foi,squeeze(mean(all_absolute_clarity_contrasts(1,2,:,:,:),5)),'b','LineWidth',7)
%            
%             title(['All Clear-Unclear ' analysis_type ' time ' num2str(start_times) '-' num2str(end_times)])
%             legend({'temp-front','front-temp'})
%             for i = 1:35 %Compare across group permutation
%                 p_tf(i) = 1-relRankIn_includeValue_lowerBound(squeeze(mean(all_absolute_random_clarity_contrasts(2,1,:,i,:,:),6)),squeeze(mean(all_absolute_clarity_contrasts(2,1,:,i,:),5)));
%                 p_ft(i) = 1-relRankIn_includeValue_lowerBound(squeeze(mean(all_absolute_random_clarity_contrasts(1,2,:,i,:,:),6)),squeeze(mean(all_absolute_clarity_contrasts(1,2,:,i,:),5)));
%                 if p_tf(i)<=0.05 || p_tf(i)>=0.95
%                     plot(foi(i),0,'g*')
%                 end
%                 if p_ft(i)<=0.05 || p_ft(i)>=0.95
%                     plot(foi(i),0,'bx')
%                 end
%             end
%             
%             figure
%             plot(foi,squeeze(median(all_absolute_clarity_contrasts(2,1,:,:,:),5)),'g','LineWidth',7)
%             hold on
%             plot(foi,squeeze(median(all_absolute_clarity_contrasts(1,2,:,:,:),5)),'b','LineWidth',7)
%             plot(foi,squeeze(median(all_absolute_random_clarity_contrasts(2,1,:,:,:,:),6)),'k')
%             plot(foi,squeeze(median(all_absolute_random_clarity_contrasts(1,2,:,:,:,:),6)),'k')
%             plot(foi,squeeze(median(all_absolute_clarity_contrasts(2,1,:,:,:),5)),'g','LineWidth',7)
%             
%             plot(foi,squeeze(median(all_absolute_clarity_contrasts(1,2,:,:,:),5)),'b','LineWidth',7)
%            
%             title(['All median Clear-Unclear ' analysis_type ' time ' num2str(start_times) '-' num2str(end_times)])
%             legend({'temp-front','front-temp'})
%             for i = 1:35 %Compare across group permutation
%                 p_tf(i) = 1-relRankIn_includeValue_lowerBound(squeeze(median(all_absolute_random_clarity_contrasts(2,1,:,i,:,:),6)),squeeze(median(all_absolute_clarity_contrasts(2,1,:,i,:),5)));
%                 p_ft(i) = 1-relRankIn_includeValue_lowerBound(squeeze(median(all_absolute_random_clarity_contrasts(1,2,:,i,:,:),6)),squeeze(median(all_absolute_clarity_contrasts(1,2,:,i,:),5)));
%                 if p_tf(i)<=0.05 || p_tf(i)>=0.95
%                     plot(foi(i),0,'g*')
%                 end
%                 if p_ft(i)<=0.05 || p_ft(i)>=0.95
%                     plot(foi(i),0,'bx')
%                 end
%             end
%             
%             figure
%             plot(foi,squeeze(mean(all_absolute_interaction_contrasts(2,1,:,:,:),5)),'g','LineWidth',7)
%             hold on
%             plot(foi,squeeze(mean(all_absolute_interaction_contrasts(1,2,:,:,:),5)),'b','LineWidth',7)
%             title(['All Interaction ' analysis_type ' time ' num2str(start_times) '-' num2str(end_times)])
%             legend({'temp-front','front-temp'})
%             for i = 1:35 %Compare across group permutation
%                 p_tf(i) = 1-relRankIn_includeValue_lowerBound(squeeze(mean(all_absolute_random_interaction_contrasts(2,1,:,i,:,:),6)),squeeze(mean(all_absolute_interaction_contrasts(2,1,:,i,:),5)));
%                 p_ft(i) = 1-relRankIn_includeValue_lowerBound(squeeze(mean(all_absolute_random_interaction_contrasts(1,2,:,i,:,:),6)),squeeze(mean(all_absolute_interaction_contrasts(1,2,:,i,:),5)));
%                 if p_tf(i)<=0.05 || p_tf(i)>=0.95
%                     plot(foi(i),0,'g*')
%                 end
%                 if p_ft(i)<=0.05 || p_ft(i)>=0.95
%                     plot(foi(i),0,'bx')
%                 end
%             end
%             
%             figure
%             plot(foi,squeeze(median(all_absolute_interaction_contrasts(2,1,:,:,:),5)),'g','LineWidth',7)
%             hold on
%             plot(foi,squeeze(median(all_absolute_interaction_contrasts(1,2,:,:,:),5)),'b','LineWidth',7)
%             title(['All median Interaction ' analysis_type ' time ' num2str(start_times) '-' num2str(end_times)])
%             legend({'temp-front','front-temp'})
%             for i = 1:35 %Compare across group permutation
%                 p_tf(i) = 1-relRankIn_includeValue_lowerBound(squeeze(median(all_absolute_random_interaction_contrasts(2,1,:,i,:,:),6)),squeeze(median(all_absolute_interaction_contrasts(2,1,:,i,:),5)));
%                 p_ft(i) = 1-relRankIn_includeValue_lowerBound(squeeze(median(all_absolute_random_interaction_contrasts(1,2,:,i,:,:),6)),squeeze(median(all_absolute_interaction_contrasts(1,2,:,i,:),5)));
%                 if p_tf(i)<=0.05 || p_tf(i)>=0.95
%                     plot(foi(i),0,'g*')
%                 end
%                 if p_ft(i)<=0.05 || p_ft(i)>=0.95
%                     plot(foi(i),0,'bx')
%                 end
%             end
%             
%             figure
%             hold on
%             plot(foi,squeeze(mean(mean(all_absolute_controls_congruency_contrasts(2,1,:,:,:),5),6)),'g:','LineWidth',7)
%             plot(foi,squeeze(mean(mean(all_absolute_patients_congruency_contrasts(2,1,:,:,:),5),6)),'g--','LineWidth',7)
%             plot(foi,squeeze(mean(mean(all_absolute_controls_congruency_contrasts(1,2,:,:,:),5),6)),'b:','LineWidth',7)
%             plot(foi,squeeze(mean(mean(all_absolute_patients_congruency_contrasts(1,2,:,:,:),5),6)),'b--','LineWidth',7)
% 
%             title(['Group by Mean Mismatch-Match' analysis_type ])
%             legend({'temp-front control','temp-front patient','front-temp control','front-temp patient'})
%             for i = 1:35 %Rough initial parametric stats - better to use permutation
%                 [p_tf(i) h_tf(i)] = ttest2(squeeze(all_absolute_patients_congruency_contrasts(2,1,:,i,:)),squeeze(all_absolute_controls_congruency_contrasts(2,1,:,i,:)));
%                 [p_ft(i) h_ft(i)] = ttest2(squeeze(all_absolute_patients_congruency_contrasts(1,2,:,i,:)),squeeze(all_absolute_controls_congruency_contrasts(1,2,:,i,:)));
%                 if h_tf(i) == 1
%                     plot(foi(i),0,'g*')
%                 end
%                 if h_ft(i) == 1
%                     plot(foi(i),0,'bx')
%                 end
%             end
%             
%             figure
%             hold on
%             plot(foi,squeeze(median(median(all_absolute_controls_congruency_contrasts(2,1,:,:,:),5),6)),'g:','LineWidth',7)
%             plot(foi,squeeze(median(median(all_absolute_patients_congruency_contrasts(2,1,:,:,:),5),6)),'g--','LineWidth',7)
%             plot(foi,squeeze(median(median(all_absolute_controls_congruency_contrasts(1,2,:,:,:),5),6)),'b:','LineWidth',7)
%             plot(foi,squeeze(median(median(all_absolute_patients_congruency_contrasts(1,2,:,:,:),5),6)),'b--','LineWidth',7)
% 
%             title(['Group by Median Mismatch-Match' analysis_type ])
%             legend({'temp-front control','temp-front patient','front-temp control','front-temp patient'})
%             for i = 1:35 %Rough initial parametric stats - better to use permutation
%                 [p_tf(i) h_tf(i)] = ranksum(squeeze(all_absolute_patients_congruency_contrasts(2,1,:,i,:)),squeeze(all_absolute_controls_congruency_contrasts(2,1,:,i,:)));
%                 [p_ft(i) h_ft(i)] = ranksum(squeeze(all_absolute_patients_congruency_contrasts(1,2,:,i,:)),squeeze(all_absolute_controls_congruency_contrasts(1,2,:,i,:)));
%                 if h_tf(i) == 1
%                     plot(foi(i),0,'g*')
%                 end
%                 if h_ft(i) == 1
%                     plot(foi(i),0,'bx')
%                 end
%             end
%             
%             figure
%             hold on
%             plot(foi,squeeze(mean(mean(all_absolute_controls_congruency_contrasts(2,1,:,:,:),5),6)),'g:','LineWidth',7)
%             plot(foi,squeeze(mean(mean(all_absolute_patients_congruency_contrasts(2,1,:,:,:),5),6)),'g--','LineWidth',7)
%             plot(foi,squeeze(mean(mean(all_absolute_controls_congruency_contrasts(1,2,:,:,:),5),6)),'b:','LineWidth',7)
%             plot(foi,squeeze(mean(mean(all_absolute_patients_congruency_contrasts(1,2,:,:,:),5),6)),'b--','LineWidth',7)
%             plot(foi,squeeze(mean(all_absolute_random_controls_congruency_contrasts(2,1,:,:,:,:),6)),'k:')
%             plot(foi,squeeze(mean(all_absolute_random_patients_congruency_contrasts(2,1,:,:,:,:),6)),'k--')
%             plot(foi,squeeze(mean(all_absolute_random_controls_congruency_contrasts(1,2,:,:,:,:),6)),'k:')
%             plot(foi,squeeze(mean(all_absolute_random_patients_congruency_contrasts(1,2,:,:,:,:),6)),'k--')
%             plot(foi,squeeze(mean(mean(all_absolute_controls_congruency_contrasts(2,1,:,:,:),5),6)),'g:','LineWidth',7)
%             plot(foi,squeeze(mean(mean(all_absolute_patients_congruency_contrasts(2,1,:,:,:),5),6)),'g--','LineWidth',7)
%             plot(foi,squeeze(mean(mean(all_absolute_controls_congruency_contrasts(1,2,:,:,:),5),6)),'b:','LineWidth',7)
%             plot(foi,squeeze(mean(mean(all_absolute_patients_congruency_contrasts(1,2,:,:,:),5),6)),'b--','LineWidth',7)
%             
%             title(['By group sig Mean Mismatch-Match' analysis_type ])
%             legend({'temp-front control','temp-front patient','front-temp control','front-temp patient'})
%             for i = 1:35 %Rough initial parametric stats - better to use permutation
%                 p_tf_c(i) = 1-relRankIn_includeValue_lowerBound(squeeze(mean(all_absolute_random_controls_congruency_contrasts(2,1,i,:,:,:),6)),squeeze(mean(all_absolute_controls_congruency_contrasts(2,1,:,i,:),5)));
%                 p_ft_c(i) = 1-relRankIn_includeValue_lowerBound(squeeze(mean(all_absolute_random_controls_congruency_contrasts(1,2,i,:,:,:),6)),squeeze(mean(all_absolute_controls_congruency_contrasts(1,2,:,i,:),5)));
%                 if p_tf_c(i)<=0.05 || p_ft_p(i)>=0.95
%                     plot(foi(i),0,'go')
%                 end
%                 if p_ft_c(i)<=0.05 || p_ft_c(i)>=0.95
%                     plot(foi(i),0,'b.')
%                 end
%                 p_tf_p(i) = 1-relRankIn_includeValue_lowerBound(squeeze(mean(all_absolute_random_patients_congruency_contrasts(2,1,i,:,:,:),6)),squeeze(mean(all_absolute_patients_congruency_contrasts(2,1,:,i,:),5)));
%                 p_ft_p(i) = 1-relRankIn_includeValue_lowerBound(squeeze(mean(all_absolute_random_patients_congruency_contrasts(1,2,i,:,:,:),6)),squeeze(mean(all_absolute_patients_congruency_contrasts(1,2,:,i,:),5)));
%                 if p_tf_p(i)<=0.05 || p_ft_p(i)>=0.95
%                     plot(foi(i),0,'gp')
%                 end
%                 if p_ft_p(i)<=0.05 || p_ft_p(i)>=0.95
%                     plot(foi(i),0,'bs')
%                 end
%             end
%             
%             figure
%             hold on
%             plot(foi,squeeze(median(median(all_absolute_controls_congruency_contrasts(2,1,:,:,:),5),6)),'g:','LineWidth',7)
%             plot(foi,squeeze(median(median(all_absolute_patients_congruency_contrasts(2,1,:,:,:),5),6)),'g--','LineWidth',7)
%             plot(foi,squeeze(median(median(all_absolute_controls_congruency_contrasts(1,2,:,:,:),5),6)),'b:','LineWidth',7)
%             plot(foi,squeeze(median(median(all_absolute_patients_congruency_contrasts(1,2,:,:,:),5),6)),'b--','LineWidth',7)
%             plot(foi,squeeze(median(all_absolute_random_controls_congruency_contrasts(2,1,:,:,:,:),6)),'k:')
%             plot(foi,squeeze(median(all_absolute_random_patients_congruency_contrasts(2,1,:,:,:,:),6)),'k--')
%             plot(foi,squeeze(median(all_absolute_random_controls_congruency_contrasts(1,2,:,:,:,:),6)),'k:')
%             plot(foi,squeeze(median(all_absolute_random_patients_congruency_contrasts(1,2,:,:,:,:),6)),'k--')
%             plot(foi,squeeze(median(median(all_absolute_controls_congruency_contrasts(2,1,:,:,:),5),6)),'g:','LineWidth',7)
%             plot(foi,squeeze(median(median(all_absolute_patients_congruency_contrasts(2,1,:,:,:),5),6)),'g--','LineWidth',7)
%             plot(foi,squeeze(median(median(all_absolute_controls_congruency_contrasts(1,2,:,:,:),5),6)),'b:','LineWidth',7)
%             plot(foi,squeeze(median(median(all_absolute_patients_congruency_contrasts(1,2,:,:,:),5),6)),'b--','LineWidth',7)
%             
%             title(['By group sig Median Mismatch-Match' analysis_type ])
%             legend({'temp-front control','temp-front patient','front-temp control','front-temp patient'})
%             for i = 1:35 %Rough initial parametric stats - better to use permutation
%                 p_tf_c(i) = 1-relRankIn_includeValue_lowerBound(squeeze(median(all_absolute_random_controls_congruency_contrasts(2,1,i,:,:,:),6)),squeeze(median(all_absolute_controls_congruency_contrasts(2,1,:,i,:),5)));
%                 p_ft_c(i) = 1-relRankIn_includeValue_lowerBound(squeeze(median(all_absolute_random_controls_congruency_contrasts(1,2,i,:,:,:),6)),squeeze(median(all_absolute_controls_congruency_contrasts(1,2,:,i,:),5)));
%                 if p_tf_c(i)<=0.05 || p_ft_p(i)>=0.95
%                     plot(foi(i),0,'go')
%                 end
%                 if p_ft_c(i)<=0.05 || p_ft_c(i)>=0.95
%                     plot(foi(i),0,'b.')
%                 end
%                 p_tf_p(i) = 1-relRankIn_includeValue_lowerBound(squeeze(median(all_absolute_random_patients_congruency_contrasts(2,1,i,:,:,:),6)),squeeze(median(all_absolute_patients_congruency_contrasts(2,1,:,i,:),5)));
%                 p_ft_p(i) = 1-relRankIn_includeValue_lowerBound(squeeze(median(all_absolute_random_patients_congruency_contrasts(1,2,i,:,:,:),6)),squeeze(median(all_absolute_patients_congruency_contrasts(1,2,:,i,:),5)));
%                 if p_tf_p(i)<=0.05 || p_ft_p(i)>=0.95
%                     plot(foi(i),0,'gp')
%                 end
%                 if p_ft_p(i)<=0.05 || p_ft_p(i)>=0.95
%                     plot(foi(i),0,'bs')
%                 end
%             end
%             
%     end
    
end