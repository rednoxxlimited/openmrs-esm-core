# Dockerfile for openmrs-esm-core

FROM node:18-alpine AS builder

# Enable Corepack for Yarn 4 support
RUN corepack enable

WORKDIR /app

# Copy the entire repository first (needed for workspace resolution)
COPY . .

# Install dependencies
RUN yarn install --immutable

# Build all packages
RUN yarn build

# Production stage
FROM nginx:alpine

# Copy the built app shell
COPY --from=builder /app/packages/shell/esm-app-shell/dist /usr/share/nginx/html

# Copy nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]