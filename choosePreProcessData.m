
function [X_train,Y_train,X_test,Y_test,CV_Part]=choosePreProcessData(SelectedFile)

       switch SelectedFile
          % BINARY
          case 'C:\Users\Alvin\Documents\SvmGUI\Datasets\coimbra.csv'       
              [X_train,Y_train,X_test,Y_test,CV_Part]=coimbra_preProcessData(SelectedFile);
              kScale=1;
              bConstraint=1;
              class_type=1;
              SvmFunction=MainSVMFunction(X_train,Y_train,CV_Part,class_type,kScale,bConstraint);               
              save SvmFunction
              
          case 'C:\Users\Alvin\Documents\SvmGUI\Datasets\breast_cancer_winsconsin_diagnostic.csv'       
              [X_train,Y_train,X_test,Y_test,CV_Part]=breast_cancer_winsconsin_diagnostic_preProcessData(SelectedFile);
              kScale=1;
              bConstraint=1;
              class_type=1;
              SvmFunction=MainSVMFunction(X_train,Y_train,CV_Part,class_type,kScale,bConstraint);               
              save SvmFunction
              
          case 'C:\Users\Alvin\Documents\SvmGUI\Datasets\cervical_cancer_behavior.csv'       
              [X_train,Y_train,X_test,Y_test,CV_Part]=cervical_cancer_behavior_preProcessData(SelectedFile);
              kScale=1;
              bConstraint=1;
              class_type=1;
              SvmFunction=MainSVMFunction(X_train,Y_train,CV_Part,class_type,kScale,bConstraint);               
              save SvmFunction
              
          % MULTICLASS    
          case 'C:\Users\Alvin\Documents\SvmGUI\Datasets\acute_inflammation.csv'          
              [X_train,Y_train,X_test,Y_test,CV_Part]=acute_preProcessData(SelectedFile);
              kScale=1;
              bConstraint=1;
              class_type=2;
              SvmFunction=MainSVMFunction(X_train,Y_train,CV_Part,class_type,kScale,bConstraint);              
              save SvmFunction
          
          case 'C:\Users\Alvin\Documents\SvmGUI\Datasets\lung_cancer.csv'       
              [X_train,Y_train,X_test,Y_test,CV_Part]=lung_cancer_preProcessData(SelectedFile);
              kScale=1;
              bConstraint=1;
              class_type=2;
         
              SvmFunction=MainSVMFunction(X_train,Y_train,CV_Part,class_type,kScale,bConstraint);               
              save SvmFunction
              
          case 'C:\Users\Alvin\Documents\SvmGUI\Datasets\lymphography.csv'       
              [X_train,Y_train,X_test,Y_test,CV_Part]=lymphography_preProcessData(SelectedFile);
              kScale=1;
              bConstraint=1;
              class_type=2;
              SvmFunction=MainSVMFunction(X_train,Y_train,CV_Part,class_type,kScale,bConstraint);               
              save SvmFunction
           
          
       end
    
end  