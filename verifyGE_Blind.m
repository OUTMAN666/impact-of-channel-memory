%This file is created by Xu Xiaoli on 25/05/2021
%It verifies the analytical results obtained for GE channel analysis of
%blind coding
%#######################################
%This is only valid for PG=0 and PE=1 
%#######################################

clc;
clear;
close all;

%System parameters
lambda=0.3;
N=10000; %Total number of time slots considered

%Channel Parameters
p=0.2; % assume symmetric, p=r
r=p;
PG=0; %erasure probability when the channel is in Good State
PB=1; %erasure probability when the channel is in Bad State

%Blind coding prameter
alpha=1; %when there is no arriving packet,send the coded packets with probability alpha

%Simulate the packet arrival
PacketArrive=(rand(1,N)<lambda);

%Simulate the channel, Assume start from random state
GoodState=zeros(1,N); %Trace the channel state
Transition=(rand(1,N)<p); %whether a transition will occur at certain time
GoodState(1)=(rand<(r/(r+p))); %whether the initial state is G or B

NumTransitions=cumsum(Transition);%total number of Transitions 
flag=mod(NumTransitions,2);
GoodState(2:end)=mod(GoodState(1)+flag(1:end-1),2); 

%=======Trace the decoding behavior============
PackeTransmitted=GoodState.*(rand(1,N)>PG)+(1-GoodState).*(rand(1,N)>PB); %The packet is successfully delivered
GenerateTime=find(PacketArrive==1);
DeliverTime=zeros(1,length(GenerateTime));%to store the deliver time for all the packets
TotalPackets=sum(PacketArrive);
infoPacket=0; 
degree=0;

TraceLackDeg=zeros(1,N);
for i=1:(TotalPackets-1)
    infoPacket=infoPacket+1;
    ChannelStatus=PackeTransmitted(GenerateTime(i):(GenerateTime(i+1)-1));
    tmp=degree+cumsum(ChannelStatus);
    degree=tmp(end);
    if degree>=infoPacket
        %can decode all the previous information packet
        decodingTime=find(tmp==infoPacket,1,'first');%The instance when all the packets are decoded
        DeliverTime(i-infoPacket+1:i)=GenerateTime(i)+decodingTime;%since decoding only happen at the end of the time slot, no need to subtract 1
                %======Trace the lacking degree=
        TraceLackDeg(GenerateTime(i)+1:GenerateTime(i)+decodingTime)=infoPacket-tmp(1:decodingTime);
        
        infoPacket=0;% back to one information packet
        degree=0;
    else
        TraceLackDeg(GenerateTime(i)+1:GenerateTime(i+1))=infoPacket-tmp;
    end
end

%=========See whether the remaining packes can be decoded by the remaining
%time slots of total N time slots
undecoded=infoPacket+1;%total packet remains undecoded
ChannelStatus=PackeTransmitted(GenerateTime(end):N);
tmp=degree+cumsum(ChannelStatus);
degree=tmp(end);
if degree>=undecoded
    decodingTime=find(tmp==undecoded,1,'first');
    DeliverTime(TotalPackets-undecoded+1:end)=GenerateTime(end)+decodingTime;
    undecoded=0;
end

Delivered=TotalPackets-undecoded; %the total number of packets that have been delivered
simuLatency=mean(DeliverTime(1:Delivered)-GenerateTime(1:Delivered))
DeliverRatio=Delivered/TotalPackets;

%=============Find the state probability==============
GoodStateIdx=find(GoodState==1);
BadStateIdx=find(GoodState==0);
TraceLackDeg_G=TraceLackDeg(GoodStateIdx);
TraceLackDeg_B=TraceLackDeg(BadStateIdx);

Pr_Gn=hist(TraceLackDeg_G,0:TotalPackets)/N;
Pr_Bn=hist(TraceLackDeg_B,0:TotalPackets)/N;

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

figure;
plot(0:TotalPackets,Pr_Gn,'bo','MarkerFaceColor','b');
hold on;
plot(0:TotalPackets,Pr_Bn,'rs','MarkerFaceColor','r');
plot(0:TotalPackets,Ana_G,'b-','LineWidth',1.5);
plot(0:TotalPackets,Ana_B,'r--','LineWidth',1.5);
hold off;
xlabel('n');
ylabel('G_n/B_n');
legend('G_n (simu)','B_n (simu)','G_n (ana)','B_n (ana)')
xlim([0,10]);
grid on;

%======Verify the expected latency with the analytical results==============================
delta=(r+p)/((1-lambda)*alpha*r-p*lambda);
t1=(1+p*(1-alpha+alpha*lambda)*(1+lambda*delta)/r)/((1-lambda)*alpha);
tn_ana=t1+(1:TotalPackets-1)*delta;
tn_ana=[0 t1 tn_ana];
Tn_ana=tn_ana+(1+lambda*delta)/r;

TotalLatency_ana=sum(Ana_G.*(1+(1-p)*tn_ana+p*Tn_ana))...
    +sum(Ana_B(1:end-1).*(1+r*tn_ana(2:end)+(1-r)*Tn_ana(2:end)))





