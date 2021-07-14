%This file is created by Xu Xiaoli on 27/05/2021
%It compares the performance of ARQ over GE channel with the analytical
%results. 

function simuLatency=simuGE_ARQ(lambda, p, r,T)

% lambda=0.4;
N=10000; %Total number of time slots considered

%Channel Parameters
% p=0.2; % assume symmetric, p=r
% r=p;
% PG=0; %erasure probability when the channel is in Good State
% PB=1; %erasure probability when the channel is in Bad State

%Simulate the packet arrival
PacketArrive=(rand(1,N)<lambda);
%Simulate the channel, Assume start from random state
GoodState=zeros(1,N); %Trace the channel state
Transition=(rand(1,N)<p); %whether a transition will occur at certain time
GoodState(1)=(rand<(r/(r+p))); %whether the initial state is G or B

NumTransitions=cumsum(Transition);%total number of Transitions 
flag=mod(NumTransitions,2);
GoodState(2:end)=mod(GoodState(1)+flag(1:end-1),2); 

PackeTransmitted=GoodState;

%=======Trace the receiver behavior============
PacketArriveTS=find(PacketArrive==1);%The time slot with new packet arrival
PacketIndexAllTS=zeros(1,N);%the store which packet is sent on each time slot
DelieverStatus=ones(1,length(PacketArriveTS));%Those packet that are not properly received till the end of simulation
PacketDelivereTS=zeros(1,length(PacketArriveTS));%to store the time slot when the packet is delievered

for i=1:length(PacketArriveTS)  
    %Transmit at the first free TS after its arrival
    selectedTS=find(PacketIndexAllTS(PacketArriveTS(i):end)==0,1,'first')+PacketArriveTS(i)-1;
    PacketIndexAllTS(selectedTS)=i; %this time slot is used for sending ith packet
    if isempty(selectedTS)
       DelieverStatus(i)=0;
       continue; %If the selectedTS is greater than the range we consider, this packet is not going to be received properly
    end
    while PackeTransmitted(selectedTS)==0
        %if the packet is erased, schedule the retransmission
        %Retransmission should have priority than the new packet for minimizing the in-order deliver delay
        RetransmissionStart=selectedTS+T;%the time slot to get feedback
        %find the first free time slot after receiving the feedback
        selectedTS=find(PacketIndexAllTS(RetransmissionStart:end)==0,1,'first')+RetransmissionStart-1;
        if isempty(selectedTS)
            DelieverStatus(i)=0;
            break; %If the selectedTS is greater than the range we consider, this packet is not going to be received properly
        end
        PacketIndexAllTS(selectedTS)=i;        
    end 
    if DelieverStatus(i)==1
        PacketDelivereTS(i)=selectedTS+1;%by the end of selectedTS, the packet can be delivered successfully
    end
end
InOrderDelieverTS=PacketDelivereTS;
for i=2:length(PacketDelivereTS)
    if InOrderDelieverTS(i)<InOrderDelieverTS(i-1)
        InOrderDelieverTS(i)=InOrderDelieverTS(i-1);
    end
end

Indx=find(DelieverStatus==1);
simuLatency=mean(InOrderDelieverTS(Indx)-PacketArriveTS(Indx));

% Delievered=sum(DelieverStatus)/length(DelieverStatus); 
% BusySlot=sum(PacketIndexAllTS~=0)/N;

% a=(1-lambda)*(r+lambda*(1-r-p));
% b=lambda*((1-r)*(1-lambda)+lambda*p);
% BigNumber=100;
% G0=(r/(p+r))*(a-b)/((1-lambda)*r);
% G1=(p*lambda/a)*G0;
% Gn_ana=[G0, G1, G1*(b/a).^(1:BigNumber-1)];
% 
% B0=(p/(p+r))*((a-b)/a);
% Bn_ana=[B0, B0*(b/a).^(1:BigNumber)];
% 
% delta=(1-p)+p*(1+1/r);
% tn=1+(0:BigNumber)*(delta);
% Tn=1+1/r+(0:BigNumber)*(delta);
% 
% Latency=sum(Gn_ana.*tn+Bn_ana.*Tn)
% sum((Gn_ana+Bn_ana).*(0:BigNumber))
% Latency_neat=1+p/((p+r)*r)+(p/r)*(lambda/(a-b))
% eta=1-p-r;
% D=2*(1-lambda)/(1-2*lambda)+eta/(1-eta)/(1-2*lambda)