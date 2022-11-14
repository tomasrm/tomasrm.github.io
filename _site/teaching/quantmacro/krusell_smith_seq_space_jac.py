import numpy as np
import copy
import matplotlib.pyplot as plt

from sequence_jacobian import interpolate, grids, misc, JacobianDict
from sequence_jacobian import simple, het, create_model, hetblocks
# Use Python 3.7 or above
# Some experiments using the ``sequence_jacobian''.
# Based on the example given by Auclert et al (2021, ECTA) and their python notebooks. 
# by Tomás Martinez

# ===================================================== #
# Model Blocks
# ===================================================== #

# simple blocks: firm and equilibrium conditions
@simple
def firm(K, L, Z, alpha, delta):
    r = alpha * Z * (K(-1) / L) ** (alpha-1) - delta
    w = (1 - alpha) * Z * (K(-1) / L) ** alpha
    Y = Z * K(-1) ** alpha * L ** (1 - alpha)
    return r, w, Y

@simple
def mkt_clearing(K, A, Y, C, delta):
    asset_mkt = A - K
    I = K - (1 - delta) * K(-1)
    goods_mkt = Y - C - I
    return asset_mkt, goods_mkt, I


# heterogeneous part

# initial guess for the backward
def household_init(a_grid, e_grid, r, w, gamma): 
    coh = (1 + r) * a_grid[np.newaxis, :] + w * e_grid[:, np.newaxis] # income
    Va = (1 + r) * (0.1 * coh) ** (-gamma)
    return Va

# arguments: backward_fun, exogenous, policy, backward, backward_init=None, hetinputs=None, hetoutputs=None):
@het(exogenous='Pi', policy='a', backward='Va', backward_init=household_init)
def hh(Va_p, a_grid, y, r, beta, gamma):
    uc_nextgrid = beta * Va_p # Euler Equation (nextgrid is period t)
    c_nextgrid = uc_nextgrid ** (-1/gamma) # get consumption from period t
    coh = (1 + r) * a_grid[np.newaxis, :] + y[:, np.newaxis] # income on grid from time t from budget constraint
    a = interpolate.interpolate_y(c_nextgrid + a_grid, coh, a_grid) # get a off-grid from income off-grid
    misc.setmin(a, a_grid[0])  # enforce a_min
    c = coh - a   # get consumption off-grid
    Va = (1 + r) * c ** (-gamma)  # get next Va using envelop theorem
    return Va, a, c

# This two functions
def make_grid(rho_e, sd_e, nE, amin, amax, nA):
    e_grid, _, Pi = grids.markov_rouwenhorst(rho=rho_e, sigma=sd_e, N=nE)
    a_grid = grids.agrid(amin=amin, amax=amax, n=nA)
    return e_grid, Pi, a_grid

def income(w, e_grid):
    y = w * e_grid
    return y


household = hh.add_hetinputs([income, make_grid])
print(household)
print(f'Inputs: {household.inputs}')
print(f'Macro outputs: {household.outputs}')
print(f'Micro outputs: {household.internals}')

ks_model = create_model([household, firm, mkt_clearing], name="Krusell-Smith")

 # P.S. think carefully which unknowns and which target you want to use
calibration = {'gamma': 1, 'delta': 0.025, 'alpha': 0.33, 'rho_e': 0.966, 'sd_e': 0.5, 'L': 1.0,
               'nE': 7, 'nA': 500, 'amin': 0, 'amax': 200, 'beta': 0.96,  'Z': 1.0}
#unknowns_ss = {'beta': 0.98, 'Z': 1.0, 'K': 3.}
unknowns_ss = {'K': (8.0, 16.0)}

targets_ss = {'asset_mkt': 0.}

ss = ks_model.solve_steady_state(calibration, unknowns_ss, targets_ss, solver='hybr')

# print steady state variable:
print(ss)
for i in ['alpha','Z', 'K','Y' ,'beta','r', 'w', 'asset_mkt','goods_mkt']:
    print(i, ": ", ss[i])

print(ss.internals['hh'].keys()) # policies, and distributions

# You can also call individual blocks in the SS
firm_calib = {**calibration, **{'K': 12.0}} # this merge two dictionary: must include K
ss_firm = firm.steady_state(firm_calib)
ss_firm['r']

# Check the methods
method_list = [method for method in dir(firm) if method.startswith('__') is False]
print(method_list)
# We can use help, but to undertand all methodds the best way to do it is to check "simple_block.py"
help(firm.steady_state)

method_list = [method for method in dir(hh) if method.startswith('__') is False]
print(method_list)

# Using the Jacobian to solve for the impulse response function: 

# Using Simple Blocks
help(firm.jacobian)
J_firm = firm.jacobian(ss, inputs=['K', 'Z'])

# The Jacobian of dimension (i, j) is dYi/dXj, where i-1 and j-1 is the time of the shock. 
# So the first entry is dY0/dX0, the response of Y0 to a shock in X0.
# Since Z only enter in the production function conteporaneously, and there are no leads or lags the jacobian is sparse.
print(J_firm['Y']['Z'].matrix(3))
print('\n')
print(J_firm['Y']['Z'])

J_mkt = mkt_clearing.jacobian(ss, inputs=['K'])
print(J_mkt['I']['K'].matrix(5)) # Also sparse, but with a Dyn. Component.

# for the heterogeneous jacobian, you must specify the time (since it goes back and fourth)
T=300
J_ha = household.jacobian(ss, inputs=['r', 'w'], T=T)
print(J_ha['C']['r'])
# here we can easily see the effect ot the news shock, the consumption response is the highest at the time of tje shock

print(J_ha['C']['r'] @ J_firm['r']['Z']) # the effect of Z on 

### We can then construct the jacobians of function H manually:
# (see the notebook of the official github)
J = copy.deepcopy(J_firm)
J_curlyK_K = J_ha['A']['r'] @ J_firm['r']['K'] + J_ha['A']['w'] @ J_firm['w']['K']
J_curlyK_Z = J_ha['A']['r'] @ J_firm['r']['Z'] + J_ha['A']['w'] @ J_firm['w']['Z']
J.update(JacobianDict({'curlyK': {'K' : J_curlyK_K, 'Z' : J_curlyK_Z}}))

H_K = J['curlyK']['K'] - np.eye(T)  # This is the equilibrium equation
H_Z = J['curlyK']['Z']              # This is the equilibrium equation

# and finally get the equilibrium response to a shock, the matrix G given by the implicit funcction theorem
G = {'K': -np.linalg.solve(H_K, H_Z)}

# The reponse to all other variables are just the composite of Jacobians
G['r'] = J['r']['Z'] + J['r']['K'] @ G['K'] # direct effect of Z + effect through K
G['w'] = J['w']['Z'] + J['w']['K'] @ G['K']
G['Y'] = J['Y']['Z'] + J['Y']['K'] @ G['K']
G['C'] = J_ha['C']['r'] @ G['r'] + J_ha['C']['w'] @ G['w']


# ======= Instead of solving individually, we can solve using the package
inputs = ['Z']
unknowns = ['K']
targets = ['asset_mkt']
help(ks_model.solve_jacobian)

G2 = ks_model.solve_jacobian(ss, unknowns, targets, inputs, T=T)

# Check
for o in G:
    assert np.allclose(G2[o]['Z'], G[o])

# if it is not close, it will throw an error

# ===== IRF:

rhos = np.array([0.2, 0.4, 0.6, 0.8, 0.9])
#rhos = np.array([ 0.9])
dZ = 0.01 * ss['Z'] * rhos  ** (np.arange(T)[:, np.newaxis]) # get T*5 matrix of dZ
dr = G['r'] @ dZ

plt.plot(10000*dr[:50, :])
plt.title(r'$r$ response to 1% $Z$ shocks with $\rho=(0.2 ... 0.9)$')
plt.ylabel(r'basis points deviation from ss')
plt.xlabel(r'quarters')
plt.show()


# We could also use the Jacobians to solve for the IRF nonlinear. 
# THe intuition is to use the Jacobian as a guess in a Newthon algorithm.
# We can also use to compute transition to a different SS
help(ks_model.solve_impulse_nonlinear)
Z_shock_path = {"Z": 0.01*0.8**np.arange(T)}
td_nonlin = ks_model.solve_impulse_nonlinear(ss, unknowns, targets, Z_shock_path)

# Compare with linear
td_lin = ks_model.solve_impulse_linear(ss, unknowns, targets, Z_shock_path)

print(td_nonlin)
td_nonlin['K'][-5:]
td_nonlin['r']

dr_nonlin = 10000 * td_nonlin['r']
dr_lin = 10000 * td_lin['r']

plt.plot(dr_nonlin[:50], label='nonlinear', linewidth=2.5)
plt.plot(dr_lin[:50], label='linear', linestyle='--', linewidth=2.5)
plt.title(r'Interest rate response to a 1% TFP shock')
plt.ylabel(r'bp deviation from ss')
plt.xlabel(r'quarters')
plt.legend()
plt.show()


# Go to a different Steady State (1% higher)
#Z2 = ss['Z']*1.05 
Z2=ss['Z']*1.01
calibration2 = {**calibration, **{'Z': Z2}} 
ssnew = ks_model.solve_steady_state(calibration2, unknowns_ss, targets_ss, solver='hybr')

print((ssnew['Z']-ss['Z'])/ss['Z'])
print((ssnew['K']-ss['K'])/ss['K'])

#Z_shock_path = {"Z": np.linspace(0.0, Z2, num = T)}
#Z_shock_path = {"Z":np.full(T, Z2 - ss['Z'] )}
Z_shock_path = {"Z":np.full(T, 0.0 )} # seems that the only way to get the correct IRF is using this. 
new_ss = ks_model.solve_impulse_nonlinear(ssnew, unknowns, targets, Z_shock_path, ss_initial=ss)
#new_ss = ks_model.solve_impulse_nonlinear(ss, unknowns, targets, Z_shock_path, ss_initial=ss)



#new_ss = ks_model.solve_impulse_nonlinear(ssnew, unknowns, targets, Z_shock_path, ss_initial=ssnew)
new_ss
new_ss.internals

#new_ss['asset_mkt']
plt.plot(new_ss['K'], label='K', linewidth=2.5)



#td_newss = nonlinear.td_solve(ssnew, block_list, unknowns, targets, ss_initial=ss, Z=np.full(500, ssnew['Z']), noisy=False)

ss['K']
ssnew['K']


# newss is the difference of the response of the shock to the terminal SS)
# calculate in %, we must add back the terminal steady state
scaled = 100 * (new_ss + ssnew - ss ) / ss  # scale all variables at once

plt.plot(scaled['K'], label='K', linewidth=2.5)
plt.plot(scaled['C'], label='C', linestyle='--', linewidth=2.5)
plt.plot(scaled['Y'], label='Y', linestyle='--', linewidth=2.5)

plt.title(r'Increase in 1% of Z')
plt.ylabel(r'% deviation from ss')
plt.xlabel(r'quarters')
plt.legend()
plt.show()


