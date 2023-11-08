# Start with the official WordPress image
FROM wordpress:latest

# Define build arguments
ARG MYSQLPASSWORD
ARG MYSQLHOST
ARG MYSQLPORT
ARG MYSQLDATABASE
ARG MYSQLUSER
ARG SIZE_LIMIT

# Set environment variables for the database connection
ENV WORDPRESS_DB_HOST=$MYSQLHOST:$MYSQLPORT
ENV WORDPRESS_DB_NAME=$MYSQLDATABASE
ENV WORDPRESS_DB_USER=$MYSQLUSER
ENV WORDPRESS_DB_PASSWORD=$MYSQLPASSWORD
ENV WORDPRESS_TABLE_PREFIX="RW_"

# Install Node.js and Yarn
RUN apt-get update && apt-get install -y nodejs npm
RUN npm install -g yarn

# Create a directory to store the custom wp-content
RUN mkdir -p /var/www/html/custom-wp-content

# Copy the content of your local wp-content directory into the custom-wp-content directory in the image
COPY ./wp-content /var/www/html/custom-wp-content

# Set the maximum upload file size in the PHP configuration
RUN echo "upload_max_filesize = $SIZE_LIMIT" >> /usr/local/etc/php/php.ini
RUN echo "post_max_size = $SIZE_LIMIT" >> /usr/local/etc/php/php.ini

# Configure Apache
RUN echo "ServerName 0.0.0.0" >> /etc/apache2/apache2.conf
RUN echo "DirectoryIndex index.php index.html" >> /etc/apache2/apache2.conf

# Change the working directory
WORKDIR /var/www/html

# Remove the original wp-content and replace it with the custom wp-content
RUN rm -r wp-content
RUN mv custom-wp-content wp-content

# Command to run Apache
CMD ["apache2-foreground"]
