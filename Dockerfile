# Use the official PHP image with FPM
FROM php:8.2-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libzip-dev \
    unzip \
    git \
    curl \
    && docker-php-ext-install zip pdo pdo_mysql

# Manually install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    chmod +x /usr/local/bin/composer && \
    ln -s /usr/local/bin/composer /usr/bin/composer

# Set the working directory
WORKDIR /var/www/html

# Copy the composer.lock and composer.json files
COPY composer.json composer.lock ./

# Verify Composer is installed
RUN composer --version

# Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader

# Copy the rest of the application code
COPY . .

# Set the permissions for Symfony cache and logs
RUN chown -R www-data:www-data var/cache var/logs var/sessions

# Expose port 8080
EXPOSE 8080

# Start PHP-FPM
CMD ["php-fpm"]
