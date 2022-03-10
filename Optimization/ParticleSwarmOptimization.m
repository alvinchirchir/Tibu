function [model_accuracy,conMat,finalMdl,time_duration,bestKscale,bestBConstraint]=ParticleSwarmOptimization(rangeValue)

load SvmFunction

Par= [30, 0.9, 0.4, 2.03, 2.03, 240, 0, 1];

if(nargin<1)
    rangeValue=1000;
end

%% Algorithm Coefficients

Max_iter= 30;   % Maximum number of iterations
NB= Par(1);      % number of particles(swarm size). It's best to be >= number of variables.
W= Par(2);       % initial Inertia
minW= Par(3);    % last inertia
C1= Par(4);      % Congnitive coefficient
C2= Par(5);      % Social Coefficient
init_Vel= Par(7);            % initial particles Velocity
alpha= ((W - minW)/(Max_iter));      % a percentage to determine how much the W decreases in each iteration


%% PSO Optimized SVM function

lb= 1;   % lower bound of your variables
ub = rangeValue;   % upper bound of your variables




%The objective function is  a SVM function

%% Swarm initialization
tic % start timing
Temp.pos= [];
Temp.cost= [];
Temp.velocity= [];
% Initialize a number of Particles

Particles= repmat(Temp, NB, 1);

for i=1:NB
    % Choose pos withn lb~ub.
    Particles(i).pos= lb + (ub-lb)*rand(1, 2);
    
    % Evaluate Position
% Evaluate Position
    [Particles(i).cost,~]= MainSVMFunction(X_train,Y_train,CV_Part,class_type,Particles(i).pos(1),Particles(i).pos(2));   
    
    % Determine initial velocity.
    Particles(i).velocity= init_Vel.*ones(1, 2);
end

%%Initialize loading
fig_pso = uifigure;
d_pso = uiprogressdlg(fig_pso,'Title','Please Wait',...
        'Message','Opening the application');


% Save personal best
bParticles= Particles;     % This is the first iteration so: Personal best= the same Particles
% Determine the global best among the bparticles
[~, index]= min([bParticles.cost]);
% Save the Global optimum
gParticle= Particles(index);
%% main loop
% parameters for plotting
AVR= mean([Particles.cost]);  % Average Particles cost for plotting
best= gParticle.cost;
iter= 1;                % number of iteration
W_vector= W;
% The stop criterium is as the following
while iter<Max_iter
    
    progressbar(d_pso,iter,Max_iter);       
    
    xx= [];
    yy= [];
    zz= [];
    for i=1:NB
        
        % Choose new Velocity
        Particles(i).velocity= W.*Particles(i).velocity...
            +C1.*rand(1, 2).*(bParticles(i).pos - Particles(i).pos)...
            +C2.*rand(1, 2).*(gParticle(iter).pos - Particles(i).pos);
        
        % Update position
        Particles(i).pos= Particles(i).pos + Particles(i).velocity;
        
        %% Handling Boundaries:
        CrossUp= Particles(i).pos >= ub;             % Get the variables which crossed the upper boundary after updating position
        Particles(i).pos(CrossUp)= ub;      % and set them= upper bounds.
        
        CrossDown= Particles(i).pos <= lb;           % Get the variables which crossed the lower boundary after updating position
        Particles(i).pos(CrossDown)= lb;  % and set them= lower bounds.
        
        %% Evaluate position
% Evaluate Position
    [Particles(i).cost,~]= MainSVMFunction(X_train,Y_train,CV_Part,class_type,Particles(i).pos(1),Particles(i).pos(2));           
        
        if Particles(i).cost<bParticles(i).cost
            bParticles(i)=Particles(i);
        end
        
        xx= [xx Particles(i).pos(1)];
        yy= [yy Particles(i).pos(2)];
        zz= [zz Particles(i).cost];
    end  % Here is the end of updating particles
    
    [~, index]= min([bParticles.cost]);
    gParticle(iter)= bParticles(index);
    
    if W>minW
        W= W - alpha;
    end
    iter= iter+1;
    
    %% Update Global Best
    [~, index]= min([bParticles.cost]);
    gParticle(iter)= bParticles(index);
    best(iter)= gParticle(iter).cost;
    
    
    % Break the loop if:
    if gParticle(iter).cost==100 
                break;
    end
    
end

delete(fig_pso)


%% Results
bestKscale=gParticle(iter).pos(1);
bestBConstraint=gParticle(iter).pos(2);


[~,finalMdl]= MainSVMFunction(X_train,Y_train,CV_Part,class_type,bestBConstraint,bestKscale);
                  
%% Test Accuracy of model

testLabels = predict(finalMdl.Trained{1},X_test);

%% Confusion Mat
conMat=confusionmat(testLabels,Y_test);
model_accuracy=((conMat(1,1)+conMat(2,2))/(conMat(1,1)+conMat(1,2)+conMat(2,1)+conMat(2,2)))*100;
time_duration=num2str(toc);


