a = openAIAssistant(assis_id,api_key);
a.retrieve();   % retrieve the assistant 
file_list = a.get_files();  % get the files in the assistant

% upload file, if you have old file_id, use
% a.update_single_file(file_name,old_file_id)
file_id=a.update_single_file("Cell_states_data.xlsx");

a.update_instruction("我们有一个利用微流控技术控制的细胞培养平台，我们利用matlab作为控制软件，我们会实时获取系统状态，包含细胞种类数量。你作为一个AI助手，帮助我们读取系统的状态，回答问题，调用我们的硬件控制系统的函数操控系统。系统状态文件是一个xlsx文件，Cell_states_data.xlsx中sheet1中有时间和细胞种类信息。第一行是细胞种类，第一列是时间。sheet2中有c1和c2细胞的增值情况。")

% while loop for user input and print chatgpt response
% while true
%     a.Create_thread();
%     user_input = input("You: ", 's');
%     if user_input == "exit"
%         break
%     end
%     a.create_message(string(user_input));
%     res = a.create_run();
%     run_id = res.Body.Data.id;
%     pause(2);
%     run_status = a.check_run_status(run_id);
%     if run_status == "completed"
%         return_message = a.get_message();
%         display("ChatGPT: ");
%         a.deal_message_and_print(return_message);
%     end
% end
