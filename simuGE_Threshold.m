%This file is created by Xu Xiaoli on 23/03/2020
%It generates the expected latency for the threshold based coding protocol
%lambda: packet arrival rate
%p: packet erasrue probability
%N: the total time slots considered
%T: the feedback delay (T=0 corresponds to instantaneous feedback)

function Latency=simuGE_Threshold(lambda,p,r,T,Threshold)

ErasurePr = p/(p+r);
N = 50000;
%generate the channel model
PacketTransmitted=zeros(1,N); %record the channel status in the time slots£¬0 represents B
PacketTransmitted(1) = rand<1-ErasurePr;%the initial state as G with r/(p+r)£¬B with p/(p+r)
for i = 2:N
    PrSeed  = rand;
    if PacketTransmitted(i-1) == 1
        PacketTransmitted(i) = PrSeed>p;
    else
        PacketTransmitted(i) = PrSeed<r;
    end
end



PacketArrive=[1, (rand(1,N-1)<lambda)]; %Start from the first arriving packet
GenerateTime=find(PacketArrive==1);
DeliverTime=zeros(1,length(GenerateTime));%to store the deliver time for all the packets

Action=zeros(1,N); %To record the actions taken during all the N time slots
TransQueue=0;% The queue at transmitter side

RealQueue=zeros(1,N); %To record the real queue at the reciever side
w=0;%the number of packets waiting at the receiver
d=0; %the number of degree for decoding these packets

EstimatedQueue=0;
% Threshold=1;
numPacket=0; %to store the total number of packets processed
StopIdex=min(T+1,N);
for i=1:StopIdex
    %there is no feedback info yet
    TransQueue=TransQueue+PacketArrive(i);
    if TransQueue>0 && EstimatedQueue<Threshold
        Action(i)=0; %send an information packet
        numPacket=numPacket+1; %the processed packet increased by 1
        TransQueue=TransQueue-1; %transmitting queue decrease by 1
        EstimatedQueue=EstimatedQueue+ErasurePr;
        w=w+1;
        if PacketTransmitted(i)==1
            %if this packet is successfully received
           if w==1
               %This is the only waiting packet
               DeliverTime(numPacket)=i+1; %received at the beginning of the next time slot
               w=0;
           else
               d=d+1;
           end
        end
    elseif EstimatedQueue>=Threshold
        Action(i)=1;
        EstimatedQueue=EstimatedQueue-(1-ErasurePr);
        if PacketTransmitted(i)==1
            d=d+1;
            if d>=w-0.001
                DeliverTime((numPacket-w+1):numPacket)=i+1;%all the waiting packets are delivered
                w=0;
                d=0;
            end
        end
    else
        Action(i)=-1;
    end
    RealQueue(i+1)=w-d;
end


for i=T+2:N
    TransQueue=TransQueue+PacketArrive(i);
    EstimatedQueue=RealQueue(i-T)+sum(Action(i-T:i-1)==0)*ErasurePr-sum(Action(i-T:i-1)==1)*(1-ErasurePr);
    %EstimatedQueue=max(0,EstimatedQueue+(Action(j)==0)*p-(Action(j)==1)*(1-p));
    if TransQueue>0 && EstimatedQueue<Threshold
        Action(i)=0; %send an information packet
        TransQueue=TransQueue-1;
        numPacket=numPacket+1; %the processed packet increased by 1
        w=w+1;
        if PacketTransmitted(i)==1
            if w==1
                DeliverTime(numPacket)=i+1;
                w=0;
            else
                d=d+1;
            end
        end
    elseif EstimatedQueue>=Threshold
        Action(i)=1;
        if PacketTransmitted(i)==1
            d=d+1;
            if d>=w-0.001
                DeliverTime((numPacket-w+1):numPacket)=i+1;%all the waiting packets are delivered
                w=0;
                d=0;
            end
        end
    else
        Action(i)=-1;
    end
    RealQueue(i+1)=w-d;
end



TotalDelivered=sum(DeliverTime>=1);% only count those packets that has been delivered

Latency=mean(DeliverTime(1:TotalDelivered)-GenerateTime(1:TotalDelivered));
Uratio=1-sum(Action==-1)/N;


