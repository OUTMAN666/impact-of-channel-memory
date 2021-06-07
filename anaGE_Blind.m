%This file is created by Xu Xiaoli on 25/05/2021
%It verifies the analytical results obtained for GE channel analysis of
%blind coding

function [TotalLatency_ana,Ana_G,Ana_B]=anaGE_Blind(lambda, p, r, alpha)


% PG=0; %erasure probability when the channel is in Good State
% PB=1; %erasure probability when the channel is in Bad State

TotalPackets=10000;% set as a large number for summation up to infinity
%=======Verify the state probability with the analytical results============
a=((1-lambda)*r+(1-p)*lambda)*alpha*(1-lambda);
c=p*lambda+(1-lambda)*alpha*(r+2*lambda*(1-r-p));
b=c-a;
d=lambda*p;
Ana_G=zeros(1,1+TotalPackets);
Ana_G(1)=(a-b)*r/((a-b+d)*(p+r));
Ana_G(2)=d/a*Ana_G(1);
Ana_G(3:end)=(b/a).^(1:TotalPackets-1)*Ana_G(2);

Ana_B=zeros(1,1+TotalPackets);
Ana_B(1)=(a-b)*p/(a*(p+r));
Ana_B(2:end)=(b/a).^(1:TotalPackets)*Ana_B(1);


%======Verify the expected latency with the analytical results==============================
% delta=(r+p)/((1-lambda)*alpha*r-p*lambda);
% t1=(1+p*(1-alpha+alpha*lambda)*(1+lambda*delta)/r)/((1-lambda)*alpha);
% tn_ana=[t1,t1+(1:TotalPackets-1)*delta];
% Tn_ana=tn_ana+(1+lambda*delta)/r;
% tn_ana=[0 tn_ana];
% Tn_ana=[0 Tn_ana];
% 
% TotalLatency_ana=sum(Ana_G.*(1+(1-p)*tn_ana+p*Tn_ana))...
%     +sum(Ana_B(1:end-1).*(1+r*tn_ana(2:end)+(1-r)*Tn_ana(2:end)))




a=r*(1-lambda)*alpha+alpha*(1-p-r)*lambda*(1-lambda);
b=p*lambda+alpha*(1-p-r)*lambda*(1-lambda);
delta=(r+p)/((1-lambda)*alpha*r-p*lambda);
C=(1+lambda*delta)/r;
t1=(1+p*(1-alpha+alpha*lambda)*(1+lambda*delta)/r)/((1-lambda)*alpha);
coef=1+lambda/((1-lambda)*alpha);
TotalLatency_ana=1+p/(p+r)*(coef*t1+b/(a-b)*coef*delta+lambda*p*C/((1-lambda)*alpha)+(1-r)*C);
