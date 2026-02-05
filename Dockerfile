
FROM php:8.2-fpm 

RUN apt-get update && apt-get install -y \ 
    git curl zip unzip libpng-dev libonig-dev libxml2-dev libzip-dev libicu-dev libpq-dev \ 
    nodejs npm \ 
    && docker-php-ext-install pdo pdo_pgsql mbstring zip exif pcntl gd intl \ 
    && apt-get clean && rm -rf /var/lib/apt/lists/* # 2. Instalar Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer


WORKDIR /var/www 


COPY . . 


RUN composer install --optimize-autoloader --no-interaction
RUN npm install && npm run build 


RUN chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache


EXPOSE 8000 


CMD sh -c "sleep 10 && php artisan migrate:fresh --seed --force && php artisan serve --host=0.0.0.0 --port=8000"