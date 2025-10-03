# Strategizing Against Q-Learners: A Control-Theoretical Approach

This repository contains MATLAB code accompanying the paper:

> **Y. Arslantaş, E. Yüceel, and M. O. Sayin**,  
> *Strategizing Against Q-Learners: A Control-Theoretical Approach*,  
> IEEE Control Systems Letters, vol. 8, pp. 1733–1738, 2024.  
> [DOI: 10.1109/LCSYS.2024.3416240](https://doi.org/10.1109/LCSYS.2024.3416240)

---

## 📖 Overview

Independent Q-learning (IQL) is a widely used multi-agent reinforcement learning algorithm. However, it can be vulnerable to **strategically sophisticated opponents** who know the learning dynamics.

This project provides a MATLAB implementation of the control-theoretical approach proposed in the paper, where:

- **Naive agents (Q-learners)** update their Q-values using softmax exploration.  
- **Strategic agents (DP-based)** treat the Q-learners’ dynamics as a controlled system and compute optimal strategies via **quantization-based dynamic programming**.  

The simulations include:

- **Q vs Q**: Two Q-learners playing against each other.  
- **Q vs DP**: A Q-learner against a dynamic-programming-based strategic agent.  
- Comparison of **empirical frequency profiles** and **discounted payoffs**.  

---

## 📂 Repository Structure

- `main.m` – Entry point for running simulations (selects game, sets parameters, runs experiments).  
- `getGame.m` – Utility for loading payoff matrices (e.g., Prisoner’s Dilemma).  
- `QvsQ.m` – Simulation of two Q-learners interacting.  
- `QvsDP.m` – Simulation of Q-learner vs. strategic agent.  
- `runDP.m` – Backward induction for computing DP-based optimal policy.  
- `chooseAction.m` – Helper function for sampling actions given a probability distribution.  
- `quantizer.m`, `inverse_quantizer.m` – State quantization utilities.  

---

## ⚙️ Usage

### 1. Clone the repository
```bash
git clone https://github.com/yukselarslantas/ewa-vs-dp.git
cd ewa-vs-dp
```
### 2. Run in MATLAB

### 3. Results

Plots will show:

- The evolution of empirical frequencies (**CC, CD, DC, DD**)  
- Comparison of **Q vs Q** and **Q vs DP** interactions  
- Computed **discounted payoffs**  

Results are automatically saved in `.mat` files depending on the selected game type.


## 📑 Reference
If you use this code, please cite:

```bibtex
@article{arslantas2024strategizing,
  title={Strategizing Against Q-Learners: A Control-Theoretical Approach},
  author={Arslantas, Yuksel and Yuceel, Ege and Sayin, Muhammed O.},
  journal={IEEE Control Systems Letters},
  volume={8},
  pages={1733--1738},
  year={2024},
  publisher={IEEE}
}