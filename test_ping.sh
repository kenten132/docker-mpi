#!/bin/bash

for x in `seq 1 8`; do
  ping -c 1 10.10.1.10$x
done
