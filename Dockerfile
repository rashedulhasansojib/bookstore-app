# Use the official PHP 8.2 image with Apache
FROM php:8.2-apache

# Set working directory inside the container
WORKDIR /var/www/html

# Install required system dependencies
RUN apt-get update && apt-get install -y \
    unzip \
    git \
    libicu-dev \
    libzip-dev \
    && docker-php-ext-install intl zip opcache

# Install Composer properly
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copy Symfony project files into the container
COPY . .

# Fix permissions
RUN chown -R www-data:www-data /var/www/html

# Switch to non-root user
USER www-data

# Install Symfony Flex manually before running Composer install
RUN composer global require symfony/flex

# Run Composer install as non-root user
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Switch back to root user
USER root

# Expose port 80 for Apache
EXPOSE 80

# Start Apache
CMD ["apache2-foreground"]
