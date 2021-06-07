%This file is created by Xu Xiaoli on 25/05/2021
%It verifies the analytical results obtained for GE channel analysis of
%blind coding

clc;
clear;
close all;

p_vec=0.5:-0.05:0.1;
ChMemory=1-2*p_vec;
lambda=0.3;
alpha=1;
Threshold = 1;

iter=10;
LatencySimu_Blind=zeros(iter,length(p_vec));
LatencyAna_Blind=1+(1/(1-2*lambda)^2)./(1-ChMemory);

LatencySimu_ARQ=zeros(iter,length(p_vec));


LatencyAna_ARQ=2*(1-lambda)/(1-2*lambda)+(ChMemory./(1-ChMemory))/(1-2*lambda);
LatencysimuGE_Threshold=zeros(iter,length(p_vec));
LatencysimuGE_Threshold_modified=zeros(iter,length(p_vec));

for i=1:length(p_vec)
    p=p_vec(i)
    for j=1:iter
        LatencySimu_ARQ(j,i)=simuGE_ARQ(lambda, p, p,0);

        [LatencySimu_Blind(j,i),~,~]=simuGE_Blind(lambda, p, p,alpha);
        LatencysimuGE_Threshold(j,i)=simuGE_Threshold(lambda,p,p,10,Threshold);
        LatencysimuGE_Threshold_modified(j,i)=simuGE_Threshold_modified(lambda,p,p,10, Threshold);
    end
end
LatencySimu_ARQ_mean=sum(LatencySimu_ARQ,1)/iter;

LatencySimu_Blind_mean=sum(LatencySimu_Blind,1)/iter;
LatencySimu_Threshold_mean=sum(LatencysimuGE_Threshold,1)/iter;
LatencySimu_Threshold_mean_modified=sum(LatencysimuGE_Threshold_modified,1)/iter;
figure;
plot(ChMemory,LatencyAna_ARQ,'r-','LineWidth',1.5);
hold on;
plot(ChMemory,LatencySimu_ARQ_mean,'rs','MarkerFaceColor','r');

plot(ChMemory,LatencyAna_Blind,'b-','LineWidth',1.5);
plot(ChMemory,LatencySimu_Blind_mean,'bo','MarkerFaceColor','b');
plot(ChMemory,LatencySimu_Threshold_mean,'-c^','LineWidth',1.5);
plot(ChMemory,LatencySimu_Threshold_mean_modified,'-kd','LineWidth',1.5);
hold off;
grid on;
xlabel('Channel Memory');
ylabel('Expected E2E Latency');
legend('ARQ (ana)','ARQ (simu)','Blind Coding (ana)','Blind Coding (simu)','Threshold coding (\gamma=1)','Threshold modified (\gamma=1)');