FROM python:3.8-slim
RUN pip install flask
RUN pip install dingtalkchatbot
COPY app.py /app.py
EXPOSE 5000
ENTRYPOINT ["python", "/app.py"]
