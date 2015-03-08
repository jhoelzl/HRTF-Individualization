function [datapoint,status] = nextpoint(reset)
% [datapoint,status] = nextpoint(reset)
%
% NEXTPOINT - skeleton function
%
% this function returns the next datapoint for online methods.
%
% nextpoint(1) should return the dimensionality of the data
%              and reset to the beginning of the dataset
%
% nextpoint(0) should return the next datapoint and a status flag
%              status=1 if we still have more data
%              status=0 if we are out of data
%


global dat;
global thisn;
[p,N] = size(dat);

if(reset)
  % go back to beginning of dataset and return dimensionality
  datapoint = p; status=p;
  thisn=1;
elseif(thisn<=N)
  % return next datapoint and status=1 or status=0 if at end
  datapoint=dat(:,thisn);
  thisn=thisn+1;
  if(thisn>N) status=0; else status=1; end
else
  datapoint = NaN;
  status = 0;
end