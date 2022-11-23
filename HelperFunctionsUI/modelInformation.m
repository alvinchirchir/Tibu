
function [ModelClassNames,classLoss]=modelInformation(SelectedFile)
SVMModel = load(SelectedFile);
ModelClassNames=SVMModel.svm_model_save.Trained{1}.ClassNames;
CVSVMModel = SVMModel.svm_model_save;
classLoss=(1-kfoldLoss(CVSVMModel))*100;
end 

