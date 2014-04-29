function s = phaseran2(x)
% phaseran2
%
% Description: randomly phase scramble a matrix of time series where each row
%			   is a time series and each column is a data point
%
% Syntax: s = phaseran2(x)
%
% In:
%		x - a nVariable x nTimepoint matrix (e.g. channels x time)
%
% Out:
%		s - a phase scambled version of x
%
% References:
% 		Theiler J, Galdrikian B, Longtin A, Eubank S, Farmer D J (1992): Using 
% 		Surrogate Data to Detect Nonlinearity in Time Series. In Nonlinear Modeling
% 		and Forecasting, eds. Casdagli M & Eubank S. 163-188. Addison-Wesley
%
% 		Theiler J, Eubank S,Galdrikian B, Longtin A,  Farmer D J (1992): Testing
% 		for nonlinearity in time series: the method of surrogate data. Physica D
% 		58: 77-94
%
% Original Author:
% 		Alexandros Leontitsis
% 		Department of Education
% 		University of Ioannina
% 		45110 - Dourouti
% 		Ioannina
% 		Greece
%
% 		University e-mail: me00743@cc.uoi.gr
% 		Lifetime e-mail: leoaleq@yahoo.com
% 		Homepage: http://www.geocities.com/CapeCanaveral/Lab/1421
%
%		12 Apr 2002
%
% Updated: 2014-04-29
% Scottie Alexander

%reshape so that each column is a variable (for fft etc..)
x = transpose(x);

% N is the time series length
N = size(x,1);
k = size(x,2);

% FFT on x
y = fft(x);
% magnitudes
m = abs(y);
% angles
p = angle(y);
% the imaginary unit
i = sqrt(-1);
% half of the data points
h = floor(N/2);

% randomize phases
if rem(N,2) == 0
	p1 = rand(h-1,k)*2*pi;
    p(2:N,:) = [p1; p(h+1,:); -flipud(p1)];
	% adjust the magnitudes
	m = [m(1:h+1,:);flipud(m(2:h,:))];
else
	p1 = rand(h,k)*2*pi;
	p(2:N,:) = [p1;-flipud(p1)];
end

% Back to the complex numbers
s = m.*exp(i*p);

% Back to the time series (phase randomized surrogates)	
s = real(ifft(s));

%reshape for our user
s = transpose(s);