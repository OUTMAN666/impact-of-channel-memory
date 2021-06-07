clc;
clear;
close all;

T_vec=0:5:30;
Threshold = 1;
lambda=0.3;
alpha  = 1;
p1=0.3;
p2=0.45;
iter=100;
ChMemory_01 = 1-2*p1;
ChMemory_04 = 1-2*p2;
LatencyAna_Blind_01=1+(1/(1-2*lambda)^2)./(1-ChMemory_01);
LatencyAna_Blind_04=1+(1/(1-2*lambda)^2)./(1-ChMemory_04);

LatencysimuGE_Threshold_modified_01=zeros(iter,length(T_vec));
LatencysimuGE_Threshold_modified_04=zeros(iter,length(T_vec));
for i=1:length(T_vec)
    T=T_vec(i)
    for j=1:iter
        LatencysimuGE_Threshold_modified_01(j,i)=simuGE_Threshold_modified(lambda,p1,p1,T, Threshold);

        LatencysimuGE_Threshold_modified_04(j,i)=simuGE_Threshold_modified(lambda,p2,p2,T, Threshold);
    end
end

LatencySimu_Threshold_mean_modified_01=sum(LatencysimuGE_Threshold_modified_01,1)/iter;
LatencySimu_Threshold_mean_modified_04=sum(LatencysimuGE_Threshold_modified_04,1)/iter;
%=====================Plot the variance========================

Thre_modified_std_01=zeros(1,length(T_vec));
Thre_modified_std_04=zeros(1,length(T_vec));

Thre_modified_CI_01=zeros(2,length(T_vec));
Thre_modified_CI_04=zeros(2,length(T_vec));

for i=1:length(T_vec)
    
    Thre_modified_std_01(i)=std(LatencysimuGE_Threshold_modified_01(:,i));  
    Thre_modified_std_04(i)=std(LatencysimuGE_Threshold_modified_04(:,i));  
    
    
    Thre_modified_SEM_01=Thre_modified_std_01(i)/sqrt(iter); %standard error
    Thre_modified_ts_01=tinv([0.025 0.095],iter-1);
    Thre_modified_CI_01(:,i)=Thre_modified_std_01(i)+Thre_modified_ts_01*Thre_modified_SEM_01;
    
    Thre_modified_SEM_04=Thre_modified_std_04(i)/sqrt(iter); %standard error
    Thre_modified_ts_04=tinv([0.025 0.095],iter-1);
    Thre_modified_CI_04(:,i)=Thre_modified_std_04(i)+Thre_modified_ts_04*Thre_modified_SEM_04;
    
end


figure;
plot(T_vec,LatencyAna_Blind_01*ones(1,length(T_vec)),'bo-');
hold on;
grid on;
errorbar(T_vec,LatencySimu_Threshold_mean_modified_01,Thre_modified_CI_01(1,:),Thre_modified_CI_01(2,:),'kd-','MarkerFaceColor','k','LineWidth',1);
plot(T_vec,LatencyAna_Blind_04*ones(1,length(T_vec)),'mo-');
errorbar(T_vec,LatencySimu_Threshold_mean_modified_04,Thre_modified_CI_04(1,:),Thre_modified_CI_04(2,:),'gd-','MarkerFaceColor','g','LineWidth',1);
hold off;
xlabel('Feedback delay T');
ylabel('End-to-end latency');
%legend('Delayed ARQ','Greedy Coding');
ylim([2,16]);

legend('Blind coding (p=r=0.3,\alpha=1)','Threshold Modified (p=r=0.3,\gamma=1)','Blind coding (p=r=0.45,\alpha=1)','Threshold Modified (p=r=0.45,\gamma=1)');
