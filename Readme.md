# Matlab access assistant api 

### 1. requirement

matlab.net package

### 2. example and usage

读取assistant，需要两个值，assistant_id, api_key

a = openAIAssistant(assis_id,api_key);
a.retrieve();

至此，已经创建好对象，可以利用内建的函数来发送消息或者上传文件。

1. 添加文件， file_id = a.add_file("file_name");
2. 删除文件，a.delete_file();
3. 更改指示。a.update_instruction("message")
4. 对话 
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
例如有三个文件需要上传，file1.txt, file2.txt, file3.txt

file1_id = a.add_file("file1.txt");
file2_id = a.add_file("file2.txt");
file3_id = a.add_file("file3.txt");

节省费用，可以需要的时候更新一次，不用每次都更新。
a.delete_file(file1_id);
a.add_file("file1.txt");
