function progressbar(d,current_iteration,Max_iteration)


    % Perform calculations
    % ...
    
    progressValue=current_iteration/Max_iteration;
    
    if(progressValue<0.33)
    d.Value = progressValue; 
    d.Message = 'Pre processing data';
    pause(1)
    
    elseif(progressValue>=0.33 && progressValue<0.67)
        
    % Perform calculations
    % ...
    d.Value = progressValue;
    d.Message = 'Optimizing SVM';
    pause(1)
    elseif(progressValue>=0.67 && progressValue<0.90)
        
    % Perform calculations
    % ...
    d.Value = progressValue;
    d.Message = 'Finishing optimization';
    pause(1)
    elseif(progressValue>=0.90)

    % Finish calculations
    % ...
    d.Value = progressValue;
    d.Message = 'SVM optimized!';
    pause(1)
    close(d)
    end

    % Close dialog box
end