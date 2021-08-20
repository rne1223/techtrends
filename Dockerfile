# python 2.7 is deprecated and it kept crashing when running flask
FROM python:3.8-slim-buster

EXPOSE 3111

# Keeps Python from generating .pyc files in the container
ENV PYTHONDONTWRITEBYTECODE=1
# Turns off buffering for easier container logging
ENV PYTHONUNBUFFERED=1

WORKDIR /app
COPY ./techtrends/ /app

# Install pip requirements
COPY requirements.txt .
RUN python -m pip install -r requirements.txt

# Initialize Database
RUN python init_db.py

ENTRYPOINT [ "python3" ]
CMD ["app.py"]