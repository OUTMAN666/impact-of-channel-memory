%This file is created by Xu Xiaoli on 25/05/2021
%It estimates the number of steps to reach the absorb state from state
%(G,n) and (B,n)
%p,r, GE channel state transition probability assume p=r;

function [t,T]=simuNumSteps(n,lambda,p)

iter=10000;
t_vec=zeros(1,iter);
T_vec=zeros(1,iter);
for i=1:iter
    N=50*n; %the maximum number of time slots for it to go absorb
    PacketArrive=(rand(1,N)<lambda);
    PacketWaiting=n+cumsum(PacketArrive);
    Transition=(rand(1,N)<p); %whether a transition will occur at certain time
%     TransitionB=(rand(1,N)<r); %whether a transition will occur at certain time
    NumTransitions=cumsum(Transition);%total number of Transitions 
    flag=mod(NumTransitions,2);
    GoodState_iniG=[1, mod(1+flag(1:end-1),2)]; 
    PackeTransmitted=GoodState_iniG;
    degree=cumsum(PackeTransmitted);
    tmp=find(degree==PacketWaiting,1,'first');
    if isempty(tmp)
        tmp=N;
    end
    t_vec(i)=tmp;

    GoodState_iniB=[0, mod(flag(1:end-1),2)]; 
    PackeTransmitted=GoodState_iniB;
    degree=cumsum(PackeTransmitted);
    tmp=find(degree==PacketWaiting,1,'first');
    if isempty(tmp)
        tmp=N;
    end
    T_vec(i)=tmp;
end
t=sum(t_vec)/iter;
T=sum(T_vec)/iter;