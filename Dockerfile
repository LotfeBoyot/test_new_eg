# Use official PHP image with necessary extensions
FROM php:8.2-cli

# Set working directory
WORKDIR /var/www

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    unzip \
    zip \
    libzip-dev \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    && docker-php-ext-install pdo pdo_mysql mbstring zip exif pcntl

# Install swoole via PECL
RUN pecl install swoole && docker-php-ext-enable swoole

# Install Composer
COPY --from=composer:2.6 /usr/bin/composer /usr/bin/composer

# Copy existing application
COPY . .

# Install Laravel dependencies
RUN composer install --no-interaction --prefer-dist --optimize-autoloader

# Set permissions (optional depending on how you're managing storage/logs)
RUN chown -R www-data:www-data /var/www

# Expose Laravel Octane port (default 8000)
EXPOSE 8000

# Run Octane server with Swoole
CMD php artisan octane:start --server=swoole --host=0.0.0.0 --port=8000
