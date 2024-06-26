function [response, streamedText] = Assistant_post(api_key, endpoint, data, timeout, streamFun)
    %sendRequest Sends a request to an ENDPOINT using PARAMETERS and
    %   api key api_key. TIMEOUT is the nubmer of seconds to wait for initial
    %   server connection. STREAMFUN is an optional callback function.
    
    %   Copyright 2023 The MathWorks, Inc.
    
    arguments
        api_key
        endpoint
        data 
        timeout = 10
        streamFun = []
    end
    
    % Define the headers for the API request

    headers = [matlab.net.http.HeaderField('Content-Type', 'application/json')...
        matlab.net.http.HeaderField('Authorization', "Bearer " + api_key) ...
        matlab.net.http.HeaderField("OpenAI-Beta","assistants=v2")];
    
    % TODO, check if data is a cell array
    if iscell(data)
        % data 是2维cell数组，第一列是key，第二列是value
        struct_data = {};
        for i = 1:size(data,1)
            struct_data.(data{i,1}) = data{i,2};
        end
        body = matlab.net.http.MessageBody(struct_data);
    else
        % data 是字符串
        disp("data is not a cell array");
    end

    % Define the request message
    request = matlab.net.http.RequestMessage('post', headers, body);
    
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