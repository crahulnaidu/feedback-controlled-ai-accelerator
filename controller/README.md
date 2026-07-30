# Feedback Controller

This directory contains the runtime controller responsible for managing the AI accelerator.

The controller will monitor

- Latency
- Energy
- Temperature
- Accuracy
- Utilization
- Battery State

and generate runtime control actions such as

- DVFS
- Quantization
- Sparsity
- Scheduling
- Dataflow Selection

## Subdirectories

pid/
    Classical control

mpc/
    Model Predictive Control

rl_controller/
    Reinforcement Learning based controller

simulations/
    Closed-loop simulations

## Goal

Develop a feedback-controlled runtime management system for safety-critical AI accelerators.