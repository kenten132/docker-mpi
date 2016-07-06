#include <stdio.h>
#include <math.h>
#include <mpi.h>


int main (int argc, char **argv)
{
  int my_id, root_process, num_procs, ierr, num_intervals, i;
  MPI_Status status;

  /* Let process 0 be the root process. */

  root_process = 0;

  /* Now replicate this process to create parallel processes. */

  ierr = MPI_Init (&argc, &argv);

  /* Find out MY process ID, and how many processes were started. */

  ierr = MPI_Comm_rank (MPI_COMM_WORLD, &my_id);
  ierr = MPI_Comm_size (MPI_COMM_WORLD, &num_procs);

  int num_iterations = 1000000;

  /* Then...no matter which process I am:
   *
   * I engage in a broadcast so that the number of intervals is 
   * sent from the root process to the other processes, and ...
   **/
  int stopping = 0;
  if (my_id > 0) {
    while (!stopping) {
      MPI_Bcast(&stopping, 1, MPI_INT, root_process, MPI_COMM_WORLD);
      MPI_Barrier (MPI_COMM_WORLD);
    }
  }
  else {
    for (int i = 1; i <= num_iterations; i++) {
      if (i == num_iterations)
        stopping = 1;

      double t1, t2;

      MPI_Bcast(&stopping, 1, MPI_INT, root_process, MPI_COMM_WORLD);
      t1 = MPI_Wtime();
      MPI_Barrier (MPI_COMM_WORLD);
      t2 = MPI_Wtime();

      if (my_id == root_process)
        printf ("%f\n", t2-t1);
    }
  }


  /* Close down this processes. */

  ierr = MPI_Finalize ();
}
