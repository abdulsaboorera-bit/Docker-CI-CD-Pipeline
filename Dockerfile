FROM node:18 as build
WORKDIR /app

COPY ./Frontend/ecommerce_inventory/package.json/ /code/Frontend/ecommerce_inventory/

WORKDIR /code/Frontend/ecommerce_inventory

#Install Packages
RUN npm install


#Build the React App
RUN npm run build


#Backend Stage

FROM python:3.11


#Set Environment Variables

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

WORKDIR /code

#Copy DJango Project Files into the Container

COPY ./Backend/EcommerceInventory /code/Backend/EcommerceInventory/

#Install Required Packages
RUN pip install -r /code/Backend/EcommerceInventory/requirements.txt



#Copy fronend build into Django project
COPY --from=build /code/Frontend/ecommerce_inventory/build /code/Backend/EcommerceInventory/static/

COPY --from=build /code/Frontend/ecommerce_inventory/build/static /code/Backend/EcommerceInventory/static/

COPY --from=build /code/Frontend/ecommerce_inventory/build/index.html /code/Backend/EcommerceInventory/EcommerceInventory/templates/index.html



#Run Django Migrations Command

RUN python ./Backend/EcommerceInventory/manage.py migrate


#Run Django Collectstatic Command
RUN python ./Backend/EcommerceInventory/manage.py collectstatic --no-input

#Expose the port
EXPOSE 80

WORKDIR /code/Backend/EcommerceInventory

#Run the Django Server
CMD ["gunicorn", "EcommerceInventory.wsgi.application", "--bind", "0.0.0.0:8000"]