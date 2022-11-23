
function [model_accuracy,conMat,finalMdl,time_duration,bestKscale,bestBConstraint]=chooseSVM(fname,fromRange,toRange)
       switch fname
          case 'acute_inflammation.csv'
              [model_accuracy,conMat,finalMdl,time_duration,bestKscale,bestBConstraint]=Acute_diagnosis(fromRange,toRange);
          case 'coimbra.csv'
              %[model_accuracy,conMat,Mdl]=Coimbra_diagnosis(fromRange,toRange);
          case 'lymphography.csv'
             % [model_accuracy,conMat,Mdl]=Lymphography_diagnosis(fromRange,toRange); 
       end
    
end 