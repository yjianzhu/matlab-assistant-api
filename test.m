clear;

assis_id = "";
api_key  = "";

a = openAIAssistant(assis_id, api_key);

a.retrieve();
a.Create_thread();

a.create_message("你好？");
response = a.create_run();

run_id = response.Body.Data.id;
a.check_run_status(run_id);

return_mess = a.get_message();
a.deal_message_and_print(return_mess);