function [bBAT, gBAT]= Bat_Algorithm_Demo(Par)
%  =============================================================
%    Standard Bat Optimization Algorithm Version Demo
%  =============================================================
%    Validating Bat Alogirthm using eggcrate function
%
%    Programmed by: Haydar Khayou @Damascus University, Syria
%    June 6, 2020
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% 
% References: ----------------------------------------------------------- %
% 1) Yang X.S. (2010). A New Metaheuristic Bat-Inspired Algorithm, In:    %
%   Nature-Inspired Cooperative Strategies for Optimization (NICSO 2010), %
%   Studies in Computational Intelligence, vol 284. Springer, Berlin.     %
%   https://doi.org/10.1007/978-3-642-12538-6_6                           %
% 2) Yang X.S. (2014). Nature-Inspired Optimization Algorithms, Elsevier. %
% 3) XS Yang (2020). The Standard Bat Algorithm (BA)
%   (https://www.mathworks.com/matlabcentral/fileexchange/74768-the-standard-bat-algorithm-ba),
%    MATLAB Central File Exchange. Retrieved June 4, 2020.
% 4) Haydar Khayou (2020). Standard Bat Algorithm
%    (https://www.mathworks.com/matlabcentral/fileexchange/76595-standard-bat-algorithm),
%     MATLAB Central File Exchange. Retrieved June 5, 2020.
%
% [bBAT, gBAT]= Bat_Algorithm(Par)
% par= [NB, Min_Freq, Max_Freq, init_Vel, Max_iter, Plot_Type]
%
% where:
%   - NB= swarm sie;
%   - Min_Freq= Minimum frequency;
%   - Max_Freq= Maximum frequency;
%   - init_Vel= Bats initial velocity.
%   - Max_iter= maximum number of iteration.
%   - Plot_Type= surf or contour.

%% Start
if nargin<1
    help Bat_Algorithm
    Par= [30, 0, 0.05, 0, 120, 1];
end
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
lb= -5;   % lower bound of your variables
ub= 5;   % upper bound of your variables

[X, Y]= meshgrid(lb:0.1:ub, lb:0.1:ub);
Z= X.^2 + Y.^2 + (25 * (sin(X).^2 + sin(Y).^2));

xlabel('X');
ylabel('Y');


%%  Objective Function
Fitness= @(S) S(1).^2 + S(2).^2 + (25 * (sin(S(1)).^2 + sin(S(2)).^2));

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
    BAT(i).cost= Fitness(BAT(i).pos);
    
    % Determine initial velocity.
    BAT(i).velocity= init_Vel.*ones(1, 2);
    
    % Determine Frequency.
    BAT(i).Pulse_Frequency= 0.*ones(1, 2);
end

% Save personal best
bBAT= BAT;     % This is the first iteration so: Personal best= the same BAT(Particle).

% Determine the global best among the bBAT
[~, index]= min([bBAT.cost]);

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
    if iter==2
        pause(5);
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
        BAT(i).cost= Fitness(BAT(i).pos);
        
        % Update bBAT if the following condition is satisfied
        if ((BAT(i).cost<=bBAT(i).cost) && (rand>loudness))
            bBAT(i)= BAT(i);
        end
        xx= [xx BAT(i).pos(1)];
        yy= [yy BAT(i).pos(2)];
        zz= [zz BAT(i).cost];
    end  % Here is the end of updating BATS
    
    iter= iter+1;
    
    %% Update Global Best
    [~, index]= min([bBAT.cost]);
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
        title({['Eggcrate function'], ['Optimum Z= ' num2str(gBAT(end).cost)]}, 'FontSize', 10);
        xlabel('X');
        ylabel('Y');
        cc= gca;
        cc.CameraPosition= [-15.4048  -22.5827  871.7489];        
        hold on
        s1=scatter3(xx, yy, zz+2, 50, 'fill', 'k');
        s2=scatter3(gBAT(end).pos(1), gBAT(end).pos(2), gBAT(end).cost+2, 75, 'fill', 'y');
        colormap(hsv(10000));
        col= colorbar;
        col.Label.String= 'Z value';
        legend([s1 s2], 'Bats', 'Optimum', 'Location','northwest');
        hold off
    elseif ~plot_type
        subplot(2, 2, [1 3]); contour(X, Y, Z);
        title({'Eggcrate function', ['Optimum Z= ' num2str(gBAT(end).cost)]}, 'FontSize', 10);
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
    if gBAT(iter).cost==0  % Change this tolerance condition to fit your case
%         break;
    end
    
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
