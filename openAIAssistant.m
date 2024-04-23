classdef(Sealed) openAIAssistant < handle
    %openAIChat Chat completion API from OpenAI.
    %Assis_client = openAIAssistant(assistant_id) creates with the assistant_id
    properties (SetAccess = public)
        assistant_id
        api_key
        api_url
        thread_id
        map_filename_fileid % map file id to file name 
    end

    methods
        function obj = openAIAssistant(assistant_id, api_key)
            %openAIAssistant Construct an instance of this class
            obj.assistant_id = assistant_id;
            obj.api_key = api_key;
            obj.api_url = "https://api.openai.com/v1/assistants/" + assistant_id;
            obj.update_map();
        end
        
        function update_map(this)
            % update the map_filename_fileid
            % if map_filename_fileid is empty
            temp_map = this.map_filename_fileid;
            if isempty(this.map_filename_fileid)
                % read from "map_filename_fileid.mat"
                if isfile('map_filename_fileid.mat')
                    load('map_filename_fileid.mat', 'temp_map');
                else
                    this.map_filename_fileid = containers.Map;
                end
            else
                save('map_filename_fileid.mat', 'temp_map');
            end
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

            cell_data = {};

            thread = llms.internal.Assistant_post(this.api_key, "https://api.openai.com/v1/threads",cell_data);
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

            cell_message = {"role", "user"; "content", message};
            
            message_obj = llms.internal.Assistant_post(this.api_key, "https://api.openai.com/v1/threads/" + this.thread_id + "/messages",cell_message);
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

            % TODO steaming
            cell_data = {"assistant_id", this.assistant_id};
            run_obj = llms.internal.Assistant_post(this.api_key, "https://api.openai.com/v1/threads/" + this.thread_id + "/runs", cell_data);
        end

        function return_status = check_run_status(this, run_id)
            %curl https://api.openai.com/v1/threads/thread_abc123/runs/run_abc123 \
            % -H "Authorization: Bearer $OPENAI_API_KEY" \
            % -H "Content-Type: application/json" \
            % -H "OpenAI-Beta: assistants=v2"
            % 
            % while run.status in ['queued', 'in_progress', 'cancelling']
            while true
                return_obj = llms.internal.Assistant_get(this.api_key, "https://api.openai.com/v1/threads/" + this.thread_id + "/runs/" + run_id );
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
            message_obj=llms.internal.Assistant_get(this.api_key, "https://api.openai.com/v1/threads/" + this.thread_id + "/messages");
        end

        function deal_message_and_print(~,message_obj)
            %deal with the message and print
            %   message_obj: the message object
            %   print the message
            for i = 1:length(message_obj.Body.Data.data)
                % 依次输出message_obj.Body.Data.data[i].content.text.value
                disp(message_obj.Body.Data.data(i).content.text.value);
            end
        end
        
        % file modify, upload, delete. April 6,2024 by yjianzhu
        function file_list = get_files(this)
            % Get the files in the storage
            % curl https://api.openai.com/v1/files \
            % -H "Authorization: Bearer $OPENAI_API_KEY"
            % get
            file_list = llms.internal.openai_get(this.api_key, "https://api.openai.com/v1/files");
        end

        function delete_file(this, file_id)
            % Delete a file in the storage
            llms.internal.openai_delete(this.api_key, "https://api.openai.com/v1/files/" + file_id);
            % this.map_filename_fileid.remove(file_id);
            % this.update_map();
        end

        function delete_all_files(this)
            % Delete all files in the storage
            file_list = this.get_files();
            for i = 1:length(file_list.Body.Data.data)
                this.delete_file(file_list.Body.Data.data(i).id);
            end
        end
        
        function file_id = upload_file(this, file_path)
            % Upload a file to openai storage.
            % curl https://api.openai.com/v1/files \
            % -H "Authorization: Bearer $OPENAI_API_KEY" \
            % -F purpose="assistants" \
            % -F file="@mydata.jsonl"
            return_obj = llms.internal.openai_upload_file(this.api_key, "https://api.openai.com/v1/files", file_path);
            file_id = return_obj.Body.Data.id;
            % this.map_filename_fileid(file_id) = file_path;
            % this.update_map();
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

        function return_obj = get_vector_stores(this)
            % get all the vector stores in the storage
            % curl https://api.openai.com/v1/vector_stores \
            % -H "Authorization: Bearer $OPENAI_API_KEY" \
            % -H "Content-Type: application/json" \
            % -H "OpenAI-Beta: assistants=v2"
            % get
            return_obj = llms.internal.Assistant_get(this.api_key, "https://api.openai.com/v1/vector_stores");
        end

        function delete_status =delete_vector_store(this, vector_store_id)
            % delete a vector store in the storage
            % curl https://api.openai.com/v1/vector_stores/vs_abc123 \
            % -H "Authorization: Bearer $OPENAI_API_KEY" \
            % -H "Content-Type: application/json" \
            % -H "OpenAI-Beta: assistants=v2" \
            % -X DELETE         
            delete_status = llms.internal.Assistant_delete(this.api_key, "https://api.openai.com/v1/vector_stores/" + vector_store_id);
        end

        function delete_all_vector_stores(this)
            % delete all the vector stores in the storage
            vector_store_list = this.get_vector_stores();
            for i = 1:length(vector_store_list.Body.Data.data)
                this.delete_vector_store(vector_store_list.Body.Data.data(i).id);
            end
        end

        function file_id = add_file_to_assis(this,file_path)
            % add file to storage, add file_id to vector store
            % vector store id is vs_KPdPyPl6QMv6o4hxMt4tZacK
            file_id = this.upload_file(file_path);
            % curl https://api.openai.com/v1/vector_stores/vs_abc123/files \
            % -H "Authorization: Bearer $OPENAI_API_KEY" \
            % -H "Content-Type: application/json" \
            % -H "OpenAI-Beta: assistants=v2" \
            % -d '{
            % "file_id": "file-abc123"
            % }'
            % Post
            llms.internal.Assistant_post(this.api_key, "https://api.openai.com/v1/vector_stores/vs_KPdPyPl6QMv6o4hxMt4tZacK/files", {"file_id", file_id});
        end

        function file_list = list_file_of_assis(this)
            % curl https://api.openai.com/v1/vector_stores/vs_abc123/files \
            % -H "Authorization: Bearer $OPENAI_API_KEY" \
            % -H "Content-Type: application/json" \
            % -H "OpenAI-Beta: assistants=v2"
            % get
            file_list = llms.internal.Assistant_get(this.api_key, "https://api.openai.com/v1/vector_stores/vs_KPdPyPl6QMv6o4hxMt4tZacK/files");

            % print all the file name
            % for i = 1:length(file_list.Body.Data.data)
            %     disp(this.map_filename_fileid(file_list.Body.Data.data(i).id));
            % end
        end

        function delete_file_from_assis(this, file_id)
            % curl https://api.openai.com/v1/vector_stores/vs_abc123/files/file-abc123 \
            % -H "Authorization: Bearer $OPENAI_API_KEY" \
            % -H "Content-Type: application/json" \
            % -H "OpenAI-Beta: assistants=v2" \
            % -X DELETE
            llms.internal.Assistant_delete(this.api_key, "https://api.openai.com/v1/vector_stores/vs_KPdPyPl6QMv6o4hxMt4tZacK/files/" + file_id);
            this.delete_file(file_id);
        end

        % TODO check the vector store readiness before creating runs

        function delete_file_by_name_from_assis(this, file_name)
            file_list = this.list_file_of_assis();
            for i = 1:length(file_list.Body.Data.data)
                if isKey(this.map_filename_fileid,file_list.Body.Data.data(i).id) && this.map_filename_fileid(file_list.Body.Data.data(i).id) == file_name
                    disp("delete file: " + file_name);
                    this.delete_file_from_assis(file_list.Body.Data.data(i).id);
                end
            end
        end

        function delete_all_files_from_assis(this)
            file_list = this.list_file_of_assis();
            for i = 1:length(file_list.Body.Data.data)
                this.delete_file_from_assis(file_list.Body.Data.data(i).id);
            end
        end


        function file_id = add_file_to_code_interpreter(this, file_path)
            file_id = this.upload_file(file_path);
            llms.internal.Assistant_post(this.api_key, this.api_url + "/files", {"file_id", file_id});
        end

        function delete_file_from_code_interpreter(this, file_id)
            llms.internal.Assistant_delete(this.api_key, this.api_url + "/files/" + file_id);
            this.delete_file(file_id);
        end

        function file_list = list_file_of_code_interpreter(this)
            % curl https://api.openai.com/v1/assistants/asst_abc123/files \
            % -H "Authorization: Bearer $OPENAI_API_KEY" \
            % -H "Content-Type: application/json" \
            % -H "OpenAI-Beta: assistants=v1"
            % get
            file_list = llms.internal.Assistant_get(this.api_key, this.api_url + "/files");
            % print all the file name
            % for i = 1:length(file_list.Body.Data.data)
            %     disp(this.map_filename_fileid(file_list.Body.Data.data(i).id));
            % end
        end

        function delete_file_by_name_from_code_interpreter(this,file_path)
            file_list = this.list_file_of_code_interpreter();
            for i = 1:length(file_list.Body.Data.data)
                if isKey(this.map_filename_fileid,file_list.Body.Data.data(i).id) && this.map_filename_fileid(file_list.Body.Data.data(i).id) == file_path
                    disp("delete file: " + file_path);
                    this.delete_file_from_code_interpreter(file_list.Body.Data.data(i).id);
                end
            end
        end

        function delete_all_files_from_code_interpreter(this)
            file_list = this.list_file_of_code_interpreter();
            for i = 1:length(file_list.Body.Data.data)
                this.delete_file_from_code_interpreter(file_list.Body.Data.data(i).id);
            end
        end

        function file_id = add_file(this,file_path)
            file_id = this.upload_file(file_path);
            llms.internal.Assistant_post(this.api_key, this.api_url + "/files", {"file_id", file_id});
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
