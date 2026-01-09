# Dockerfile for openmrs-esm-core

FROM node:18-alpine AS builder

RUN corepack enable

WORKDIR /app

COPY . .

RUN yarn install --immutable

RUN yarn build

# Debug: Show what was built
RUN echo "=== Build output structure ===" && \
    find /app/packages -name "dist" -type d && \
    echo "=== App shell dist ===" && \
    ls -la /app/packages/shell/esm-app-shell/dist/ 2>/dev/null || echo "esm-app-shell/dist not found" && \
    echo "=== Looking for importmap ===" && \
    find /app -name "importmap.json" -type f 2>/dev/null

# Production stage
FROM nginx:alpine

# Try copying from the correct location
COPY --from=builder /app/packages/shell/esm-app-shell/dist /usr/share/nginx/html

COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]