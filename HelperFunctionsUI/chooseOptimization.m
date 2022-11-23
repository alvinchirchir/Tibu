
function [model_accuracy,conMat,finalMdl,time_duration,bestKscale,bestBConstraint]=chooseOptimization(fnameoptimization,rangeValue)
       switch fnameoptimization 
          case 'BatOptimization.m'
              [model_accuracy,conMat,finalMdl,time_duration,bestKscale,bestBConstraint]=BatOptimization(rangeValue);
          case 'ParticleSwarmOptimization.m'
              [model_accuracy,conMat,finalMdl,time_duration,bestKscale,bestBConstraint]=ParticleSwarmOptimization(rangeValue);
          case 'WhaleOptimization.m'
              [model_accuracy,conMat,finalMdl,time_duration,bestKscale,bestBConstraint]=WhaleOptimization(rangeValue);
          case 'ModifiedBatOptimization.m'
              [model_accuracy,conMat,finalMdl,time_duration,bestKscale,bestBConstraint]=+(rangeValue); 
       end
end 