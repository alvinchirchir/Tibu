function [X_train,Y_train,X_test,Y_test,Cancer_CV]=cervical_cancer_behavior_preProcessData(SelectedFile)

%SelectedFile=('C:\Users\Alvin\Documents\SvmGUI\Datasets\cervical_cancer_behavior.csv');
opts = detectImportOptions(SelectedFile);
temp_data=readtable(SelectedFile,opts);

%opts = detectImportOptions(SelectedFile);
%temp_data=readtable(SelectedFile,opts);

%check if there any missing if there are any replace with mean of window
%size 10
temp_data = fillmissing(temp_data,'movmedian',10);

%Get Feature names 
feature_names=cellstr(strrep(temp_data.Properties.VariableNames,'_',''));

%convert table to cell for ease of manipulation
data=table2cell(temp_data);

%Find size of data
row_size=size(data,1);
column_size=size(data,2);

%Data set has two classes labelled 1 and 0 convert to 1 and 2 respectively
%1 represents present
%2 represents absent

%Index values in cells Cervical cancer absent to 1 and Cervical cancer
    
for count_j=1:row_size
    if isequal(data(count_j,column_size),{0})
    data(count_j,column_size)={1};
    elseif isequal(data(count_j,column_size),{1})
    data(count_j,column_size)={2};
    end      
end
%convert to matrix
X_value=cell2mat(data(:,1:column_size-1));
Y_value=cell2mat(data(:,column_size));


%Randomly shuffle rows 
rand_num=randperm(row_size);

X_shuff_value=X_value(rand_num(1:end),:);

Y_shuff_value=Y_value(rand_num(1:end),:);





%% Partition our training set using kfold

Y_pre_CV=cvpartition(Y_shuff_value,'HoldOut',0.2,'Stratify',true);

trainIndices=training(Y_pre_CV);
testIndices=test(Y_pre_CV);

%Partition the training using Kfold 5 times
Cancer_CV=cvpartition(Y_shuff_value(trainIndices,:),'KFold',5,'Stratify',true);



%% Split data in Training and Testing

X_train=X_shuff_value(trainIndices,:);
Y_train=Y_shuff_value(trainIndices,:);


X_test=X_shuff_value(testIndices,:);
Y_test=Y_shuff_value(testIndices,:);

end
