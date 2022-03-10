function [predictionPatient]=diagnosePatient(TrainedModelsLocation,symptoms)


load(TrainedModelsLocation)



PatientSymptoms(:,:)=str2double(symptoms(:,:));

predictionPatient=predict(svm_model_save.Trained{1},PatientSymptoms);

predictionPatient=num2str(predictionPatient);





end

                    
                    
                    
                    