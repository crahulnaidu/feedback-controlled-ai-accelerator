#!/usr/bin/env bash
set -euo pipefail

# Find the repository root relative to this script.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT_DIR"

echo "Repository: $ROOT_DIR"
echo "Compiling Day 11 program-runner test..."

iverilog -g2012 -Wall -s tb_program_runner \
  -o /tmp/day11_sim \
  rtl/day04/pc.v \
  rtl/day06/register_file.v \
  rtl/day07/alu.v \
  rtl/day07/datapath_top.v \
  rtl/day09/control_extended.v \
  rtl/day09/datapath_extended.v \
  rtl/day10/instruction_rom.v \
  rtl/day10/program_runner.v \
  rtl/day10/tb_program_runner.v \
  rtl/day11/program_controller.v

echo "Running simulation..."
vvp /tmp/day11_sim
