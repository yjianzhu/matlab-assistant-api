function [response, streamedText] = Assistant_get_message(api_key, endpoint, timeout, streamFun)
    %sendRequest Sends a request to an ENDPOINT using PARAMETERS and
    %   api key api_key. TIMEOUT is the nubmer of seconds to wait for initial
    %   server connection. STREAMFUN is an optional callback function.
    
    %   Copyright 2023 The MathWorks, Inc.
    
    arguments
        api_key
        endpoint
        timeout = 10
        streamFun = []
    end
    
    % Define the headers for the API request

    headers = [matlab.net.http.HeaderField('Content-Type', 'application/json')...
        matlab.net.http.HeaderField('Authorization', "Bearer " + api_key) ...
        matlab.net.http.HeaderField("OpenAI-Beta","assistants=v1")];
    
    % Define the request message, body             %   -d '{
            %       "role": "user",
            %       "content": message
            %     }'

    request = matlab.net.http.RequestMessage('get', headers);
    
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