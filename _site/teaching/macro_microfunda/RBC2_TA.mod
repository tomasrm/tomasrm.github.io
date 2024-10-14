// RBC Model 2 - Two Agents
// This file was modified by Tomás Martinez for teaching purposes.
// Original file comes from José L. Torres (U Malága). 
// I cannot guarantee that it is error-free.


// Endogenous variables of the model
var Y, C, C1, C2, I, I1, K, K1, L, L1, L2, W, R, A;

// Exogenous shock
varexo ea ;

// Parameters of the model
parameters alpha, beta, delta, gamma, omega, rho;

// Calibration of parameters
alpha = 0.35;
beta = 0.97;
delta = 0.06;
gamma = 0.40;
omega = 0.50;  // share of "Ricardian Agents"
rho = 0.95;

// Model equations:
model;
C1=(gamma/(1-gamma))*(1-L1)*W;
C2=(gamma/(1-gamma))*(1-L2)*W;
C2=W*L2;
C =omega*C1+(1-omega)*C2;
1 = beta*((C1/C1(+1))*(R(+1)+(1-delta)));
K = omega*K1;
L = omega*L1+(1-omega)*L2;
Y = A*(K(-1)^alpha)*(L^(1-alpha));
K1= I1+(1-delta)*K1(-1);
I1= W*L1+R*K1-C1;
I = omega*I1;
W = (1-alpha)*A*(K(-1)^alpha)*(L^(-alpha));
R = alpha*A*(K(-1)^(alpha-1))*(L^(1-alpha));
log(A) = rho*log(A(-1))+ ea;
end;

// Initial values
initval;
Y = 1;
C = 0.8;
C1= 0.6;
C2= 0.2;
L = 0.3;
L1= 0.3;
L2= 0.3;
K = 3.5;
K1= 4;
I = 0.2;
I1= 0.3;
W = (1-alpha)*Y/L;
R = alpha*Y/K;
A = 1;
ea = 0;
end;


steady;
check;
model_diagnostics; 
model_info;

shocks;
var ea;
stderr 0.01; // 1% shock
end;

stoch_simul(order=1, irf=200);
