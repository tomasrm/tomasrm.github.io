"""
DISCLAIMER
----------
This file is a translation of the original Julia/Pluto notebook `shooting.jl`
into Python. The translation was produced by AI (Claude). While the logic and
equations have been preserved as faithfully as possible, users should verify
results against the original Julia code before relying on this version for
research or teaching purposes.
----------

Fiscal Policy using the Shooting Algorithm
===========================================

The goal is to solve for the equilibrium sequence {k_{t+1}, c_t} given a
fiscal policy path {G_t, tau^c_t, tau^k_t} and an initial condition k_0.

The equilibrium equations are:
  k_{t+1} = k_t^alpha + (1-delta)*k_t - c_t - G_t          (resource constraint)
  u'(c_t) = [(1+tau^c_t)/(1+tau^c_{t+1})] * beta
            * [1 + (alpha*k_{t+1}^{alpha-1} - delta)*(1-tau^k_{t+1})] * u'(c_{t+1})
                                                              (Euler equation)

Functional forms: F(k,1) = k^alpha,  u(c) = c^{1-gamma} / (1-gamma).

The shooting algorithm:
  1. Solve for the terminal steady state k_ss.
  2. Guess an initial consumption c_0.
  3. Simulate the full path using the resource constraint and Euler equation.
  4. Adjust c_0 via bisection until k_T ≈ k_ss.
"""

import numpy as np
import matplotlib.pyplot as plt


# =============================================================================
# Baseline model (no fiscal policy)
# =============================================================================

def solve_neoclassical_growth():
    """Solve the neoclassical growth model without fiscal policy."""

    # Model parameters
    alpha = 0.33
    beta  = 0.95
    delta = 0.2
    gamma = 2.0
    T     = 50
    k0    = 0.1

    # Steady state
    k_ss = (alpha / (1/beta - (1 - delta))) ** (1 / (1 - alpha))
    c_ss = k_ss**alpha - delta * k_ss

    # Algorithm parameters
    max_iter = 10_000
    tol      = 1e-3

    def shoot(c0, k0):
        """Simulate model given initial consumption guess c0 and state k0."""
        k = np.zeros(T)
        c = np.zeros(T)
        c[0] = c0
        k[0] = k0
        for t in range(T - 1):
            k[t+1] = k[t]**alpha + (1 - delta)*k[t] - c[t]
            if k[t+1] < 0:
                k[t+1] = 1e-4
            c[t+1] = c[t] * ((1 + alpha * k[t+1]**(alpha - 1) - delta) * beta) ** (1 / gamma)
        return k, c

    # Initial bounds for bisection
    c_lower = c_ss / 30
    k, c = shoot(c_lower, k0)
    if (k[-1] - k_ss) / k_ss < 0:
        print("Warning: lower bound too high")

    c_upper = c_ss
    k, c = shoot(c_upper, k0)
    if (k[-1] - k_ss) / k_ss > 0:
        print("Warning: upper bound too low")

    c_guess = (c_lower + c_upper) / 2

    for it in range(max_iter):
        k, c = shoot(c_guess, k0)
        dist = (k[-1] - k_ss) / k_ss
        if abs(dist) < tol:
            print(f"Converged at iteration {it+1}, distance: {dist:.6f}")
            break
        if dist > 0:   # capital too high -> increase c0
            c_lower = c_guess
            c_guess = (c_guess + c_upper) / 2
        else:          # capital too low  -> decrease c0
            c_upper = c_guess
            c_guess = (c_guess + c_lower) / 2

    return k, c


# =============================================================================
# Model with fiscal policy
# =============================================================================

def solve_neoclassical_fiscal_pol(params, policy_seq):
    """
    Solve the neoclassical growth model with fiscal policy.

    Parameters
    ----------
    params : dict
        alpha, beta, delta, gamma, T
    policy_seq : dict
        tau_c_seq, tau_k_seq, g_seq  (each a numpy array of length T)

    Returns
    -------
    k, c : numpy arrays of length T
    """

    alpha = params['alpha']
    beta  = params['beta']
    delta = params['delta']
    gamma = params['gamma']
    T     = params['T']

    tau_c_seq = policy_seq['tau_c_seq']
    tau_k_seq = policy_seq['tau_k_seq']
    g_seq     = policy_seq['g_seq']

    # Initial steady state
    tau_k_0 = tau_k_seq[0]
    g_0     = g_seq[0]
    k_ss_0  = (alpha / ((1/beta - 1) / (1 - tau_k_0) + delta)) ** (1 / (1 - alpha))
    c_ss_0  = k_ss_0**alpha - delta * k_ss_0 - g_0

    # Final steady state
    tau_k_T = tau_k_seq[-1]
    k_ss_T  = (alpha / ((1/beta - 1) / (1 - tau_k_T) + delta)) ** (1 / (1 - alpha))

    # Algorithm parameters
    max_iter = 10_000
    tol      = 1e-3

    def shoot(c0, k0):
        k = np.zeros(T)
        c = np.zeros(T)
        c[0] = c0
        k[0] = k0
        for t in range(T - 1):
            k[t+1] = k[t]**alpha + (1 - delta)*k[t] - c[t] - g_seq[t]
            if k[t+1] < 0:
                k[t+1] = 1e-4
            c[t+1] = c[t] * (
                (1 + tau_c_seq[t]) / (1 + tau_c_seq[t+1])
                * (1 + (alpha * k[t+1]**(alpha - 1) - delta) * (1 - tau_k_seq[t+1]))
                * beta
            ) ** (1 / gamma)
        return k, c

    # Initial bounds for bisection
    c_lower = c_ss_0 / 10
    k, c = shoot(c_lower, k_ss_0)
    if (k[-1] - k_ss_T) / k_ss_T < 0:
        print("Warning: lower bound too high")

    c_upper = c_ss_0 * 10
    k, c = shoot(c_upper, k_ss_0)
    if (k[-1] - k_ss_T) / k_ss_T > 0:
        print("Warning: upper bound too low")

    c_guess = (c_lower + c_upper) / 2

    for it in range(max_iter):
        k, c = shoot(c_guess, k_ss_0)
        dist = (k[-1] - k_ss_T) / k_ss_T
        if abs(dist) < tol:
            print(f"Converged at iteration {it+1}, distance: {dist:.6f}")
            break
        if dist > 0:
            c_lower = c_guess
            c_guess = (c_guess + c_upper) / 2
        else:
            c_upper = c_guess
            c_guess = (c_guess + c_lower) / 2

    return k, c


# =============================================================================
# Helper: recover aggregate variables from k and c sequences
# =============================================================================

def recover_aggregates(k, params):
    T     = params['T']
    alpha = params['alpha']
    delta = params['delta']

    r = np.zeros(T)
    w = np.zeros(T)
    i = np.zeros(T)
    y = np.zeros(T)

    for t in range(T):
        r[t] = alpha * k[t]**(alpha - 1) - delta
        w[t] = (1 - alpha) * k[t]**alpha
        y[t] = k[t]**alpha
        if t < T - 1:
            i[t] = k[t+1] - (1 - delta) * k[t]
    i[-1] = delta * k[-1]  # last period: economy at steady state

    return r, w, i, y


# =============================================================================
# Plotting helper
# =============================================================================

def plot_fiscal_experiment(title, gT, k, c, r, i, y, policy_var, policy_label):
    fig, axes = plt.subplots(2, 3, figsize=(12, 7))
    fig.suptitle(title, fontsize=14)

    axes[0, 0].plot(gT, policy_var, lw=2)
    axes[0, 0].set_title(policy_label)
    axes[0, 0].set_xlabel("t")

    axes[0, 1].plot(gT, k, lw=2)
    axes[0, 1].set_title("Capital")
    axes[0, 1].set_xlabel("t")

    axes[0, 2].plot(gT, c, lw=2)
    axes[0, 2].set_title("Consumption")
    axes[0, 2].set_xlabel("t")

    axes[1, 0].plot(gT, y, lw=2)
    axes[1, 0].set_title("Output")
    axes[1, 0].set_xlabel("t")

    axes[1, 1].plot(gT, i, lw=2)
    axes[1, 1].set_title("Investment")
    axes[1, 1].set_xlabel("t")

    axes[1, 2].plot(gT, r, lw=2)
    axes[1, 2].set_title("Interest Rate")
    axes[1, 2].set_xlabel("t")

    plt.tight_layout()
    plt.show()


# =============================================================================
# Fiscal Policy Experiments
# =============================================================================

def permanent_gov_increase():
    """Permanent increase in government spending starting at period 10."""
    T      = 50
    params = dict(alpha=0.33, beta=0.95, delta=0.2, gamma=2.0, T=T)

    tau_c_seq = np.zeros(T)
    tau_k_seq = np.zeros(T)
    g_seq     = np.full(T, 0.2)
    g_seq[9:] = 0.4  # Permanent shock starting at period 10 (0-indexed: period 9)

    policy_seq = dict(tau_c_seq=tau_c_seq, tau_k_seq=tau_k_seq, g_seq=g_seq)
    k, c = solve_neoclassical_fiscal_pol(params, policy_seq)
    r, w, i, y = recover_aggregates(k, params)

    gT = np.arange(T)
    plot_fiscal_experiment("Permanent Gov. Increase", gT, k, c, r, i, y, g_seq, "Gov. Spending")


def permanent_tax_cons_increase():
    """Permanent increase in consumption tax starting at period 10."""
    T      = 50
    params = dict(alpha=0.33, beta=0.95, delta=0.2, gamma=2.0, T=T)

    tau_c_seq     = np.zeros(T)
    tau_k_seq     = np.zeros(T)
    g_seq         = np.full(T, 0.2)
    tau_c_seq[9:] = 0.2  # Permanent shock starting at period 10

    policy_seq = dict(tau_c_seq=tau_c_seq, tau_k_seq=tau_k_seq, g_seq=g_seq)
    k, c = solve_neoclassical_fiscal_pol(params, policy_seq)
    r, w, i, y = recover_aggregates(k, params)

    gT = np.arange(T)
    plot_fiscal_experiment("Permanent Consumption Tax Increase", gT, k, c, r, i, y, tau_c_seq, "Consum. Tax")


def permanent_tax_capital_increase():
    """Permanent increase in capital tax starting at period 10."""
    T      = 50
    params = dict(alpha=0.33, beta=0.95, delta=0.2, gamma=2.0, T=T)

    tau_c_seq     = np.zeros(T)
    tau_k_seq     = np.zeros(T)
    g_seq         = np.full(T, 0.2)
    tau_k_seq[9:] = 0.2  # Permanent shock starting at period 10

    policy_seq = dict(tau_c_seq=tau_c_seq, tau_k_seq=tau_k_seq, g_seq=g_seq)
    k, c = solve_neoclassical_fiscal_pol(params, policy_seq)
    r, w, i, y = recover_aggregates(k, params)

    gT = np.arange(T)
    plot_fiscal_experiment("Permanent Capital Tax Increase", gT, k, c, r, i, y, tau_k_seq, "Capital Tax")


def transitory_gov_increase():
    """Transitory (one-period) increase in government spending at period 10."""
    T      = 50
    params = dict(alpha=0.33, beta=0.95, delta=0.2, gamma=2.0, T=T)

    tau_c_seq = np.zeros(T)
    tau_k_seq = np.zeros(T)
    g_seq     = np.full(T, 0.2)
    g_seq[9]  = 0.4  # Transitory shock at period 10

    policy_seq = dict(tau_c_seq=tau_c_seq, tau_k_seq=tau_k_seq, g_seq=g_seq)
    k, c = solve_neoclassical_fiscal_pol(params, policy_seq)
    r, w, i, y = recover_aggregates(k, params)

    gT = np.arange(T)
    plot_fiscal_experiment("Transitory Gov. Increase", gT, k, c, r, i, y, g_seq, "Gov. Spending")


def transitory_capital_subsidy():
    """Transitory capital subsidy (negative tax) from period 10 to 20."""
    T      = 50
    params = dict(alpha=0.33, beta=0.95, delta=0.2, gamma=2.0, T=T)

    tau_c_seq       = np.zeros(T)
    tau_k_seq       = np.zeros(T)
    g_seq           = np.full(T, 0.2)
    tau_k_seq[9:20] = -0.1  # Subsidy for 10 periods

    policy_seq = dict(tau_c_seq=tau_c_seq, tau_k_seq=tau_k_seq, g_seq=g_seq)
    k, c = solve_neoclassical_fiscal_pol(params, policy_seq)
    r, w, i, y = recover_aggregates(k, params)

    gT = np.arange(T)
    plot_fiscal_experiment("Transitory Capital Subsidy", gT, k, c, r, i, y, tau_k_seq, "Capital Subsidy")


# =============================================================================
# Run all experiments
# =============================================================================

if __name__ == "__main__":

    print("=== Baseline: Neoclassical Growth (no fiscal policy) ===")
    k, c = solve_neoclassical_growth()
    T  = len(k)
    gT = np.arange(T)
    fig, axes = plt.subplots(1, 2, figsize=(10, 4))
    axes[0].plot(gT, k, lw=2); axes[0].set_title("Capital"); axes[0].set_xlabel("t")
    axes[1].plot(gT, c, lw=2); axes[1].set_title("Consumption"); axes[1].set_xlabel("t")
    plt.suptitle("Neoclassical Growth Model")
    plt.tight_layout(); plt.show()

    print("\n=== Experiment 1: Permanent Government Spending Increase ===")
    permanent_gov_increase()

    print("\n=== Experiment 2: Permanent Consumption Tax Increase ===")
    permanent_tax_cons_increase()

    print("\n=== Experiment 3: Permanent Capital Tax Increase ===")
    permanent_tax_capital_increase()

    print("\n=== Experiment 4: Transitory Government Spending Increase ===")
    transitory_gov_increase()

    print("\n=== Experiment 5: Transitory Capital Subsidy ===")
    transitory_capital_subsidy()
