# Use the official PHP 8.2 image with Apache
FROM php:8.2-apache

# Set the working directory inside the container
WORKDIR /var/www/html

# Install system dependencies
RUN apt-get update && apt-get install -y \
    unzip \
    git \
    curl \
    libzip-dev \
    libpng-dev

# Install PHP extensions required for Symfony
RUN docker-php-ext-install zip gd

# Enable Apache Rewrite Module (needed for Symfony routing)
RUN a2enmod rewrite

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Verify Composer installation
RUN composer --version

# Copy application files
COPY . .

# Set COMPOSER_ALLOW_SUPERUSER to allow plugin execution
ENV COMPOSER_ALLOW_SUPERUSER=1

# Install Symfony Flex globally before installing dependencies
RUN composer global require symfony/flex

# Clear Composer cache
RUN composer clear-cache

# Install Symfony dependencies (disable auto-scripts to prevent `symfony-cmd` errors)
RUN composer install --no-dev --optimize-autoloader --no-scripts

# Run auto-scripts manually (ignore `symfony-cmd` error)
RUN composer run-script auto-scripts || true

# Set correct permissions
RUN chown -R www-data:www-data /var/www/html
RUN chmod -R 755 /var/www/html

# Expose port 80 for Apache
EXPOSE 80

# Start Apache when the container runs
CMD ["apache2-foreground"]
