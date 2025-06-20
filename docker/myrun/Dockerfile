FROM frdel/agent-zero-base:latest

WORKDIR /app

# Copy repository code into the image
COPY . /app

RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 80

CMD ["python", "run_ui.py", "--host", "0.0.0.0", "--port", "80"]
