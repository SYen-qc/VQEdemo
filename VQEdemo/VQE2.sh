#!/bin/bash
#
# Fast VQE Simulation Sample Program
# 2024/Sep
# Fujitsu Ltd.

DIR_mpi=/data/qc/deploy/VQEsimulation_qulacs/mpi
DIR_vqe=/data/qc/deploy/vqe
DIR_grpc=/data/qc/deploy/qulacs-grpc
DIR_py=/data/qc/miniforge3/envs/py39-vqe-20240426
DIR_work=$HOME/VQEdemo

sbatch \
  --time=01:00:00 \
    --job-name="24Q_VQE_CO2" \
      ${DIR_work}/VQEbatch.sh \
        -u \
  -j "24Q_CO2_VQE" \
    -- \
      ${DIR_mpi}/job.7.sh \
          -- \
      ${DIR_py}/bin/python \
            -B \
          ${DIR_vqe}/vqe_common.py \
            --config-file=${DIR_grpc}/qulacs_grpc-20240503.yml \
              --sbatch \
                --sbatch-time="01:00:00" \
          --title=demo \
            --save-address="${DIR_work}/qulacs-dir.@SLURM_JOB_ID@.json" \
              --qulacs-grpc-server-num=10\
                --qulacs-grpc-server-nprocs=1 \
          --hamiltonian-cut-percent=80 \
            --start-from-vqe \
              --preprocess-data="${DIR_work}/24qubit_VQE_CO2_prep.pickle" \
                --hack-energy-function \
          --maxiter=99999 \
            --results-file=${DIR_work}/vqe_results_TEST-24Q.pickle \
              24qubit_CO2_VQE
