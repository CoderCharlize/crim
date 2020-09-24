###Run the following commands in terminal to install hpHawkes on HPC###
#git clone https://github.com/suchard-group/hawkes

#module load anaconda3/personal (need this every time)
#anaconda-setup (only need this the first time)
#conda create –n urop (set up a new environment in conda, only the first time)
#source activate urop
#conda install r –c conda-forge (install r in conda, only the first time)

#R CMD build hawkes
#conda install r-Rcpp
#conda install r-RcppParallel
#conda install r-mvtnorm
#conda install r-truncnorm
#conda install r-BH
#go to R in terminal & install.packages("RcppXsimd",repos="http://cran.us.r-project.org")
#quit R in terminal
#R CMD INSTALL hpHawkes_0.1.0.tar.gz

#qsub (name of job script to submit on HPC)
#qstat (check the state of job scripts)


setwd("~/hawkes/")
library(hpHawkes)

#Check the serial implementation for 1000 locations:
timeTest(locationCount=1000)
timeTest(locationCount=1000, simd=2) 
timeTest(locationCount=1000, simd=2, threads=4) 
timeTest(locationCount=1000, gpu=1,single=1)

dc_xyt <- readRDS("data/dc_xyt.RDS")

is.unsorted(dc_xyt$T) # check that Time is ordered correctly

#Compare running times for MCMC, using CPU, SSE, AVX and GPU:
one_thread_no_simd <- sampler(n_iter=1000, locations=cbind(dc_xyt$X,dc_xyt$Y),times=dc_xyt$T,)

two_threads_avx <- sampler(n_iter=1000, locations=cbind(dc_xyt$X,dc_xyt$Y),times=dc_xyt$T, threads=2, simd=2)

gpu <- sampler(n_iter=1000, locations=cbind(dc_xyt$X,dc_xyt$Y),times=dc_xyt$T, gpu=1, single=1)

one_thread_no_simd$Time
two_threads_avx$Time
gpu$Time

#In our case, get MCMC sample using GPU with initial values of 1 and spatial & temporal background lengthscales set to 1.6 kilometers and 14 days
#Again change the "simd" and "thread" arguments to explore different MCMC running times
cpu_sse <- sampler(n_iter=1000,
               burnIn=200,
               params=c(1,1/1.6,1/(14*24),1,1,1), locations=cbind(dc_xyt$X,dc_xyt$Y),
               times=dc_xyt$T,
               simd=1,threads=8)


cpu_avx <- sampler(n_iter=1000,
               burnIn=200,
               params=c(1,1/1.6,1/(14*24),1,1,1), locations=cbind(dc_xyt$X,dc_xyt$Y),
               times=dc_xyt$T,
               simd=2,threads=8)

gpu <- sampler(n_iter=1000,
               burnIn=200,
               params=c(1,1/1.6,1/(14*24),1,1,1), locations=cbind(dc_xyt$X,dc_xyt$Y),
               times=dc_xyt$T,
               gpu=1, single=1)

cpu_sse$Time
cpu_avx$Time
gpu$Time

#Create trace plot for, say, the self-excitatory weight:
plot(gpu$samples[5,],type="l",ylab="Self-Exciting Weight")
