% matced32.m
% routines to control the 1401+ from MAtlab 6.x
% original (16 bit) version by Mario Ringach
% modified for 32 bit by JG Colebatch
% version 2: stop some text output, allow command directory to be
%                   specified
% version 3: new calls, supports PERI32
% version 4: call U14WorkingSet
%
%   usage:
%          ans=matced32('cmd',[opt1],[opt2],[opt3]);
%
%   where cmd = cedOpen - opens the 1401 or returns error code
%             = cedGetUserMemorySize - ans = installed memory
%             = cedGetTimeOut - ans = timeout duration
%             = cedSetTimeOut - opt1 = timeout duration
%             = cedStat1401 - ans = status
%             = cedLd     -'opt1' = command name to load
%             = cedToHost - opt1 = length (16 bit) to transfer
%                         - opt2 = address to begin with
%                         - ans = array of results
%             = cedTo1401 - opt1 = length (16 bit) to transfer
%                         - opt2 = start address in 1401
%                         - opt3 = array to be transferred
%             = cedSendString - opt1 = string to send
%             = cedGetString  - ans = string from the 1401
%             = cedReset - resets the 1401
%             = cedClose - closes the 1401
%  added with ver 2:  
%             = cedOpenX - returns (default)1401 handle or error code
%             = cedCloseX - returns value from U14Close1401
%             = cedLdX      - opt1 - directory of 1401 commands
%                           - opt2,opt3 etc - command names to load
%  version 3, added:
%             = cedOpenX - opt1 = no of 1401 (default=0)
%             = cedLongsFrom1401 - ans = array of longs
%                           - opt1 = no. of longs (us 2)
%             = cedTransferFlags - ans = value returned
%             = cedSetTransfer - opt1 = transfer area (us 0)\
%                              - opt2 = size in bytes
%             = cedUnsetTransfer - opt1 = area
%             = cedGetTransData ans = array of data
%                                - opt1 = wArea (us 0)
%                                - opt2 = number of data points
%                                - opt3 = data type 0,1 = byte, 2 = short
%            = cedTypeOf1401 ans = returned value
% version 4, added:
%            = cedWorkingSet - this is to avoid -544 errors
%              if so, try calling 'cedWorkingSet',400,4000
%               if ret > 0 there is an error, typically due to privilege
%            existing calls now declare details of error codes (if any)
%         4.2: cedToHost, cedTo1401 capacity increased