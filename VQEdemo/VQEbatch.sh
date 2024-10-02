#!/bin/bash
#
# Fast VQE Simulation Sample Program
# 2024/Sep
# Fujitsu Ltd.
#
#SBATCH --partition=Batch
#SBATCH --output="%x.out.%j"
#SBATCH --open-mode=append
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --time=1:00:00
#SBATCH --job-name="batch.7"


set -e  # シェルスクリプト中でエラーが発生したら、そこで終了させる
export t0_sbatch=$(date +%s)  # このスクリプトの実行が開始された時刻
NNODES=${SLURM_NNODES:-1}  # sbatch --nodes=NUM ... のNUM
N_APP=1  # MPIアプリケーションの数
NPROC_PER_APP=${NNODES}  # 1つのMPIアプリケーションが使う、プロセス数＝(ノード数)
JOB_NAME=""
cmd_mpirun="mpirun"

usage () {
    echo "usage: $0 [-h] [-n NUM] [-p NUM] [-v] -- CMD ARG1 ARG2 ..."
    echo "    -h      help"
    echo "    -j      used in 'srun --job-name=...'"
    echo "    -m CMD  specify 'mpirun' command (default: $cmd_mpirun)"
    echo "    -n NUM  number of applications"
    echo "    -p NUM  number of nodes for an application"
    echo "    -u      unset HTTP_PROXY https_proxy http_proxy no_proxy HTTPS_PROXY"
    echo "    -v      verbose"
    exit 9
}

while getopts "hj:m:n:p:uv-" OPT
do
    case $OPT in
        h) usage ;;
        m) cmd_mpirun=$OPTARG ;;
        n) N_APP=$OPTARG ;;
        j) JOB_NAME=$OPTARG ;;
        p) NPROC_PER_APP=$OPTARG ;;
        u) unset HTTP_PROXY https_proxy http_proxy no_proxy HTTPS_PROXY ;;
        v) echo "$0" : $(hostname) : $(date) ;;
        -) break ;;
    esac
done

#echo OPTIND = $OPTIND
shift $(( $OPTIND - 1))
#echo "$@"
if [[ -z "${JOB_NAME}" ]] ; then
    JOB_NAME=$1
fi

#unset OMPI_APP_CTX_NUM_PROCS
#unset OMPI_ARGV
#unset OMPI_COMMAND
#unset OMPI_COMM_WORLD_LOCAL_RANK
#unset OMPI_COMM_WORLD_LOCAL_SIZE
#unset OMPI_COMM_WORLD_NODE_RANK
#unset OMPI_COMM_WORLD_RANK
#unset OMPI_COMM_WORLD_SIZE
#unset OMPI_FILE_LOCATION
#unset OMPI_FIRST_RANKS
#unset OMPI_MCA_ess_base_jobid
#unset OMPI_MCA_ess_base_vpid
#unset OMPI_MCA_ess
#unset OMPI_MCA_initial_wdir
#unset OMPI_MCA_mpi_oversubscribe
#unset OMPI_MCA_orte_app_num
#unset OMPI_MCA_orte_bound_at_launch
#unset OMPI_MCA_orte_ess_node_rank
#unset OMPI_MCA_orte_ess_num_procs
#unset OMPI_MCA_orte_hnp_uri
#unset OMPI_MCA_orte_jobfam_session_dir
#unset OMPI_MCA_orte_launch
#unset OMPI_MCA_orte_local_daemon_uri
#unset OMPI_MCA_orte_num_nodes
#unset OMPI_MCA_orte_precondition_transports
#unset OMPI_MCA_orte_tmpdir_base
#unset OMPI_MCA_orte_top_session_dir
#unset OMPI_MCA_pmix
#unset OMPI_MCA_rmaps_ppr_n_pernode
#unset OMPI_MCA_shmem_RUNTIME_QUERY_hint
#unset OMPI_NUM_APP_CTX
#unset OMPI_UNIVERSE_SIZE                     ##### [openmpi] bozo check #####
#unset PMIX_BFROP_BUFFER_TYPE
#unset PMIX_GDS_MODULE
#unset PMIX_HOSTNAME
#unset PMIX_ID
#unset PMIX_MCA_gds
#unset PMIX_MCA_mca_base_component_show_load_errors
#unset PMIX_MCA_psec
#unset PMIX_NAMESPACE
#unset PMIX_RANK
#unset PMIX_SECURITY_MODE
#unset PMIX_SERVER_TMPDIR
#unset PMIX_SERVER_URI21
#unset PMIX_SERVER_URI2
#unset PMIX_SERVER_URI3
#unset PMIX_SERVER_URI41
#unset PMIX_SERVER_URI4
#unset PMIX_SYSTEM_TMPDIR
#unset PMIX_VERSION

#printenv | grep -E '^(OMP_|OMPI_|PMIX_|SLURM|MPI_QULACS|QULACS)' | sort
#set -vx

if [[ "${N_APP}" -eq 1 ]] ; then
    if [[ -z "${OMPI_UNIVERSE_SIZE}" ]] ; then
        # 1段目のvqe_common.pyの場合を想定している
        echo DEBUG: ${cmd_mpirun} -n "${NPROC_PER_APP}" -npernode 1 "$@"
        exec ${cmd_mpirun} -n "${NPROC_PER_APP}" -npernode 1 "$@"
    else
        exec srun --ntasks-per-node=1 --nodes=${NPROC_PER_APP} --job-name="${JOB_NAME}" "$@"
    fi
fi

i=1
pids=""
while [[ ${i} -le ${N_APP} ]] ; do
    srun --ntasks-per-node=1 --nodes=${NPROC_PER_APP} --job-name="${JOB_NAME}-${i}/${N_APP}" "$@" &
    #srun --verbose --verbose --verbose ... # DEBUG
    last_pid=$!
    pids="${pids} ${last_pid}"
    i=$(( ${i} + 1))
    sleep 1  
done

#echo pids = $pids
wait ${pids}
