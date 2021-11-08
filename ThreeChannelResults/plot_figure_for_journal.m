clc;
clear;
close all;
figdir = 'figs_for_journal';
mkdir(figdir);
malesub = [8,10,11,20,23,26];
femalesub = [7,12,15,18,21,25];

k = 12;gray_ = [0 0 0]+0.05*k;
left_color = [0 0 0];
right_color = [0 0 0];


for part = 1
part1 = [3,6,1,2,4,5];
% part = 2
% close all;
fig = figure('units','normalized','outerposition',[0 0 1/2 * 1.05 0.667]),
 
set(fig,'defaultAxesColorOrder',[left_color; right_color]);   
sub = malesub(part1(part));
load(['result_s',num2str(sub)]);

linewidth = 1.5;
fontsize = 16;
fontlabel = 14;
%% segment plot

    subplot(411),plot(downsample(ty,2),downsample(data_result1.y(:,1),2),'r*','LineWidth', 1);hold on;plot(ty, data_result1.y_rec(:,1),'g-','LineWidth', linewidth); hold on;box on; xlim([ty(1) ty(end)]);
    xlabel('Time (second)','fontsize',fontlabel), ylabel('SC (\muS)','fontsize',fontlabel), %legend('simulated','reconstructed');
    title(['(i) Male Participant ', num2str(part) ,' (Phasic SC from Middle Phalanx of Hand)'],'fontsize',fontsize),


    subplot(413),plot(downsample(ty,2),downsample(data_result1.y(:,2),2),'b*','LineWidth', 1);hold on;plot(ty, data_result1.y_rec(:,2),'g-','LineWidth', linewidth); hold on;box on; xlim([ty(1) ty(end)]);
    xlabel('Time (second)','fontsize',fontlabel), ylabel('SC (\muS)','fontsize',fontlabel), %legend('simulated','reconstructed');
    title(['(iii) Male Participant ', num2str(part) ,' (Phasic SC from Medial Plantar Surface of Foot)'],'fontsize',fontsize);
    
    subplot(412),plot(downsample(ty,2),downsample(data_result1.y(:,3),2),'k*','LineWidth', 1);hold on;plot(ty, data_result1.y_rec(:,3),'g-','LineWidth', linewidth); hold on;box on; xlim([ty(1) ty(end)]);
    xlabel('Time (second)','fontsize',fontlabel), ylabel('SC (\muS)','fontsize',fontlabel), %legend('simulated','reconstructed');
    title(['(ii) Male Participant ', num2str(part) ,' (Phasic SC from Thenar/Hypothenar of Hand)'],'fontsize',fontsize);
 
    x_plot = data_result1.uj;
    x_plot(x_plot<=0) = NaN; tu = (0:length(x_plot)-1)/Fsu+ll;
    
    xg = ug;
    xg(ug<=0) = NaN;
     subplot(414),hold on; box on
    yyaxis right, stem(tu, x_plot,'g-','filled','LineWidth', linewidth); hold on;ylabel('Amplitude (\muS)','fontsize',fontlabel,'Color','k'),
    yyaxis left; stem(tg, xg,'b','filled','MarkerSize',0.1,'LineWidth', 2.25,'Color',gray_);ylabel('Event','fontsize',fontlabel,'Color','k')
    xlim([ty(1) ty(end)]);
    title('(iii) Estimated Neural Stimuli','fontsize',fontsize), xlabel('Time (second)','fontsize',fontlabel),  %legend('ground truth','recovered');
    dim3 = xlim;
    
%     part1(part)
%     lag
%     tau = result1.tau_j
%     R_2_H = 1-var(y1-y1_)/var(y1)
%     R_2_F = 1-var(y2-y2_)/var(y2)
     saveas(gcf,[figdir,'\small_male_participant',num2str(part),'.png']);
end