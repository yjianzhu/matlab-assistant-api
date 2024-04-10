# Matlab access assistant api 

### 1. requirement

matlab.net package

### 2. example and usage

读取assistant，需要两个值，assistant_id, api_key

a = openAIAssistant(assis_id,api_key);
a.retrieve();

至此，已经创建好对象，可以利用内建的函数来发送消息或者上传文件。

1. 更新文件，file_id=a.update_single_file("Cell_states_data.xlsx");
    或者 file_id=a.update_single_file("Cell_states_data.xlsx"，old_file_id);    这里old_file_id 是用于替换旧的文件，如果整个参数省去，就默认删除所有的文件。
2. 删除文件，a.delete_all_files();
3. 添加单个文件 a.add_file("Cell_states_data.xlsx");
4. 更改指示。a.update_instruction("message")
5. 对话 
   先创建thread，a.Create_thread();
   创建消息a.create_message("hi"); 
   创建运算，res = a.create_run();
   run_id = res.Body.Data.id;
   检查运输是否完成
    run_status = a.check_run_status(run_id);
    if run_status == "completed"
        return_message = a.get_message();
        display("ChatGPT: ");
        a.deal_message_and_print(return_message);
    end


## 建议
最好在保留文件对应的fild_id，方便管理。