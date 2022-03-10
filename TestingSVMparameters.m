clear
clc

load SvmFunction

bConst=100000000;
kScal=bConst;
  
FoldLoss(5,2)=0;

%iteration_increase_box=0.01;

%while(b<=1000)

Mdl_Linear=svmtrain(X_train,Y_train,...,
                        'KernelFunction','linear',...,
                        'CVPartition',CV_Part,...
                        'KernelScale',kScal,...
                        'BoxConstraint',bConst,...
                        'Standardize',1);
FoldLoss(1,1)=1;
FoldLoss(1,2)=(1-kfoldLoss(Mdl_Linear,'LossFun','ClassifError'))*100;



          
                    
Mdl_rbf=fitcsvm(X_train,Y_train,...,
                        'KernelFunction','rbf',...
                        'CVPartition',CV_Part,...
                        'KernelScale',1/sqrt(kScal),...
                        'BoxConstraint',bConst,...
                        'Standardize',1);
FoldLoss(2,1)=2;
FoldLoss(2,2)=(1-kfoldLoss(Mdl_rbf,'LossFun','ClassifError'))*100;




Mdl_polynomial_1=fitcsvm(X_train,Y_train,...,
                        'KernelFunction','polynomial',...
                        'CVPartition',CV_Part,...
                        'KernelScale',kScal,...
                        'BoxConstraint',bConst,...
                        'Standardize',1);
FoldLoss(3,1)=3;
FoldLoss(3,2)=(1-kfoldLoss(Mdl_polynomial_1,'LossFun','ClassifError'))*100;


Mdl_polynomial_10=fitcsvm(X_train,Y_train,...,
                        'KernelFunction','polynomial',...,
                        'PolynomialOrder',10,...,
                        'CVPartition',CV_Part,...,
                        'KernelScale',kScal,...
                        'BoxConstraint',bConst,...
                        'Standardize',1);

                    
FoldLoss(4,1)=4;
FoldLoss(4,2)=(1-kfoldLoss(Mdl_polynomial_10,'LossFun','ClassifError'))*100;


Mdl_gaussian=fitcsvm(X_train,Y_train,...,
                        'KernelFunction','gaussian',...
                        'CVPartition',CV_Part,...
                        'KernelScale',kScal,...
                        'BoxConstraint',bConst,...
                        'Standardize',1);
FoldLoss(5,1)=5;
FoldLoss(5,2)=(1-kfoldLoss(Mdl_gaussian,'LossFun','ClassifError'))*100;

                    
%iteration_increase=iteration_increase*10;

%end
                    
                    
                    