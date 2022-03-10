clc
clear
load SvmFunction

%% Start

Par= [20, 0, 0.05, 0, 90, 1];

%% Algorithm Coefficients
Max_iter= Par(5);   % Maximum number of iterations

NB= Par(1);        % number of bats(swarm size). It's best to be >= number of variables.

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

plot_type= Par(6);  % 1= surf,  0= contour

%% eggcrate function

lb= 0.1;   % lower bound of your variables
ub = 100000;   % upper bound of your variables



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
    [BAT(i).cost,~]= MainSVMFunction(X_train,Y_train,CV_Part,BAT(i).pos(1),BAT(i).pos(2));   
    
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

time_don=0;

% The stop criterium is as the following

while iter<Max_iter
    if iter==2
       % pause(5);
    end
    % Update loundness and emission rate
    emission_rate= init_emission_rate*(1-exp(-gamma*iter));
    loudness= alpha*loudness;
    
    xx= [];
    yy= [];
    zz= [];
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
        [BAT(i).cost,~]= MainSVMFunction(X_train,Y_train,CV_Part,BAT(i).pos(1),BAT(i).pos(2));   
        
        % Update bBAT if the following condition is satisfied
        if ((BAT(i).cost>=bBAT(i).cost) && (rand>loudness))
            bBAT(i)= BAT(i);
        end
        xx= [xx BAT(i).pos(1)];
        yy= [yy BAT(i).pos(2)];
        zz= [zz BAT(i).cost];
    end  % Here is the end of updating BATS
    
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
    if gBAT(iter).cost==100  % Change this tolerance condition to fit your case
         %break;
    end
    
end

%%


bestKscale=gBAT(iter).pos(1);
bestBConstraint=gBAT(iter).pos(2);


[~,finalMdl]= MainSVMFunction(X_train,Y_train,CV_Part,bestBConstraint,bestKscale);




                    
% Test Accuracy of model

testLabels = predict(finalMdl.Trained{1},X_test);

% Confusion Mat
conMat=confusionmat(testLabels,Y_test);
model_accuracy=((conMat(1,1)+conMat(2,2))/(conMat(1,1)+conMat(1,2)+conMat(2,1)+conMat(2,2)))*100;
time_duration=num2str(toc);



%% results
disp('======================================');
disp([' Swarm Size  '  num2str(NB)]);
disp([' Search Space Size  '  num2str(ub)]);
disp([' Time  '  num2str(toc)]);
disp([' Iterations  '  num2str(Max_iter)]);
disp([' Best Validation Acc  '  num2str(gBAT(iter).cost)]);

