function [FoldLoss,Mdl] = MainSVMFunction(X_train,Y_train,CV_Part,class_type,bConstraint,kScale)
%If there are no input set values to 1 
%Both parameters have a default setting of 1 
if nargin<1  
    kScale=1;
    bConstraint=1;
  elseif kScale<1 || bConstraint<1
    kScale=1;
    bConstraint=1;

  elseif kScale<1 && bConstraint<1
    kScale=1;
    bConstraint=1;
end

if(class_type==1)

Mdl=fitcsvm(X_train,Y_train,...,
                        'KernelFunction','rbf',...
                        'CVPartition',CV_Part,...
                        'KernelScale',kScale,...
                        'BoxConstraint',bConstraint,...
                        'Standardize',1);
                    
%% Train model

elseif (class_type==2)

template=templateSVM(...
                 'KernelFunction','rbf',...
                 'KernelScale',kScale,...
                 'BoxConstraint',bConstraint,...
                 'Standardize',true);

Mdl = fitcecoc(X_train,Y_train,...
                        'Learners',template,'CVPartition',CV_Part); 
                    

                    

end

                    
FoldLoss=(1-kfoldLoss(Mdl))*100;

end

                    
                    
                    
                    