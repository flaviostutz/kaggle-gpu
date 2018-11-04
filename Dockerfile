FROM tensorflow/tensorflow:1.12.0-rc0-py3
# FROM tensorflow/tensorflow:1.0.0-py3
#FROM tensorflow/tensorflow:1.0.0.2-gpu-py3

RUN apt-get update && \
    apt-get install git -y

RUN pip install --upgrade pip

#PROCESSING
RUN pip install scoop && \
    pip install multiprocessing_generator

#GRAPHING
RUN pip install plotly && \
#    pip install python-igraph && \
    pip install seaborn && \
    pip install altair && \
    pip install git+https://github.com/jakevdp/JSAnimation.git && \
    pip install bokeh

#GEO
RUN pip install Geohash && \
    pip install mplleaflet && \
    apt-get install libgeos-dev -y

#TEXT PROCESSING
RUN pip install textblob && \
    pip install git+git://github.com/amueller/word_cloud.git && \
    pip install toolz cytoolz && \
    pip install gensim && \
    pip install PyPDF2 && \
    pip install slate3k && \
    pip install bs4
RUN python -c "import nltk; nltk.download('punkt')"
RUN python -c "import nltk; nltk.download('rslp')"
RUN python -c "import nltk; nltk.download('stopwords')"
RUN python -c "import nltk; nltk.download('floresta')"
RUN python -c "import nltk; nltk.download('all-corpora')"

#DATA
RUN pip install h5py && \
    pip install pyexcel-ods && \
    pip install pandas-profiling && \
    pip install sklearn-pandas

#IMAGE
RUN pip install pydicom && \
    pip install --trusted-host itk.org -f https://itk.org/SimpleITKDoxygen/html/PyDownloadPage.html SimpleITK && \
    pip install scikit-image && \
    pip install opencv-python && \
    pip install ImageHash && \
    apt-get install libav-tools -y && \
    apt-get install imagemagick -y && \
    pip install git+https://github.com/danoneata/selectivesearch.git

#LEARNING
RUN apt-get install pandoc -y && pip install pypandoc && pip install deap && \
    pip install git+https://github.com/tflearn/tflearn.git && \
    pip install scipy && \
    pip install scikit-learn && \
    pip install tpot && \
    pip install heamy

RUN cd /usr/local/src && mkdir keras && cd keras && \
    #keras
    git clone --depth 1 https://github.com/fchollet/keras.git && \
    cd keras && python setup.py install && \
    #keras-rl
    cd /usr/local/src && mkdir keras-rl && cd keras-rl && \
    git clone --depth 1 https://github.com/matthiasplappert/keras-rl.git && \
    cd keras-rl && python setup.py install && \
    # Keras likes to add a config file in a custom directory when it's first imported. This doesn't work with our read-only filesystem, so we have it done now
    python -c "from keras.models import Sequential"  && \
    # Switch to TF backend
    sed -i 's/theano/tensorflow/' /root/.keras/keras.json  && \
    # Re-run it to flush any more disk writes
    python -c "from keras.models import Sequential; from keras import backend; print(backend._BACKEND)" && \
    # Keras reverts to /tmp from ~ when it detects a read-only file system
    mkdir -p /tmp/.keras && cp /root/.keras/keras.json /tmp/.keras

#MISC
RUN pip install wavio && \
    pip install trueskill

#SPARK DRIVER
# RUN apt-get install openjdk-8-jdk -y
# RUN curl https://archive.apache.org/dist/spark/spark-2.3.0/spark-2.3.0-bin-hadoop2.7.tgz --output /tmp/spark-2.3.0-bin-hadoop2.7.tgz
# RUN cd /tmp && tar -xzf spark-2.3.0-bin-hadoop2.7.tgz && \
#     mv spark-2.3.0-bin-hadoop2.7 /opt/spark-2.3.0 && \
#     ln -s /opt/spark-2.3.0 /opt/spark̀
# RUN pip install findspark
# ENV SPARK_MASTER ''

#CLEANUP
RUN rm -rf /root/.cache/pip/* && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /usr/local/src/*

RUN apt-get install supervisor -y

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

ADD /start-jupyter.sh /

CMD ["/usr/bin/supervisord"]
