# Matlab access assistant api 

### 1. requirement

matlab.net package

### 2. example and usage

读取assistant，需要两个值，assistant_id, api_key

a = openAIAssistant(assis_id,api_key);
a.retrieve();

至此，已经创建好对象，可以利用内建的函数来发送消息或者上传文件。

#### 2.1 file search 文件搜索
文件搜索类型，用于llm对文本处理，从文本中获取知识，回答。

1. 添加文件， file_id = a.add_file_to_assis("file_name");
2. 删除文件， a.delete_file_from_assis(file_id);
3. 删除文件使用文件名， a.delete_file_by_name_from_assis("file_name");


#### 2.2 code_interpreter 代码处理
代码处理类型文件，用于内建的python环境，可以被代码处理的文件，最好是csv，或者xlsx文件。具体见这个链接https://platform.openai.com/docs/assistants/tools/code-interpreter/supported-files

1. 添加文件， a.add_file_to_code_interpreter("file_name");
2. 删除文件， a.delete_file_from_code_interpreter(file_id);
3. 删除文件使用文件名， a.delete_file_by_name_from_code_interpreter("file_name");

### 3. 对话
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