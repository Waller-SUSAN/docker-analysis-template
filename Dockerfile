FROM labwaller/base:latest

ARG home=/home/rstudio/

RUN cd $home && mkdir -p code/ data/ figures/ report/

COPY code/* ${home}code/
COPY data/* ${home}data/
COPY figures/* ${home}figures/
COPY report/* ${home}report/
