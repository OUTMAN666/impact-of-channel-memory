clc;
clear;
close all;

p=0.2;
lambda=0.3;
n_vec=1:10;
tn=zeros(1,length(n_vec));
Tn=zeros(1,length(n_vec));

for i=1:length(n_vec)
    n=n_vec(i);
    [tn(i),Tn(i)]=simuNumSteps(n,lambda,p);
end



%=======Analytical results============
r=p;alpha=1;
delta=(r+p)/((1-lambda)*alpha*r-p*lambda);
t1=(1+p*(1-alpha+alpha*lambda)*(1+lambda*delta)/r)/((1-lambda)*alpha);
tn_ana=t1+(n_vec-1)*delta;
Tn_ana=tn_ana+(1+lambda*delta)/r;

figure;
plot(n_vec,tn,'bo','MarkerFaceColor','b');
hold on;
plot(n_vec,Tn,'rs','MarkerFaceColor','r');
plot(n_vec,tn_ana,'b-','LineWidth',1.5);
plot(n_vec,Tn_ana,'r--','LineWidth',1.5);
hold off;
grid on;
xlabel('n');
ylabel('t_n/T_n');
legend('t_n (simu)','T_n (simu)','t_n (ana)','T_n (ana)')