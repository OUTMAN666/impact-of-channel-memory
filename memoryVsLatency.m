%This file is created by Xu Xiaoli on 25/05/2021
%It verifies the analytical results obtained for GE channel analysis of
%blind coding
%Developed by Guan Qixing on 07/06/2021
clc;
clear;
close all;

p_vec=0.5:-0.05:0.1;
ChMemory=1-2*p_vec;
lambda=0.3;
alpha1=1;
alpha2=0.8;
Threshold = 1;

iter=1000;
LatencySimu_Blind1=zeros(iter,length(p_vec));
LatencySimu_Blind08=zeros(iter,length(p_vec));

LatencyAna_Blind1=1+(1/(1-2*lambda)^2)./(1-ChMemory);
LatencyAna_Blind08 = 1+(lambda+(1-lambda)*alpha2)./((1-lambda).*alpha2-lambda)^2+(((1-lambda).*alpha2+lambda)./((1-lambda).*alpha2-lambda))^2.*ChMemory./(1-ChMemory);

LatencySimu_ARQ=zeros(iter,length(p_vec));


LatencyAna_ARQ=2*(1-lambda)/(1-2*lambda)+(ChMemory./(1-ChMemory))/(1-2*lambda);
LatencysimuGE_Threshold_T3=zeros(iter,length(p_vec));
LatencysimuGE_Threshold_T7=zeros(iter,length(p_vec));
LatencysimuGE_Threshold_T11=zeros(iter,length(p_vec));


for i=1:length(p_vec)
    p=p_vec(i)
    for j=1:iter
        LatencySimu_ARQ(j,i)=simuGE_ARQ(lambda, p, p,0);
        
        LatencySimu_Blind1(j,i)=getBlindCoding(lambda, p, p,alpha1);
        LatencySimu_Blind08(j,i)=getBlindCoding(lambda,p,p,alpha2);

%         [LatencysimuGE_Threshold_T1(j,i),~]=getThresholdCoding2(lambda,0,1,10000,1,Threshold,p);
%         [LatencysimuGE_Threshold_T5(j,i),~]=getThresholdCoding2(lambda,0,1,10000,5,Threshold,p);
%          [LatencysimuGE_Threshold_T15(j,i),~]=getThresholdCoding2(lambda,0,1,10000,10,Threshold,p);
        LatencysimuGE_Threshold_T3(j,i)=simuGE_Threshold(lambda,p,p,3,Threshold);
        LatencysimuGE_Threshold_T7(j,i)=simuGE_Threshold(lambda,p,p,7,Threshold);
        LatencysimuGE_Threshold_T11(j,i)=simuGE_Threshold(lambda,p,p,11,Threshold);

    end
end
LatencySimu_ARQ_mean=sum(LatencySimu_ARQ,1)/iter;

LatencySimu_Blind_mean1=sum(LatencySimu_Blind1,1)/iter;
LatencySimu_Blind_mean08=sum(LatencySimu_Blind08,1)/iter;

LatencySimu_Threshold_mean_T3=sum(LatencysimuGE_Threshold_T3,1)/iter;
LatencySimu_Threshold_mean_T7=sum(LatencysimuGE_Threshold_T7,1)/iter;
LatencySimu_Threshold_mean_T11=sum(LatencysimuGE_Threshold_T11,1)/iter;

figure;
plot(ChMemory,LatencyAna_ARQ,'r-','LineWidth',1.5);
hold on;
plot(ChMemory,LatencySimu_ARQ_mean,'rs','MarkerFaceColor','r');

plot(ChMemory,LatencyAna_Blind1,'b-','LineWidth',1.5);
plot(ChMemory,LatencySimu_Blind_mean1,'bo','MarkerFaceColor','b');
plot(ChMemory,LatencyAna_Blind08,'g-','LineWidth',1.5);
plot(ChMemory,LatencySimu_Blind_mean08,'go','MarkerFaceColor','g');
plot(ChMemory,LatencySimu_Threshold_mean_T3,'--c^','LineWidth',1.5);
plot(ChMemory,LatencySimu_Threshold_mean_T7,'--m^','LineWidth',1.5);
plot(ChMemory,LatencySimu_Threshold_mean_T11,'--k^','LineWidth',1.5);

hold off;
grid on;
xlabel('Channel Memory \eta');
ylabel('Expected E2E Latency');
legend('ARQ-ana','ARQ-simu','blind coding-ana(\alpha=1)', ...
    'blind coding-simu(\alpha=1)','blind coding-ana(\alpha=0.8)', ...
    'blind coding-simu(\alpha=0.8)','threshold coding (T=3)', ...
    'threshold coding (T=7)','threshold coding (T=11)');
save memoryLatency.mat
