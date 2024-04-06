function [response, streamedText] = Assistant_modify(api_key, endpoint, file_id, instructions)
    %sendRequest Sends a request to an ENDPOINT using PARAMETERS and
    %   api key api_key. TIMEOUT is the nubmer of seconds to wait for initial
    %   server connection. STREAMFUN is an optional callback function.
    
    %   Copyright 2023 The MathWorks, Inc.
    
    arguments
        api_key
        endpoint
        file_id
        instructions = ""
    end
    
    % Define the headers for the API request

    headers = [matlab.net.http.HeaderField('Content-Type', 'application/json')...
        matlab.net.http.HeaderField('Authorization', "Bearer " + api_key) ...
        matlab.net.http.HeaderField("OpenAI-Beta","assistants=v1")];
    
    % Define the body of the request
                % -d '{
            %     "instructions": "You are an HR bot, and you have access to files to answer employee questions about company policies. Always response with info from either of the files.",
            %     "tools": [{"type": "retrieval"}],
            %     "model": "gpt-4",
            %     "file_ids": ["file-abc123", "file-abc456"]
            %   }'
    body = matlab.net.http.MessageBody(struct(...
        'instructions', instructions, ...
        'file_ids', file_id));

    % Define the request message
    request = matlab.net.http.RequestMessage('POST', headers, body);
    
    % Create a HTTPOptions object;
    httpOpts = matlab.net.http.HTTPOptions;
    
    % Set the ConnectTimeout option
    httpOpts.ConnectTimeout = timeout;
    
    % Send the request and store the response
    if isempty(streamFun)
        response = send(request, matlab.net.URI(endpoint),httpOpts);
        streamedText = "";
    else
        % User defined a stream callback function
        consumer = llms.stream.responseStreamer(streamFun);
        response = send(request, matlab.net.URI(endpoint),httpOpts,consumer);
        streamedText = consumer.ResponseText;
    end
    end