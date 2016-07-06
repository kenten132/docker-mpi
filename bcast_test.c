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

  int num_iterations = 100;

  /* Then...no matter which process I am:
   *
   * I engage in a broadcast so that the number of intervals is 
   * sent from the root process to the other processes, and ...
   **/
  for (int i = 0; i < num_iterations; i++) {
    int data = i;
    double t1, t2;

    t1 = MPI_Wtime();
    MPI_Bcast (&data, 1, MPI_INT, root_process, MPI_COMM_WORLD);
    t2 = MPI_Wtime();

    if (my_id == root_process)
      printf ("%f\n", t2-t1);
  }


  /* Close down this processes. */

  ierr = MPI_Finalize ();
}
