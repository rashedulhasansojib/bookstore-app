# Use the official PHP 8.2 image with Apache
FROM php:8.2-apache

# Set the working directory inside the container
WORKDIR /var/www/html

# Install system dependencies
RUN apt-get update && apt-get install -y \
    unzip \
    git \
    libicu-dev \
    libzip-dev \
    && docker-php-ext-install intl zip opcache

# Install Composer properly
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copy Symfony project files to the container
COPY . .

# Ensure Composer runs as www-data user (not root)
RUN chown -R www-data:www-data /var/www/html

# Switch to www-data user before installing dependencies
USER www-data

# Install Symfony dependencies
RUN composer install --no-dev --optimize-autoloader --no-interaction || true

# Switch back to root user
USER root

# Expose port 80 for Apache
EXPOSE 80

# Start Apache
CMD ["apache2-foreground"]
