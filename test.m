a = openAIAssistant(Assistant_id, API_key);
a.retrieve();


% while loop for user input and print chatgpt response
while true
    a.Create_thread();
    user_input = input("You: ", 's');
    if user_input == "exit"
        break
    end
    a.create_message(string(user_input));
    res = a.create_run();
    run_id = res.Body.Data.id;
    pause(2);
    run_status = a.check_run_status(run_id);
    if run_status == "completed"
        return_message = a.get_message();
        display("ChatGPT: ");
        a.deal_message_and_print(return_message);
    end
end
