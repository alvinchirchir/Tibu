
function [temp_data,feature_names]=showSelectedTable(SelectedFile)


opts = detectImportOptions(SelectedFile);


temp_data=readtable(SelectedFile,opts);

%Get Feature names 
feature_names=cellstr(strrep(temp_data.Properties.VariableNames,'_',''))

end