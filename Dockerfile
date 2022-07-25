# miniconda 2 comes with python 2.7
FROM continuumio/miniconda

# system dependencies
RUN apt-get --allow-releaseinfo-change update
RUN apt-get install -y \
gcc \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/*

# python dependencies
RUN conda update conda
COPY ./environment.yml /environment.yml
RUN conda env update --name base --file /environment.yml
RUN rm /environment.yml


# install pychem
COPY ./pychem-1.0 /pychem-1.0
WORKDIR /pychem-1.0
RUN python setup.py install
WORKDIR /the/workdir/path /
RUN rm -r /pychem-1.0

RUN conda clean -ay

# copy required files

COPY ./docking_files /docking_files
COPY ./Index /Index
COPY ./MGLTools-1.5.6 /MGLTools-1.5.6
COPY ./Model /Model



COPY ./ligtmap.py /ligtmap.py
COPY ./psovina /psovina
COPY ./predict /predict

# bind mount input.smi, /Output
COPY ./target.lst /target.lst

WORKDIR /

# SET MGL_ROOT ENV VARIABLE FOR pythonsh
ENV MGL_ROOT /MGLTools-1.5.6

ENTRYPOINT ["/predict"]