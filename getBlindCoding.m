% simulate the result of blind coding over GE channel
function [simuLatency]=getBlindCoding(lambda,p,r,alpha)

% clear;
 N=10000;
% %��Ϣ��������
% lambda=0.4;
% %�����ŵ�״��
% p = 0.4;
% r = 0.4;
% alpha = 0.8;

PackeTransmitted=zeros(1,N); %record the channel status in the time slots��0��ʾ�ŵ�״��B
PackeTransmitted(1) = rand<r/(p+r);%��ʼʱ���ŵ�״��ΪG�ĸ���r/(p+r)��ΪB�ĸ���p/(p+r)
for i = 2:N
    PrSeed  = rand;
    if PackeTransmitted(i-1) == 1
        PackeTransmitted(i) = PrSeed>p;
    else
        PackeTransmitted(i) = PrSeed<r;
    end
end

PacketArrive=(rand(1,N)<lambda); %record the packet arrival��1��ʾ����Ϣ������
GenerateTime=find(PacketArrive==1);
DeliverTime=zeros(1,length(GenerateTime));%to store the deliver time for all the packets
TotalPackets=sum(PacketArrive);

infoPacket=0; 
degree=0;

actionSet = zeros(1,N);

%������Ϊ
for i = 1:N
    if PacketArrive(i)==1
        %�����ݰ��������Ϣ��
        actionSet(i) = 1;
    elseif rand<alpha
        %�����ݰ������alpha���ʷ��ͱ����        
        actionSet(i) = 0;
    else
        %��1-alpha�ĸ���ʲô������
        actionSet(i) = -1;
    end
end

for i=1:(TotalPackets-1)
    
    infoPacket=infoPacket+1;
    
    ChannelStatus=PackeTransmitted(GenerateTime(i):(GenerateTime(i+1)-1));   
    actionStatus = actionSet(GenerateTime(i):(GenerateTime(i+1)-1));
    %��Ϊ������ʲô�������ģ��൱��ԭ�ŵ��ŵ�״�����ѣ������������ɶ�
    ChannelStatus(actionStatus==-1) = 0;
    
    tmp=degree+cumsum(ChannelStatus);   
    degree=tmp(end);    
    if degree>=infoPacket
        %can decode all the previous information packet
        decodingTime=find(tmp==infoPacket,1,'first');%The instance when all the packets are decoded
        DeliverTime(i-infoPacket+1:i)=GenerateTime(i)+decodingTime;%since decoding only happen at the end of the time slot, no need to subtract 1
        infoPacket=0;% back to one information packet
        degree=0;
    end
end

%=========See whether the remaining packes can be decoded by the remaining
%time slots of total N time slots
undecoded=infoPacket+1;%total packet remains undecoded
ChannelStatus=PackeTransmitted(GenerateTime(end):N);
actionStatus = actionSet(GenerateTime(end):N);
ChannelStatus(actionStatus==-1) = 0;

tmp=degree+cumsum(ChannelStatus);
degree=tmp(end);

if degree>=undecoded
    decodingTime=find(tmp==undecoded,1,'first');
    DeliverTime(TotalPackets-undecoded+1:end)=GenerateTime(end)+decodingTime;
    undecoded=0;
end

Delivered=TotalPackets-undecoded; %the total number of packets that have been delivered
simuLatency=mean(DeliverTime(1:Delivered)-GenerateTime(1:Delivered));