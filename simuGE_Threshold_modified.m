%This file is created by Xu Xiaoli on 23/03/2020
%It generates the expected latency for the threshold based coding protocol
%lambda: packet arrival rate
%p: packet erasrue probability
%N: the total time slots considered
%T: the feedback delay (T=0 corresponds to instantaneous feedback)
%==========================================================================
%==It modify the original proposed scheme in [5] by transmitting code
%packet during the empty slot
%==========================================================================
%developped by Guan Qixing on 30/05/2021
function Latency=simuGE_Threshold_modified(lambda,p,r,T, Threshold)
N = 50000;

PacketArrive=[1, (rand(1,N-1)<lambda)]; %Start from the first arriving packet

GenerateTime=find(PacketArrive==1);
DeliverTime=zeros(1,length(GenerateTime));%to store the deliver time for all the packets

Action=zeros(1,N); %To record the actions taken during all the N time slots
TransQueue=0;% The queue at transmitter side

RealQueue=zeros(1,N); %To record the real queue at the reciever side
w=0;%the number of packets waiting at the receiver
d=0; %the number of degree for decoding these packets

EstimatedQueue=0;
TrackEstimatedQueue=zeros(1,N);


ErasurePr = p/(p+r);

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



% Threshold=1;
numPacket=0; %to store the total number of packets processed

for i=1:T+1
    %there is no feedback info yet
    TransQueue=TransQueue+PacketArrive(i);
    if TransQueue>0 && EstimatedQueue<Threshold
        Action(i)=0; %send an information packet
        numPacket=numPacket+1; %the processed packet increased by 1
        TransQueue=TransQueue-1; %transmitting queue decrease by 1
        EstimatedQueue=EstimatedQueue+ErasurePr;
        w=w+1;
        %the channel state G
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
    else
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
    end
    RealQueue(i+1)=w-d;
    TrackEstimatedQueue(i)=EstimatedQueue;
end


for i=T+2:N
    TransQueue=TransQueue+PacketArrive(i);
    EstimatedQueue=RealQueue(i-T)+sum(1-Action(i-T:i-1))*ErasurePr-sum(Action(i-T:i-1))*(1-ErasurePr);
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
    else
        Action(i)=1;
        if PacketTransmitted(i)==1
            d=d+1;
            if d>=w-0.001
                DeliverTime((numPacket-w+1):numPacket)=i+1;%all the waiting packets are delivered
                w=0;
                d=0;
            end
        end
    end
    RealQueue(i+1)=w-d;
    TrackEstimatedQueue(i)=EstimatedQueue;
end



TotalDelivered=sum(DeliverTime>=1);% only count those packets that has been delivered

Latency=mean(DeliverTime(1:TotalDelivered)-GenerateTime(1:TotalDelivered));
