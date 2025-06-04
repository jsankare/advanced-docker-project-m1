# Build stage
FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install all dependencies (including dev dependencies)
RUN npm install

# Copy project files
COPY . .

# Create a non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Set ownership to non-root user
RUN chown -R appuser:appgroup /app

# Switch to non-root user
USER appuser

# Expose port
EXPOSE 3002

# Start the application (will be overridden by docker-compose)
CMD ["npm", "start"] 