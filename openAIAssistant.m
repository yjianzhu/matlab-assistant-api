classdef(Sealed) openAIAssistant < handle
    %openAIChat Chat completion API from OpenAI.
    %Assis_client = openAIAssistant(assistant_id) creates with the assistant_id
    properties (SetAccess = public)
        assistant_id
        api_key
        api_url
        thread_id
    end

    methods
        function obj = openAIAssistant(assistant_id, api_key)
            %openAIAssistant Construct an instance of this class
            obj.assistant_id = assistant_id;
            obj.api_key = api_key;
            obj.api_url = "https://api.openai.com/v1/assistants/" + assistant_id;
        end

        function response = retrieve(this)
            %retrieve the assistant id
            %   assistant_cliend = retrieve(assistant_id) returns the assistant obj
            %   returns the completion of the prompt
            %   prompt: The prompt to complete
            %   max_tokens: The maximum number of tokens to generate
            %   temperature: The sampling temperature
            %   headers:   -H "Content-Type: application/json" \
                            %-H "Authorization: Bearer $OPENAI_API_KEY" \
                            %-H "OpenAI-Beta: assistants=v1"
            
            response = llms.internal.Assistant_get(this.api_key, this.api_url);
        end

        function thread_id = Create_thread(this)
            %Create a new thread
            %   thread_id = Create_thread(assistant_id) returns the thread id

            thread = llms.internal.Assistant_thread(this.api_key, "https://api.openai.com/v1/threads");
            % 读取其中的Body.Data.id
            % 保存到thread_id
            this.thread_id = thread.Body.Data.id;
            thread_id = thread.Body.Data.id;
        end

        function message_obj = create_message(this, message)
            %Create a new message
            %   curl https://api.openai.com/v1/threads/thread_abc123/messages \
            %   -H "Content-Type: application/json" \
            %   -H "Authorization: Bearer $OPENAI_API_KEY" \
            %   -H "OpenAI-Beta: assistants=v1" \
            %   -d '{
            %       "role": "user",
            %       "content": "How does AI work? Explain it in simple terms."
            %     }'
            
            message_obj = llms.internal.Assistant_message(this.api_key, "https://api.openai.com/v1/threads/" + this.thread_id + "/messages", message);
        end

        function run_obj = create_run(this)
            %curl https://api.openai.com/v1/threads/thread_abc123/runs \
            %   -H "Authorization: Bearer $OPENAI_API_KEY" \
            %   -H "Content-Type: application/json" \
            %   -H "OpenAI-Beta: assistants=v1" \
            %   -d '{
            %     "assistant_id": "asst_abc123",
            %     "instructions": "Please address the user as Jane Doe. The user has a premium account."
            %   }'
            run_obj = llms.internal.Assistant_run(this.api_key, "https://api.openai.com/v1/threads/" + this.thread_id + "/runs", this.assistant_id);
        end

        function return_status = check_run_status(this, run_id)
            %curl https://api.openai.com/v1/threads/thread_abc123/runs/run_abc123 \
            %   -H "Content-Type: application/json" \
            %   -H "Authorization: Bearer $OPENAI_API_KEY" \
            %   -H "OpenAI-Beta: assistants=v1"
            % 
            % while run.status in ['queued', 'in_progress', 'cancelling']
            while true
                return_obj = llms.internal.Assistant_check_run(this.api_key, "https://api.openai.com/v1/threads/" + this.thread_id + "/runs/" + run_id);
                if ismember( return_obj.Body.Data.status, ["queued", "in_progress", "cancelling"])
                    pause(1);
                else
                    break;
                end
            end
            return_status = return_obj.Body.Data.status;
        end
        function message_obj = get_message(this)
            %curl https://api.openai.com/v1/threads/thread_abc123/messages \
            %   -H "Content-Type: application/json" \
            %   -H "Authorization: Bearer $OPENAI_API_KEY" \
            %   -H "OpenAI-Beta: assistants=v1"
            message_obj=llms.internal.Assistant_get_message(this.api_key, "https://api.openai.com/v1/threads/" + this.thread_id + "/messages");
        end

        function deal_message_and_print(~,message_obj)
            %deal with the message and print
            %   message_obj: the message object
            %   print the message
            for i = 1:length(message_obj.Body.Data.data)-1
                % 依次输出message_obj.Body.Data.data[i].content.text.value
                disp(message_obj.Body.Data.data(i).content.text.value);
            end
        end
    end

end
