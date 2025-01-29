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
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Copy Symfony project files to the container
COPY . .

# Set correct permissions
RUN chown -R www-data:www-data /var/www/html

# Switch to non-root user (to prevent plugin execution issues)
USER www-data

# Install Symfony dependencies (without global Symfony Flex)
RUN composer install --no-dev --optimize-autoloader --no-interaction --no-scripts

# Run auto-scripts manually, ignoring errors
RUN composer run-script auto-scripts || true

# Switch back to root user
USER root

# Expose port 80 for Apache
EXPOSE 80

# Start Apache
CMD ["apache2-foreground"]
