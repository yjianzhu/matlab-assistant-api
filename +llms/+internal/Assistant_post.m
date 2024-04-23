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
    
    % TODO, check if data is a cell array,and get the size of the cell array
    % check the length is even or odd
    if mod(length(data),2) ~= 0
        error("data should be a cell array with even number of elements");
    end

    % Define the request message body
    structData = {};
    for i = 1:2:length(data)
        structData.(data{i}) = data{i+1};
    end
    body = matlab.net.http.MessageBody(structData);
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