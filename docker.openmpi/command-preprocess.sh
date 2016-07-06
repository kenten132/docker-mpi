set -x
export PYTHON_PATH=.

cat /etc/hosts | grep "172"|grep "mpi_node" | awk '{print $1}' | sort -u > /home/tutorial/machines

rm -rf /home/tutorial/preprocess_data.zip
rm -rf /home/tutorial/dispel4py/tc_cross_correlation/OUTPUT/DATA
mkdir /home/tutorial/dispel4py/tc_cross_correlation/OUTPUT/DATA

OLD_PATH=`pwd`

cd /home/tutorial/dispel4py

for f in `cat /home/tutorial/machines`;
do ssh $f "rm -rf /home/tutorial/dispel4py/tc_cross_correlation/OUTPUT/DATA"
   ssh $f "mkdir /home/tutorial/dispel4py/tc_cross_correlation/OUTPUT/DATA"
done

mpiexec -n 16 -hostfile /home/tutorial/machines python -m dispel4py.new.processor mpi tc_cross_correlation/realtime_prep.py -f tc_cross_correlation/realtime_xcorr_input.jsn

for f in `cat /home/tutorial/machines`;
do scp -r $f:/home/tutorial/dispel4py/tc_cross_correlation/OUTPUT/DATA/* /home/tutorial/dispel4py/tc_cross_correlation/OUTPUT/DATA/
done


cd /home/tutorial/dispel4py/tc_cross_correlation/OUTPUT/DATA/
zip -r $OLD_PATH/preprocess_data.zip .

for f in `cat /home/tutorial/machines`;
do
scp -q /home/tutorial/preprocess_data.zip  $f:/home/tutorial/.
ssh $f "unzip -n /home/tutorial/preprocess_data.zip -d /home/tutorial/dispel4py/tc_cross_correlation/OUTPUT/DATA/"
done


