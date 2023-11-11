FROM python:3.7

RUN git clone https://github.com/DarrielleEvans/deployment8.git

WORKDIR /deployment8/backend/

RUN pip install -r requirements.txt

RUN python manage.py migrate

EXPOSE 8000

CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
