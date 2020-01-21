FROM python:3.7

# просто подготовка конфига uwsgi и его рабочих директорий
RUN mkdir -p /usr/share/app.rc
COPY ./rc/uwsgi.ini /usr/share/app.rc/uwsgi.ini
RUN chmod g+w /var/run

WORKDIR /usr/src/app
ENV prometheus_multiproc_dir=/tmp

#TODO сделать s2i, наверняка это всё в слайсах будет одинаковое
COPY setup.py .

# это просто установка зависимостей, не самого приложения. эта часть закешируется до следующего изменения setup.py
RUN pip install uwsgi uwsgitop && \
    pip install --no-cache-dir  -e .

# а это установка приложения, она всегда будет запускаться заново при наличии изменений в коде
COPY . /usr/src/app
RUN pip install --no-cache-dir /usr/src/app

USER 1001
CMD [ "/usr/local/bin/uwsgi", "--ini", "/usr/share/app.rc/uwsgi.ini" ]
