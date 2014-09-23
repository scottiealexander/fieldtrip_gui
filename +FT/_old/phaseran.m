function s = phaseran(x,c)
%Syntax: s = phaseran(x,c)
%_______________________
%
% Makes c phase randomized surrogates of a time series x.
%
% s is the phase randomized time series.
% x is the original time series.
% c is the number of surrogates.
%
%
% References:
%
% Theiler J, Galdrikian B, Longtin A, Eubank S, Farmer D J (1992): Using 
% Surrogate Data to Detect Nonlinearity in Time Series. In Nonlinear Modeling
% and Forecasting, eds. Casdagli M & Eubank S. 163-188. Addison-Wesley
%
% Theiler J, Eubank S,Galdrikian B, Longtin A,  Farmer D J (1992): Testing
% for nonlinearity in time series: the method of surrogate data. Physica D
% 58: 77-94
%
% Original Author:
% Alexandros Leontitsis
% Department of Education
% University of Ioannina
% 45110 - Dourouti
% Ioannina
% Greece
%
% University e-mail: me00743@cc.uoi.gr
% Lifetime e-mail: leoaleq@yahoo.com
% Homepage: http://www.geocities.com/CapeCanaveral/Lab/1421
%
% 12 Apr 2002
%
% Updated: 2014-01-13
% Scottie Alexander

% x must be a vector
if min(size(x)) > 1 || numel(size(x)) > 2
  error('Input must be a vector');
end

%format as column vector
if size(x,1) < size(x,2)
    re_shape = true;
    x = reshape(x,[],1);
else
    re_shape = false;
end

% N is the time series length
N = length(x);

if nargin < 2 || isempty(c)
   c = 1;
else
   % c must be scalar
   if sum(size(c))>2
      error('c must be scalar.');
   end
   % c must be greater or equal than 1
   if c < 1
      error('c must be greater or equal than 1.');
   end
end


% FFT on x
y = fft(x);
% Magnitudes
m = abs(y);
% Angles
p = angle(y);
% The imaginary unit
i = sqrt(-1);
% Half of the data points
h = floor(N/2);

s = nan(N,c);

for j=1:c
   % Randomized phases
   if rem(N,2)==0
      p1=rand(h-1,1)*2*pi;
      p(2:N)=[p1' p(h+1) -flipud(p1)'];
      % Adjust the magnitudes
      m=[m(1:h+1);flipud(m(2:h))];
   else
      p1=rand(h,1)*2*pi;
      p(2:N)=[p1 -flipud(p1)];
   end
   % Back to the complex numbers
   s(:,j)=m.*exp(i*p);
   % Back to the time series (phase randomized surrogates)
   s(:,j)=real(ifft(s(:,j)));
end

%return the format that we recieved
if re_shape
    s = transpose(s);
end

