% The Whale Optimization Algorithm

function [model_accuracy,conMat,finalMdl,time_duration,bestKscale,bestBConstraint]=WhaleOptimization(rangeValue)


load SvmFunction

%% Initialize parameters
if(nargin<1)
    rangeValue=1000;
end

SearchAgents_no=20; % Number of search agents

Max_iter=20; % Maximum numbef of iterations

lb=1;
ub=rangeValue;
dim=2;


%initialize position vector and score for the leader
Leader_pos=zeros(1,dim);
Leader_score=inf; %change this to -inf for maximization problems

Boundary_no= size(ub,dim); % number of boundaries

% Return back if positions is off bounds
% number for both ub and lb
if Boundary_no==1
    Positions=rand(SearchAgents_no,dim).*(ub-lb)+lb;
end

% If each variable has a different lb and ub
if Boundary_no>1
    for i=1:dim
        ub_i=ub(i);
        lb_i=lb(i);
        Positions(:,i)=rand(SearchAgents_no,1).*(ub_i-lb_i)+lb_i;
    end
end

 %%
 
fig = uifigure;
d = uiprogressdlg(fig,'Title','Please Wait',...
        'Message','Opening the application');


Convergence_curve=zeros(1,Max_iter);

tic % start timing
t=0;% Loop counter

% Main loop
while t<Max_iter
    %display progress bar
    progressbar(d,t,Max_iter);       
    for i=1:size(Positions,1)
        
        % Return back the search agents that go beyond the boundaries of the search space
        Flag4ub=Positions(i,:)>ub;
        Flag4lb=Positions(i,:)<lb;
        Positions(i,:)=(Positions(i,:).*(~(Flag4ub+Flag4lb)))+ub.*Flag4ub+lb.*Flag4lb;
        
        % Calculate objective function for each search agent
        fitness=MainSVMFunction(X_train,Y_train,CV_Part,class_type,Positions(i,1),Positions(i,2));
                
        % Update the leader
        if fitness<Leader_score % Change this to > for maximization problem
            Leader_score=fitness; % Update alpha
            Leader_pos=Positions(i,:);
        end
        
    end
    
    a=2-t*((2)/Max_iter); % a decreases linearly from 2 to 0 in Eq. (2.3)
    
    % a2 linearly dicreases from -1 to -2 to calculate t in Eq. (3.12)
    a2=-1+t*((-1)/Max_iter);
    
    % Update the Position of search agents 
    for i=1:size(Positions,1)
        r1=rand(); % r1 is a random number in [0,1]
        r2=rand(); % r2 is a random number in [0,1]
        
        A=2*a*r1-a;  % Eq. (2.3) in the paper
        C=2*r2;      % Eq. (2.4) in the paper
        
        
        b=1;               %  parameters in Eq. (2.5)
        l=(a2-1)*rand+1;   %  parameters in Eq. (2.5)
        
        p = rand();        % p in Eq. (2.6)
        
        for j=1:size(Positions,2)
            
            if p<0.5   
                if abs(A)>=1
                    rand_leader_index = floor(SearchAgents_no*rand()+1);
                    X_rand = Positions(rand_leader_index, :);
                    D_X_rand=abs(C*X_rand(j)-Positions(i,j)); % Eq. (2.7)
                    Positions(i,j)=X_rand(j)-A*D_X_rand;      % Eq. (2.8)
                    
                elseif abs(A)<1
                    D_Leader=abs(C*Leader_pos(j)-Positions(i,j)); % Eq. (2.1)
                    Positions(i,j)=Leader_pos(j)-A*D_Leader;      % Eq. (2.2)
                end
                
            elseif p>=0.5
              
                distance2Leader=abs(Leader_pos(j)-Positions(i,j));
                % Eq. (2.5)
                Positions(i,j)=distance2Leader*exp(b.*l).*cos(l.*2*pi)+Leader_pos(j);
                
            end
            
        end
        
    end
    t=t+1
    Convergence_curve(t)=Leader_score;
    [t Leader_score];
    
    
    %% Results
bestKscale=Leader_pos(1,1);
bestBConstraint=Leader_pos(1,2);


[~,finalMdl]= MainSVMFunction(X_train,Y_train,CV_Part,class_type,bestBConstraint,bestKscale);




                    
%% Test Accuracy of model

testLabels = predict(finalMdl.Trained{1},X_test);

%% Confusion Mat
conMat=confusionmat(testLabels,Y_test);
model_accuracy=((conMat(1,1)+conMat(2,2))/(conMat(1,1)+conMat(1,2)+conMat(2,1)+conMat(2,2)))*100;
time_duration=num2str(toc);

 
end

delete(fig);

end





