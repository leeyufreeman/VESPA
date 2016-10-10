%% Set up global variables

es_batch_init; 

%% Specify preprocessing parameters

%p.mod = {'MEG'}; % imaging modality (used by 'convert','convert+epoch','image','smooth','mask','firstlevel' steps)
%p.mod = {'MEGPLANAR'}; % imaging modality (used by 'convert','convert+epoch','image','smooth','mask','firstlevel' steps)
%p.mod = {'EEG'}; % imaging modality (used by 'convert','convert+epoch','image','smooth','mask','firstlevel' steps)
p.mod = {'MEG' 'MEGPLANAR' 'EEG'}; % imaging modality (used by 'convert','convert+epoch','image','smooth','mask','firstlevel' steps)
%p.mod = {'Source'};

% cell array of experimental conditions (used by 'definetrials','convert+epoch' and 'sort' steps)
p.conditions = conditions;

%p.montage_fname = 'es_montage_MEG.mat'; % channel montage (used by 'convert','convert+epoch','artifact_ft','rereference' steps)
%p.montage_fname = 'es_montage_MEGPLANAR.mat'; % channel montage (used by 'convert','convert+epoch','artifact_ft','rereference' steps)
%p.montage_fname = 'es_montage_EEG.mat'; % channel montage (used by 'convert','convert+epoch','artifact_ft','rereference' steps)
p.montage_fname = 'es_montage_all.mat'; % channel montage (used by 'convert','convert+epoch','artifact_ft','rereference' steps)

p.fs = 1000; % original sample rate
p.fs_new = 250; % sample rate after downsampling in SPM (currently assumes that maxfilter HASN't downsampled data)

% for trial definitions
p.preEpoch = -500; % pre stimulus time (ms)
p.postEpoch = 1500; % post stimulus time (ms)
p.triggers = [2 1 5 4 8 7]; % trigger values (correspond to p.conditions specified above)
p.delay = 32; % delay time (ms) between trigger and stimulus
p.minduration = 950; % if using definetrials_jp, minimum duration of a trial (ms)
p.maxduration = 1150; % if using definetrials_jp, maximum duration of a trial (ms)
%p.stimuli_list_fname = 'stimuli_list.txt';

% for averaging
p.robust = 1;

% for baseline correction
p.preBase = -100; % pre baseline time (ms)
p.postBase = 0; % post baseline time (ms)

% for combining planar gradiometer data
p.correctPlanar = 0; % whether to baseline correct planar gradiometer data after RMSing (using baseline period specified in preBase and postBase)

% for filtering
p.filter = 'low'; % type of filter (lowpass or highpass)- never bandpass!
p.freq = 40; % filter cutoff (Hz)
%p.filter = 'high'; % type of filter (lowpass or highpass)- never bandpass!
%p.freq = 0.5; % filter cutoff (Hz)
%p.filter = 'stop';
%p.freq = [48 52];

% for computing contrasts of grand averaged MEEG data
p.contrast_labels = contrast_labels;
p.contrast_weights = contrast_weights;

% for image smoothing
p.xSmooth = 10; % smooth for x dimension (mm)
p.ySmooth = 10; % smooth for y dimension (mm)
p.zSmooth = 25; % smooth for z (time) dimension (ms)

% for making image mask
p.preImageMask = 0; % pre image time (ms)
p.postImageMask = 800; % post image time (ms)

% time windows over which to average for 'first-level' contrasts (ms)
p.windows = [80 120; 170 230; 260 420; 450 700;];

%% Event-related preprocessing steps

% note: should high-pass filter or baseline-correct before lowpass fitering
% to avoid ringing artefacts

cbupool(size(subjects,2));

parfor cnt = 1:size(subjects,2)
   
es_preprocess_parallel('definetrials','maxfilter',p,pathstem,subjects{cnt});
es_preprocess_parallel('convert+epoch','maxfilter',p,pathstem,subjects{cnt},dates,blocksin,blocksout,rawpathstem,badeeg);
es_preprocess_parallel('downsample','convert',p,pathstem,subjects{cnt});
es_preprocess_parallel('rereference','downsample',p,pathstem,subjects{cnt});
es_preprocess_parallel('baseline','rereference',p,pathstem,subjects{cnt});
es_preprocess_parallel('filter','baseline',p,pathstem,subjects{cnt});
es_preprocess_parallel('merge','filter',p,pathstem,subjects{cnt});
es_preprocess_parallel('sort','merge',p,pathstem,subjects{cnt});
es_preprocess_parallel('average','merge',p,pathstem,subjects{cnt});
es_preprocess_parallel('filter','average',p,pathstem,subjects{cnt});


%es_preprocess_parallel('combineplanar','fm*.mat',p,pathstem,subjects{cnt});
%es_preprocess_parallel('grand_average','pcfm*.mat',p,pathstem,subjects{cnt});

%es_preprocess_parallel('weight','pcfm*.mat',p,pathstem,subjects{cnt});
%es_preprocess_parallel('grand_average','wpcfm*.mat',p,pathstem,subjects{cnt});

%es_preprocess_parallel('image','cfm*.mat',p,pathstem,subjects{cnt});
%es_preprocess_parallel('image','wpcfm*.mat',p,pathstem,subjects{cnt});
%es_preprocess_parallel('smooth','image',p,pathstem,subjects{cnt});
%es_preprocess_parallel('firstlevel','smooth',p,pathstem,subjects{cnt});

%es_preprocess_parallel('mask','image',p,pathstem,subjects{cnt});

%% Other preprocessing steps
%es_preprocess_parallel('artefact','baseline',p,pathstem,subjects{cnt});
%es_preprocess_parallel('sort','average',p,pathstem,subjects{cnt});
%es_preprocess_parallel('erase','',p,pathstem,subjects{cnt});
%p.outputstem = '/imaging/es03/P6E1/preprocess_TF/'; % for copying files
%es_preprocess_parallel('copy','rereference',p,pathstem,subjects{cnt});

end
matlabpool 'close';