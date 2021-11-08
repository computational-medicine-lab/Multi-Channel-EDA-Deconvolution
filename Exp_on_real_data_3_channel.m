% code for experiment
clear all;
addpath('Dependencies');
clc;
% theta1 = theta2, alpha ~=0
load('ss_8_14_18.mat');
s = ss;
dirname = 'ThreeChannelResults';
mkdir(dirname);

subject = [11];%,12,14,15,18,19, 20, 21, 23, 25, 26, 7, 8, 10]%;


for sub = subject
    close all;
    Fsy = 1; Fsu = 4;
    Tsy = 1/Fsy; Tsu = 1/Fsu;

    ub = [1.4 6 100]';
    lb = [0.1 1.5 0.01]';
    
    y1_ton_phas = s(sub).sc(2).y; y1_ton_phas = y1_ton_phas(:);
    y2_ton_phas = s(sub).sc(3).y; y2_ton_phas = y2_ton_phas(:);
    y3_ton_phas = s(sub).sc(1).y; y3_ton_phas = y3_ton_phas(:);
    
    Y_ton_phas = [y1_ton_phas y2_ton_phas y3_ton_phas];
    
    y1_ton = s(sub).sc(2).tonic; y1_ton = y1_ton(:);
    y2_ton = s(sub).sc(3).tonic; y2_ton = y2_ton(:);
    y3_ton = s(sub).sc(1).tonic; y3_ton = y3_ton(:);
    
    Y_ton = [y1_ton y2_ton y3_ton];
    
    y1 = s(sub).sc(2).phasic; % 'thenar/hypothenar of the non-dominant hand' 
    y2 = s(sub).sc(3).phasic; % 'volar middle phalanx' (Finger joints in hand)
    y3 = s(sub).sc(1).phasic; % 'medial plantar' (a nerve in foot)
    
    ug = s(sub).u;
    ugw = s(sub).u;
    Fss = 100;
    %%  sigma calculation
    y1 = y1(:); y2 = y2(:); y3 = y3(:); Y = [y1 y2 y3];
    [sigma] = get_sigma_nchannel(Y, Fss);
    
    %% delay fixation
    [r,c] = size(Y);
    lag = [];
    lag(1) = 0; % first lag is zero, here the reference signal is the channel one.
    
    for i = 2:c
        y_ref_temp = Y(:,1);
        y_com_temp = Y(:,i);

        C = xcorr(y_ref_temp,y_com_temp);
        tc = 0:(1/Fss):(length(C)-1)*(1/Fss);

        [~, idx] = max(C);

        lag(i) = round(length(C)/2-idx+1);
        y_comp = [y_com_temp(max(lag(i)-1,1):end); y_com_temp(end)*ones(max(lag(i)-2,0),1)];
        Y(:,i) = y_comp;
        tyy = 0:(1/Fss):(length(y1)-1)*(1/Fss);
    end
    
        
    % per channel filtering and downsampling the phasic component
    Y_ = [];
    for i = 1:c
       Y(:,i) = LowPassFilter(Y(:,i), Fss, 0.5, 64);
       Y_(:,i) = downsample(Y(:,i), Fss/Fsy);
    end
    Y = Y_;
    
    % per channel filtering and downsampling the tonic component
    Y_ton_ = [];
    for i = 1:c
       Y_ton(:,i) = LowPassFilter(Y_ton(:,i), Fss, 0.5, 64);
       Y_ton_(:,i) = downsample(Y_ton(:,i), Fss/Fsy);
    end
    Y_ton = Y_ton_;
    
    % per channel filtering and downsampling the tonic-phasic component
    for i = 1:c
       Y_ton_phas(:,i) = LowPassFilter(Y_ton_phas(:,i), Fss, 0.5, 64);
       Y_ton_phas_(:,i) = downsample(Y_ton_phas(:,i), Fss/Fsy);
    end
    Y_ton_phas = Y_ton_phas_;
    
%   preserve the full length signal
    Yw = Y;
    
    [Ny,~] = size(Y);           Nu = Ny*(Fsu/Fsy);
    
    ty = 0:Tsy:(Ny-1)*Tsy;      tu = 0:Tsu:(Nu-1)*Tsu;
    tg = 0:(1/Fss):(length(ug)-1)*(1/Fss);


%%  Take a window of the signal
    lls = 200; % window start time in second
    rrs = 400; % window end time in second
    ll = lls*Fsy;
    rr = rrs*Fsy;
    
    ty = ty(ll:rr)';
    
    Y_ton_phas = Y_ton_phas(ll:rr,:);
    Y_ton = Y_ton(ll:rr,:);
    Y = Y(ll:rr,:);

    
    % segment out the ground truth as well
    tg = tg(lls*Fss:rrs*Fss);
    ug = ug(lls*Fss:rrs*Fss);
    

    % make the data structure for the function
    
    data.y = Y;
    data.sigma = sigma;
    data.ub = ub;
    data.lb = lb;
    data.Fsu = Fsu;
    data.Fsy = Fsy;
    data.minimum_peak_distance = 1;

    Nu = length(y1)*(Fsu/Fsy);
   
    %% perform deconvolution
    tic
    parallal_operations = 24;
    parfor i=1:parallal_operations
        [dataA(i)] = concurrent_coordinate_descent1_n_channel(data);
    end
    toc
    cost_prev1 =Inf;
    cost_prev2 =Inf;
    
    %% choose the best initialization
    for i=1:parallal_operations

        cost1 = dataA(i).cost1;
        cost2 = dataA(i).cost2;
        
        if(cost1<cost_prev1 && dataA(i).convergenceFlag == 1 && round(dataA(i).tau_j(1)*1e4)/1e4 ~= lb(1) && round(dataA(i).tau_j(1)*1e4)/1e4 ~= ub(1))
            data_result1 = dataA(i);
            cost_prev1 = cost1;
        end
        if(cost2<cost_prev2 && dataA(i).convergenceFlag == 1 && round(dataA(i).tau_j(1)*1e4)/1e4 ~= lb(1) && round(dataA(i).tau_j(1)*1e4)/1e4 ~= ub(1))
            data_result2 = dataA(i);
            cost_prev2 = cost2;
        end
    end

    save([dirname,'\result_s',num2str(sub)]);
end