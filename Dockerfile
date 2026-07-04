# ==========================
# Frontend Build Stage
# ==========================
FROM node:18 AS build

WORKDIR /code/Frontend/ecommerce_inventory

# Copy package files
COPY ./Frontend/ecommerce_inventory/package*.json ./

# Install dependencies
RUN npm install

# Copy the entire React project
COPY ./Frontend/ecommerce_inventory/ .

# Build React
RUN npm run build


# ==========================
# Backend Stage
# ==========================
FROM python:3.11

# Environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /code

# Copy Django project
COPY ./Backend/EcommerceInventory /code/Backend/EcommerceInventory/

# Install Python dependencies
RUN pip install --no-cache-dir -r /code/Backend/EcommerceInventory/requirements.txt

# Copy React build into Django
COPY --from=build /code/Frontend/ecommerce_inventory/build /code/Backend/EcommerceInventory/static/

COPY --from=build /code/Frontend/ecommerce_inventory/build/index.html \
    /code/Backend/EcommerceInventory/EcommerceInventory/templates/index.html

WORKDIR /code/Backend/EcommerceInventory

# Expose Gunicorn port
EXPOSE 8000

# Run migrations and collectstatic at container start (needs a live DB
# connection + real env vars, neither of which exist during docker build),
# then start Gunicorn.
CMD python manage.py migrate && \
    python manage.py collectstatic --no-input && \
    gunicorn EcommerceInventory.wsgi:application --bind 0.0.0.0:8000