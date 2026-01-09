# Dockerfile for openmrs-esm-core

FROM node:18-alpine AS builder

# Enable Corepack for Yarn 4 support
RUN corepack enable

WORKDIR /app

# Copy package manager configuration
COPY package.json yarn.lock ./
COPY .yarnrc.yml ./
COPY .yarn ./.yarn

# Copy workspace package.json files for dependency resolution
COPY packages/apps/*/package.json ./packages/apps/
COPY packages/framework/*/package.json ./packages/framework/
COPY packages/shell/*/package.json ./packages/shell/
COPY packages/tooling/*/package.json ./packages/tooling/

# Install dependencies
RUN yarn install --immutable

# Copy all source code
COPY . .

# Build all packages
RUN yarn build

# Production stage - use the OpenMRS frontend base image approach
FROM nginx:alpine

# Copy the built app shell
COPY --from=builder /app/packages/shell/esm-app-shell/dist /usr/share/nginx/html

# Copy nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]