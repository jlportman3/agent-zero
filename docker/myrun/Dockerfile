# Build Agent Zero runtime image from the latest repository sources
FROM frdel/agent-zero-base:latest

WORKDIR /a0

# Copy repository into the image
COPY . /a0

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Expose default web UI port
EXPOSE 80

# Run the default startup script
CMD ["/exe/run_A0.sh", "main"]
