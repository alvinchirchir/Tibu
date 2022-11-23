function [model_accuracy,conMat,finalMdl,time_duration,bestKscale,bestBConstraint]=ModifiedBatOptimization(rangeValue)

load SvmFunction

%% Start

if(nargin<1)
    rangeValue=50000;
    selectedKernel=2;
end

Par= [30, 0, 0.05, 0, 30, 1];

%% Algorithm Coefficients
Max_iter= Par(5);   % Maximum number of iterations

NB= Par(1);        % number of bats(swarm size)

Min_Freq= Par(2);   % Minimum Frequency
Max_Freq= Par(3);   % Maximum Frequency

loudness= 1;   % Initial loudness

% alpha= last Loudness^(1/last iteration)
Last_Loudness= 0.01;
alpha= Last_Loudness^(1/Max_iter);  % loudness coefficient

init_emission_rate= 1;  % emission rate

% gamma= -log(1-(last_emission_rate/initial_emission_rate))/last iteration
last_emission_rate= 0.99;
gamma= -log(1-(last_emission_rate/init_emission_rate))/Max_iter;   % emission rate coefficient

init_Vel= Par(4);            % initial Bats Velocity


%% Fitness function

lb= 1;   % lower bound of your variables
ub = rangeValue;   % upper bound of your variables
steps=ub/10;




%%  Objective Function

%% Swarm initialization
tic % start timing

Temp.pos= [];
Temp.cost= [];
Temp.Pulse_Frequency= [];
Temp.velocity= [];

% Initialize a number of Bats
BAT= repmat(Temp, NB, 1);


for i=1:NB
    % Choose pos withn lb~ub.
    BAT(i).pos= lb + (ub-lb)*rand(1, 2);
    
    % Evaluate Position
    [BAT(i).cost,~]= MainSVMFunction(X_train,Y_train,CV_Part,class_type,selectedKernel,BAT(i).pos(1),BAT(i).pos(2));   
    
    % Determine initial velocity.
    BAT(i).velocity= init_Vel.*ones(1, 2);
    
    % Determine Frequency.
    BAT(i).Pulse_Frequency= 0.*ones(1, 2);
end

% Save personal best
bBAT= BAT;     % This is the first iteration so: Personal best= the same BAT(Particle).

% Determine the global best among the bBAT
[~, index]= max([bBAT.cost]);

% Save the Global optimum
gBAT= BAT(index);

%% main loop

% parameters for plotting
AVR= mean([BAT.cost]);  % Average BAT cost for plotting
best= gBAT.cost;
iter= 1;                % number of iteration
loudness_vector= loudness;
emission_rate_vector= init_emission_rate;


% The stop criterium is as the following

while iter<Max_iter

    % Update loundness and emission rate
    emission_rate= init_emission_rate*(1-exp(-gamma*iter));
    loudness= alpha*loudness;
    
    for i=1:NB
        
        % Choose new Frequency randomely
        BAT(i).Pulse_Frequency= Min_Freq+(Max_Freq - Min_Freq)*rand;
        
        % Choose new Velocity
        BAT(i).velocity= BAT(i).velocity + (BAT(i).pos - gBAT(iter).pos)*BAT(i).Pulse_Frequency;
        
        % Update position
        BAT(i).pos= BAT(i).pos + BAT(i).velocity;
        
        % Check a switching condition
        if rand<emission_rate
            eps= 10;
            BAT(i).pos= gBAT(iter).pos+eps*randn(1, 2)*loudness;
        end
        

        
        %% Handling Boundaries:
        CrossUp= BAT(i).pos >= ub;             % Get the variables which crossed the upper boundary after updating position
        BAT(i).pos(CrossUp)= ub;      % and set them= upper bounds.
        
        CrossDown= BAT(i).pos <= lb;           % Get the variables which crossed the lower boundary after updating position
        BAT(i).pos(CrossDown)= lb;  % and set them= lower bounds.
   
        %% Evaluate position
        [BAT(i).cost,~]= MainSVMFunction(X_train,Y_train,CV_Part,class_type,selectedKernel,BAT(i).pos(1),BAT(i).pos(2));   
        
        % Update bBAT if the following condition is satisfied
        if ((BAT(i).cost>=bBAT(i).cost) && (rand>loudness))
            bBAT(i)= BAT(i);
        end

    end  % Here is the end of updating BATS
    
    %BAT(:).pos=whalePositions(Bat(:).pos,lb,ub,NB);
    
    
    convertedTable = struct2table(BAT);

    data=table2cell(convertedTable);
    row_size=size(data,1);
    column_size=2;
 
battowhalepositions(30,2)=0;
    
%Index values in cells 
for count_i=1:2
    for count_j=1:row_size       
        battowhalepositions(count_j,count_i)=BAT(count_j).pos(count_i);
    end
end

    

whaletobats=whaleoptimizedBats(battowhalepositions,lb,ub,NB);

% for count_m=1:30
%  BAT(count_m).pos=whaletobats(count_m,1);
% end


for count_k=1:30
   BAT(count_k).pos=whaletobats(count_k).whale ; 
end


 

    iter= iter+1;
    
    
    %% Update Global Best
    [~, index]= max([bBAT.cost]);
    gBAT(iter)= bBAT(index);
    best(iter)= gBAT(iter).cost;
    
    %% Save things to plot
    AVR(iter)= mean([BAT.cost]);
    loudness_vector= [loudness_vector loudness];
    emission_rate_vector= [emission_rate_vector emission_rate];
    disp([ 't= ' num2str(iter), ',   emission rate= ' num2str(emission_rate), ',  Loudness= ' num2str(loudness), ',   BEST= ' num2str(best(iter))]);


    % Break the loop if:
    if gBAT(iter).cost==100 
         %break;
    end
    
end

%%

bestKscale=gBAT(iter).pos(1);
bestBConstraint=gBAT(iter).pos(2);


[~,finalMdl]= MainSVMFunction(X_train,Y_train,CV_Part,class_type,selectedKernel,bestBConstraint,bestKscale);




                    
% Test Accuracy of model

testLabels = predict(finalMdl.Trained{1},X_test);

% Confusion Mat
conMat=confusionmat(testLabels,Y_test);
model_accuracy=((conMat(1,1)+conMat(2,2))/(conMat(1,1)+conMat(1,2)+conMat(2,1)+conMat(2,2)))*100;
time_duration=num2str(toc);










end
