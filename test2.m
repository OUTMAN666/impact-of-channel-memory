lambda=0.3;
p=0.5;
r=0.5;

TotalPackets=15;% set as a large number for summation up to infinity
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

Ana_Greedy=(1-2*lambda)/(1-lambda).*(lambda/(1-lambda)).^(0:TotalPackets);
% figure;
% plot(0:TotalPackets, Ana_Greedy,'b-');
% hold on;
% plot(0:TotalPackets, 2*Ana_G,'r--');
% return;
%======Verify the expected latency with the analytical results==============================
delta=(r+p)/((1-lambda)*alpha*r-p*lambda);
t1=(1+p*(1-alpha+alpha*lambda)*(1+lambda*delta)/r)/((1-lambda)*alpha);
tn_ana=t1+(1:TotalPackets-1)*delta;
tn_ana=[0 t1 tn_ana];
Tn_ana=tn_ana+(1+lambda*delta)/r;

Latency_Greedy=1+sum(Ana_Greedy.*((0:TotalPackets)+0.5)/(0.5-lambda))

TotalLatency_ana=sum(Ana_G.*(1+(1-p)*tn_ana+p*Tn_ana))...
    +sum(Ana_B(1:end-1).*(1+r*tn_ana(2:end)+(1-r)*Tn_ana(2:end)));
