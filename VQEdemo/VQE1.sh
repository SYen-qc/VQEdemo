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

mkdir $HOME/openfermion_data >/dev/null 2>&1

env OPENFERMION_DATA_DIR=${HOME}/openfermion_data \
sbatch \
  --time=00:10:00 \
    --job-name="24Q_VQE_CO2_prep" \
      ${DIR_work}/VQEbatch.sh \
        -u \
  -j "24Q_CO2_VQE_prep" \
    -- \
      ${DIR_mpi}/job.7.sh \
          -- \
      ${DIR_py}/bin/python \
            -B \
          ${DIR_vqe}/vqe_common.py \
            --no-qulacs-grpc \
              --stop-before-vqe \
                --preprocess-data=${DIR_work}/24qubit_VQE_CO2_prep.pickle \
          --results-file=${DIR_work}/vqe_results_TEST-24Q.pickle \
            24qubit_CO2_VQE
