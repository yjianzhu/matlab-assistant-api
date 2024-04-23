function [response, streamedText] = Assistant_delete(api_key, endpoint, timeout, streamFun)
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
        matlab.net.http.HeaderField("OpenAI-Beta","assistants=v2")];
    
    % Define the request message
    request = matlab.net.http.RequestMessage('DELETE', headers);
    
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