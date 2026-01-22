# Nginx Configuration for Large File Uploads

The Rails application has been configured to accept uploads up to 50MB. However, if you're using nginx as a reverse proxy, you also need to configure nginx to allow larger uploads.

## Required nginx configuration:

Add or update the following in your nginx configuration file (usually `/etc/nginx/sites-available/your-site` or `/etc/nginx/nginx.conf`):

```nginx
http {
    # Increase client body size limit to 50MB (for multiple image uploads)
    client_max_body_size 50M;
    
    # Increase buffer sizes for large requests
    client_body_buffer_size 128k;
    
    # Increase timeouts for large uploads
    client_body_timeout 60s;
    client_header_timeout 60s;
    
    # ... rest of your nginx config
}
```

Or if you only want to apply it to a specific server block:

```nginx
server {
    # ... other server config ...
    
    # Increase client body size limit to 50MB
    client_max_body_size 50M;
    client_body_buffer_size 128k;
    client_body_timeout 60s;
    
    # ... rest of server config ...
}
```

## After updating nginx config:

1. Test the configuration: `sudo nginx -t`
2. Reload nginx: `sudo systemctl reload nginx` or `sudo service nginx reload`

## Note:

The Rails application has been configured with:
- `config.action_dispatch.parameter_size_limit = 50.megabytes` in both `config/application.rb` and `config/environments/production.rb`

This should handle multiple image uploads without nginx errors.
