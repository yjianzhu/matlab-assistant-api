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
            % Get the message object
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
        
        % file modify, upload, delete. April 6,2024 by yjianzhu
        function file_list = get_files(this)
            % Get the file list attached to the assistant,
            % curl https://api.openai.com/v1/assistants/asst_abc123/files \
            % -H "Authorization: Bearer $OPENAI_API_KEY" \
            % -H "Content-Type: application/json" \
            % -H "OpenAI-Beta: assistants=v1"
            file_list = llms.internal.Assistant_get(this.api_key, this.api_url + "/files");
        end

        function delete_file(this, file_id)
            % Delete a file attached to the assistant,
            % curl https://api.openai.com/v1/assistants/asst_abc123/files/file-abc123 \
            % -H "Authorization: Bearer $OPENAI_API_KEY" \
            % -H "Content-Type: application/json" \
            % -H "OpenAI-Beta: assistants=v1" \
            % -X DELETE   
            %file_id = string(file_id);
            llms.internal.Assistant_delete(this.api_key, this.api_url + "/files/" + file_id);
        end
        
        function file_id = upload_file(this, file_path)
            % Upload a file to openai storage.
            % curl https://api.openai.com/v1/files \
            % -H "Authorization: Bearer $OPENAI_API_KEY" \
            % -F purpose="assistants" \
            % -F file="@mydata.jsonl"
            return_obj = llms.internal.openai_upload_file(this.api_key, "https://api.openai.com/v1/files", file_path);
            file_id = return_obj.Body.Data.id;
        end

        function file_id = update_single_file(this,file_path,old_file_id)
            % Delete old file and upload new file. 如果没有给old_file_id，则删除所有文件.
            % curl https://api.openai.com/v1/assistants/asst_abc123/files \
            % -H 'Authorization: Bearer $OPENAI_API_KEY"' \
            % -H 'Content-Type: application/json' \
            % -H 'OpenAI-Beta: assistants=v1' \
            % -d '{
            %   "file_id": "file-abc123"
            % }'
        
          
            arguments
                this
                file_path 
                old_file_id  = ""
            end

            if old_file_id ~= ""
                this.delete_file(old_file_id);
            else
                % Get the file list
                file_list = this.get_files();
                % Delete the old file
                for i = 1:length(file_list.Body.Data.data)
                    this.delete_file(file_list.Body.Data.data(i).id);
                end
            end

            % Upload the new file by modify the assistant
            file_id = this.upload_file(file_path);

            % link the file to the assistant
            llms.internal.Assistant_post(this.api_key, this.api_url + "/files", {"file_id", file_id});
        end

        function update_instruction(this, instruction)
            % Update the instruction of the assistant
            % curl https://api.openai.com/v1/assistants/asst_abc123 \
            % -H "Content-Type: application/json" \
            % -H "Authorization: Bearer $OPENAI_API_KEY" \
            % -H "OpenAI-Beta: assistants=v1" \
            % -d '{
            %     "instructions": "You are an HR bot, and you have access to files to answer employee questions about company policies. Always response with info from either of the files.",
            %     "tools": [{"type": "retrieval"}],
            %     "model": "gpt-4",
            %     "file_ids": ["file-abc123", "file-abc456"]
            %     }'
            % POST
            llms.internal.Assistant_post(this.api_key, this.api_url, {"instructions", instruction});
        end

        function file_id = add_file(this,file_path)
            file_id = this.upload_file(file_path);
            llms.internal.Assistant_post(this.api_key, this.api_url + "/files", {"file_id", file_id});
        end

        function delete_all_files(this)
            % Delete all files attached to the assistant
            % Get the file list
            file_list = this.get_files();
            for i = 1:length(file_list.Body.Data.data)
                this.delete_file(file_list.Body.Data.data(i).id);
            end
        end

        function clear_storage(this)
            % Clear the all files in storage，
            % Get curl https://api.openai.com/v1/files \
            % -H "Authorization: Bearer $OPENAI_API_KEY"
            all_files = llms.internal.openai_get(this.api_key, "https://api.openai.com/v1/files");
            file_list = this.get_files();
            % store the file id in the file_list.Body.Data.data.id
            file_list_id = {};
            for i = 1:length(file_list.Body.Data.data)
                file_list_id{i} = file_list.Body.Data.data(i).id;
            end

            % delete all the files in the storage, not attached to the assistant
            for i = 1:length(all_files.Body.Data.data)
                if ~ismember(all_files.Body.Data.data(i).id, file_list_id)
                    %curl https://api.openai.com/v1/files/file-abc123 \
                    % -X DELETE \
                    % -H "Authorization: Bearer $OPENAI_API_KEY"

                    llms.internal.openai_delete(this.api_key, "https://api.openai.com/v1/files/" + all_files.Body.Data.data(i).id);
                end
            end

        end
    end 
 
end
