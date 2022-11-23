
function [X_train,Y_train,X_test,Y_test,CV_Part]=acute_preProcessData(SelectedFile)


%SelectedFile='C:\Users\Alvin\Documents\SvmGUI\Datasets\acute_inflammation.csv';

opts = detectImportOptions(SelectedFile);



%opts = detectImportOptions('C:\Users\Alvin\Documents\MatLab SVM Diseases\Datasets\acute_inflammation.csv');


%temp_data=readtable('C:\Users\Alvin\Documents\MatLab SVM Diseases\Datasets\acute_inflammation.csv',opts);

temp_data=readtable(SelectedFile,opts);


%Check if there any missing if there are any replace with mean of window of size 10
%F = fillmissing(temp_data,'movmedian',10);

%Get Feature names 
feature_names=cellstr(strrep(temp_data.Properties.VariableNames,'_',''));

%convert table to cell for ease of manipulation
data=table2cell(temp_data);

%Find size of data
row_size=size(data,1);
column_size=size(data,2);

X_temp(row_size,column_size)=0;



%Replace temperature value from comma based to dot based ie 35,5 to 35.5
for count=1:row_size
    data(count,1)=strrep(data(count,1),',','.');
end

X_temp(:,1)=str2double(data(:,1));


%Index values in cells 
for count_i=1:column_size-2
    
    for count_j=1:row_size
       
    if strcmpi(data(count_j,count_i),'yes')
        X_temp(count_j,count_i)=2;
    elseif strcmpi(data(count_j,count_i),'no')
        X_temp(count_j,count_i)=1;
    end
    end        
end

%%Group the conditions into 1,2,3,4 
    for count_a=1:row_size
    if strcmpi(data(count_a,7),'no') && strcmpi(data(count_a,8),'no')
        X_temp(count_a,7)=1;
    elseif strcmpi(data(count_a,7),'no') && strcmpi(data(count_a,8),'yes')
        X_temp(count_a,7)=2;
    elseif strcmpi(data(count_a,7),'yes') && strcmpi(data(count_a,8),'no')
        X_temp(count_a,7)=3;
    elseif strcmpi(data(count_a,7),'yes') && strcmpi(data(count_a,8),'yes')
        X_temp(count_a,7)=4;
    end
    end 

%Take feature values from column 1 to 6 
X_value=X_temp(:,1:6);

%Extract Inflammation Diagnosis
Y_value=X_temp(:,7);


%Shuffle Rows
rand_num=randperm(row_size);

X_shuff_value=X_value(rand_num(1:end),:);


Y_shuff_value=Y_value(rand_num(1:end),:);


%% Partition our training set using kfold

Y_pre_CV=cvpartition(Y_shuff_value,'HoldOut',0.2,'Stratify',true);

trainIndices=training(Y_pre_CV);
testIndices=test(Y_pre_CV);

%%Partition the training using Kfold 5 times
CV_Part=cvpartition(Y_shuff_value(trainIndices,:),'KFold',5,'Stratify',true);



%% Split data in Training and Testing

X_train=X_shuff_value(trainIndices,:);
Y_train=Y_shuff_value(trainIndices);


X_test=X_shuff_value(testIndices,:);
Y_test=Y_shuff_value(testIndices,:);


end

