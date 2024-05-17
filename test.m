clear;

assis_id = ;
api_key  =;


a = openAIAssistant(assis_id, api_key);

a.retrieve();
a.Create_thread();

disp("system files:");
a.print_file_list_of_assis();
a.print_file_list_of_code_interpreter();

% delete all the files in the vector_store
a.delete_all_files_from_assis();
a.delete_all_files_from_code_interpreter();

disp("all files deleted");
a.print_file_list_of_assis();
a.print_file_list_of_code_interpreter();

% upload the file to the vector_store
a.add_file_to_assis("cellexplain2.txt");
a.add_file_to_code_interpreter("Cell.csv");
disp("file uploaded");
a.print_file_list_of_assis();
a.print_file_list_of_code_interpreter();

return_mess = a.dialog("你好")

return_mess = a.dialog("第一个孔位有多少个细胞？")