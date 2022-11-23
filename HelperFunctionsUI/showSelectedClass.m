
function [class_nm]=showSelectedClass(SelectedFile)

opts = detectImportOptions(SelectedFile);

temp_data=readtable(SelectedFile,opts);


data=table2cell(temp_data);
class_nm=string(data(:,1));

end 