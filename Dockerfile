# Build stage
FROM node:18-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package files first (better caching)
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production=false

# Copy source files
COPY . .

# Build the extension
RUN npm run build

# Create separate stages for different browsers
FROM scratch AS chromium
COPY --from=builder /app/dist /dist
COPY --from=builder /app/chromium/manifest.json /dist/manifest.json

FROM scratch AS firefox
COPY --from=builder /app/dist /dist
COPY --from=builder /app/firefox/manifest.json /dist/manifest.json

# Default to chromium build
FROM chromium AS final
