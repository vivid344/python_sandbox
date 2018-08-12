FROM python:3.7
ENV PYTHONUNBUFFERED 1
RUN mkdir /app
WORKDIR /app
RUN pip install pipenv

# django_sandbox用　
# 実行時のコマンドは docker run コンテナ名
ADD ./django_sandbox /app/
RUN pipenv install
RUN pipenv run make
RUN pipenv run migrate
CMD ["pipenv", "run", "start", "0.0.0.0:8000"]