// RBC Model 3 - Capital Utilization
// This file was modified by Tomás Martinez for teaching purposes.
// Original file comes from Gauthiel Vermandel. 
// I cannot guarantee that it is error-free.



// Endogenous variables of the model
var y c k ku u i h w r z a g; 

// Exogenous shock
varexo e_a e_g;

// Parameters of the model
parameters	beta alpha delta sigmaC sigmaL gy
			rho_a rho_g
			R Y C Z I Z2 K  // steady state variables
			;

// Calibration of parameters
beta 	= 0.99; %Discount Factor
delta 	= 0.025;	%Depreciation rate
alpha 	= 0.36;	%Capital share
gy 		= 0.2;    %Public spending in GDP
sigmaC 	= 1;
sigmaL 	= 2; %Elasticity of labor
Z2		= 0.5;						% capital utilization, quadratic term
rho_a	= 0.95;     % autoregressive roots parameters
rho_g	= 0.95;

%% Steady States Variables (treat as parameters)
R		= 1/beta;
H		= 1/3;
Q		= 1;
Z		= (R*Q-(1-delta)*Q); 			% capital utilization, linear term
K		= H*(Z/alpha)^(1/(alpha-1));
Y		= K^alpha*H^(1-alpha);
I		= delta*K;
W		= (1-alpha)*Y/H;
C		= (1-gy)*Y-I;
chi		= W/((H^(1/sigmaL))*(C^sigmaC));



// Calibration of parameters
alpha = 0.35;
beta = 0.97;
delta = 0.06;
gamma = 0.40;
omega = 0.50;  // share of "Ricardian Agents"
rho = 0.95;

// Model equations (based on Christiano Eichenbaum Evans 2005)
model(linear);
	sigmaC*(c(+1)-c)=r;  	% Euler
	w = (1/sigmaL)*h + sigmaC*c; 	% labor supply

	R*r = Z*z(+1); 	% No arbitrage Bonds-Capital
	delta*i = k-(1-delta)*k(-1); 	% Capital law of motion
	z = Z2*u; 	% utilization cost
	ku = u + k(-1); 	% utilized capital

    % Intermediary firms
	% Production function
	y = a + alpha*ku + (1-alpha)*h;
	% Inputs Cost minimization
	z = y - ku;
	w + h = z + ku;
    % Resources constraint
	Y*y = C*c + I*i + gy*Y*g + Z*K*u;
    % Exogenous shocks
	a = rho_a*a(-1) + e_a;
	g = rho_g*g(-1) + e_g;
end;



steady;
check;
model_diagnostics; 
model_info;
shocks;

var e_a;  stderr .01;
var e_g;  stderr .01;
end;


stoch_simul(order = 1,irf=30) y c k i w h r;