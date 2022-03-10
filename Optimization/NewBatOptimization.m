function [final_model_accuracy,conMat,finalMdl,time_duration,bestKscale,bestBConstraint]=NewBatOptimization(rangeValue,selectKernel)

if(nargin<1)
    rangeValue=1000;
    selectKernel=1;
end

%% Start
Par= [20, 0, 25, 0,30, 1];

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

initial_velocity=0;
max_velocity=50;


plot_type= Par(6);  % 1= surf,  0= contour

%% SVM function

lb= 1;   % lower bound of your variables
ub = rangeValue;   % upper bound of your variables

%Plot a meshgrid for the svm [USED TO CHECK IF ALGORITHM WORKS]
[X, Y]= meshgrid(0.1:100:1000,0.1:100:1000);
Z = zeros(10);

a=0.1;
b=0.1;
 
for c = 1:10
    
    for r = 1:10
        [Z(c,r),~] = MainSVMFunction(X_train,Y_train,CV_Part,class_type,selectKernel,a,b);
        a=a+100;
    end
    a=0.1;
    b=b+100;
end
xlabel('X');
ylabel('Y');



%% Swarm initialization
tic % start timing

Temp.pos= [];
Temp.cost= [];
Temp.Pulse_Frequency= [];
Temp.velocity= [];
Temp.gDiff= [];
Temp.lDiff= [];



% Initialize a number of Bats
BAT= repmat(Temp, NB, 1);

% Compute frequency/Velocity for each Bat
for i=1:NB
    % Choose pos withn lb~ub.
    BAT(i).pos= lb + (ub-lb)*rand(1, 2);
    
    % Evaluate Position
    [BAT(i).cost,~]= MainSVMFunction(X_train,Y_train,CV_Part,class_type,selectKernel,BAT(i).pos(1),BAT(i).pos(2));   
    
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

%%NEW CODE

for i=1:NB
    
BAT(i).gDiff=abs((gBAT(1).pos - BAT(i).pos)/ub);
BAT(i).lDiff=abs((bBAT(i).pos - BAT(i).pos)/ub);
BAT(i).Pulse_Frequency=Max_Freq-(Max_Freq-Min_Freq)*(BAT(i).gDiff);
BAT(i).velocity=initial_velocity+(max_velocity-initial_velocity)*(BAT(i).Pulse_Frequency/Max_Freq);

end
% Save personal best
bBAT= BAT;     % This is the first iteration so: Personal best= the same BAT(Particle).

% Determine the global best among the bBAT
[~, index]= max([bBAT.cost]);

% Save the Global optimum
gBAT= BAT(index);

gAVR= mean([BAT.gDiff]);  % Average globalDiff
lAVR= mean([BAT.lDiff]);  % Average localDiff


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
    AVRf= mean([BAT.Pulse_Frequency])  % Average BAT cost for plotting

    loudness= alpha*loudness;
    gAVR= mean([BAT.gDiff]);  % Average globalDiff
    lAVR= mean([BAT.lDiff]);  % Average localDiff
    
    xx= [];
    yy= [];
    zz= [];
        
    for i=1:NB
        
        % Choose new Frequency randomely
        %BAT(i).Pulse_Frequency= Min_Freq+(Max_Freq - Min_Freq)*rand;
        
        BAT(i).gDiff=abs((gBAT(iter).pos - BAT(i).pos));
        BAT(i).lDiff=abs((bBAT(i).pos - BAT(i).pos));
        BAT(i).Pulse_Frequency=Max_Freq-(Max_Freq-Min_Freq)*(BAT(i).gDiff);
        BAT(i).velocity=initial_velocity+(max_velocity-initial_velocity)*(BAT(i).Pulse_Frequency/Max_Freq);

       
        
        %Doppler effect is applied where frequency is increased if near
        %personal best and far from global best
        %Fo=(V-+Vo/V-+Vs)Fs
        if(BAT(i).lDiff<lAVR & BAT(i).gDiff>gAVR )        
        Numer=(340+BAT(i).velocity);
        Denome=(340-gBAT(iter).velocity);
        elsie=(Numer./Denome)
        BAT(i).Pulse_Frequency=(Numer./Denome).*gBAT(iter).Pulse_Frequency;
        
        if(BAT(i).Pulse_Frequency>Max_Freq)
          BAT(i).Pulse_Frequency=Max_Freq;
        end
        
        %BAT(i).velocity= BAT(i).gDiff.*(BAT(i).Pulse_Frequency);
        BAT(i).velocity=(max_velocity-initial_velocity)*(BAT(i).Pulse_Frequency/Max_Freq);
        
        b=gBAT(iter).Pulse_Frequency;
        
        %INTENSIFY LOCAL SEARCH BEST TOWARDS GLOBAL BEST
        else
         Numer=(340-BAT(i).velocity);
         Denome=(340+gBAT(iter).velocity);
         BAT(i).Pulse_Frequency=(Numer./Denome).*gBAT(iter).Pulse_Frequency;
         if(BAT(i).Pulse_Frequency<Min_Freq)
          BAT(i).Pulse_Frequency=Min_Freq;
          end
         %BAT(i).velocity= BAT(i).gDiff.*(BAT(i).Pulse_Frequency);
         BAT(i).velocity=(max_velocity-initial_velocity)*(BAT(i).Pulse_Frequency/Max_Freq);
         
        
        end
        
        % Update position
        BAT(i).pos= BAT(i).pos + BAT(i).velocity;
        
        % Check a switching condition
        if rand<emission_rate
            eps= 10;
            freq=BAT(i).Pulse_Frequency/Max_Freq;
            BAT(i).pos= gBAT(iter).pos+eps*randn(1, 2)*loudness;
        end
        
        %% Handling Boundaries:
        CrossUp= BAT(i).pos >= ub;             % Get the variables which crossed the upper boundary after updating position
        BAT(i).pos(CrossUp)= ub;      % and set them= upper bounds.
        
        CrossDown= BAT(i).pos <= lb;           % Get the variables which crossed the lower boundary after updating position
        BAT(i).pos(CrossDown)= lb;  % and set them= lower bounds.
   
        %% Evaluate position
        [BAT(i).cost,~]= MainSVMFunction(X_train,Y_train,CV_Part,class_type,selectKernel,BAT(i).pos(1),BAT(i).pos(2));   
        
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
    figure(1);
    if plot_type
        subplot(2, 2, [1 3]); dd= surf(X, Y, Z); dd.EdgeAlpha= 0.3;
        title({['SVM function'], ['Optimum Z= ' num2str(gBAT(end).cost)]}, 'FontSize', 10);
        xlabel('X');
        ylabel('Y');
        cc= gca;
        %cc.CameraPosition= [-15.4048  -22.5827  871.7489];        
        hold on
        s1=scatter3(xx, yy, zz+0.1, 50, 'fill', 'k');
        s2=scatter3(gBAT(end).pos(1), gBAT(end).pos(2), gBAT(end).cost+0.2, 75, 'fill', 'y');
        colormap(hsv(10000));
        col= colorbar;
        col.Label.String= 'Z value';
        legend([s1 s2], 'Bats', 'Optimum', 'Location','northwest');
        hold off
    elseif ~plot_type
        subplot(2, 2, [1 3]); contour(X, Y, Z);
        title({'SVM function', ['Optimum Z= ' num2str(gBAT(end).cost)]}, 'FontSize', 10);
        xlabel('X');
            ylabel('Y');
            hold on
            s1=scatter(xx, yy, 'fill','k');
            s2=scatter(gBAT(end).pos(1), gBAT(end).pos(2), 'fill','r');
            legend([s1 s2], 'Bats', 'Optimum')
            hold off
    end
    subplot(2, 2, 2); plot(1:iter, loudness_vector);
    axis([0 Max_iter 0 1]);
    title(['Loudness= ' num2str(loudness), '     alpha= ', num2str(alpha)], 'FontSize', 10);
    xlabel('Iteration'); ylabel('Loudness')
    grid
    hold on
    scatter(iter, loudness_vector(end));
    hold off
    subplot(2, 2, 4); plot(1:iter, emission_rate_vector);
    axis([0 Max_iter 0 1]);
    title(['Emission rate= ' num2str(emission_rate), '     gamma= ', num2str(gamma)], 'FontSize', 10);
    xlabel('Iteration'); ylabel('Emission rate')
    grid;
    hold on
    scatter(iter, emission_rate_vector(end));
    hold off
    drawnow;

    % Break the loop if:
    if gBAT(iter).cost==100 
         %break;
    end
    
end

%%

bestKscale=gBAT(iter).pos(1);
bestBConstraint=gBAT(iter).pos(2);


[~,finalMdl]= MainSVMFunction(X_train,Y_train,CV_Part,class_type,selectKernel,bestBConstraint,bestKscale);
                  
% Test Accuracy of model

testLabels = predict(finalMdl.Trained{1},X_test);

% Confusion Mat
conMat=confusionmat(testLabels,Y_test);

time_duration=num2str(toc);
% F-MEASURE RECALL PRECISION AND ACCURACY
if(class_type==1)
final_model_accuracy=((conMat(1,1)+conMat(2,2))/(conMat(1,1)+conMat(1,2)+conMat(2,1)+conMat(2,2)))*100

precision=((conMat(1,1))/(conMat(1,1)+conMat(1,2)));
precisionPerc=((conMat(1,1))/(conMat(1,1)+conMat(1,2)))*100
recall=((conMat(1,1))/(conMat(1,1)+conMat(2,1)));
recallPerc=((conMat(1,1))/(conMat(1,1)+conMat(2,1)))*100

tnr=((conMat(2,2))/(conMat(2,2)+conMat(1,2)));
fmeasure=2*recall*precision/(recall+precision)*100;
gmean=sqrt(recall*tnr)*100;
end

if(class_type==2)
final_model_accuracy=((conMat(1,1)+conMat(2,2)+conMat(3,3)+conMat(4,4))/((conMat(1,1)+conMat(1,2)+conMat(1,3)+conMat(1,4)+conMat(2,1)+conMat(2,2)+conMat(2,3)+conMat(2,4)+conMat(3,1)+conMat(3,2)+conMat(3,3)+conMat(3,4)+conMat(4,1)+conMat(4,2)+conMat(4,3)+conMat(4,4))))*100;
precision=((conMat(1,1)+conMat(2,2)+conMat(3,3)+conMat(4,4))/(conMat(1,1)+conMat(2,2)+conMat(3,3)+conMat(4,4)+conMat(1,2)+conMat(1,3)+conMat(1,4)+conMat(2,1)+conMat(2,3)+conMat(2,4)+conMat(3,1)+conMat(3,2)+conMat(3,4)+conMat(4,1)+conMat(4,2)+conMat(4,3)));
precisionPerc=precision*100;
recall=((conMat(1,1)+conMat(2,2)+conMat(3,3)+conMat(4,4))/(conMat(1,1)+conMat(2,2)+conMat(3,3)+conMat(4,4)+conMat(2,1)+conMat(3,1)+conMat(4,1)+conMat(1,2)+conMat(3,2)+conMat(4,2)+conMat(1,3)+conMat(2,3)+conMat(4,3)+conMat(1,4)+conMat(2,4)+conMat(3,4)));
recallPerc=recall*100;
fmeasure=2*recall*precision/(recall+precision)*100;
end


%% results
disp('======================================');
disp([' Time  '  num2str(toc)]);

figure;
subplot(1, 2, 1); plot(1:iter, best, 'b', 'Linewidth', 1);
% hold on
% Sca= scatter(1:iter, best,10 , 'filled', 'Marker' , '0', 'MarkerfaceColor' , 'r');
% hold off
title('Global Best')
xlabel('iteration');
ylabel('Z Value');
legend('Best solution');
grid on
subplot(1, 2, 2); plot(1:iter, AVR, 'r');
title('Average Z of Bats')
xlabel('iteration');
ylabel('Z Value');
legend('Avrg Z');
grid on;

end

