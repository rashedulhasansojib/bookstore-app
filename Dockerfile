# Use the official PHP image with FPM
FROM php:8.2-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libzip-dev \
    unzip \
    git \
    php-cli \
    && docker-php-ext-install zip pdo pdo_mysql

# Set the working directory
WORKDIR /var/www/html

# Copy Composer
COPY --from=composer:latest /usr/local/bin/composer /usr/local/bin/composer

# Copy the composer.lock and composer.json files
COPY composer.json composer.lock ./

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader

# Copy the rest of the application code
COPY . .

# Set the permissions for the Symfony cache and logs
RUN chown -R www-data:www-data var/cache var/logs var/sessions

# Expose port 8080
EXPOSE 8080

# Start PHP-FPM
CMD ["php-fpm"]
