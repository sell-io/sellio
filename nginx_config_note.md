# Nginx Configuration for Large File Uploads - FIX 413 ERROR

The Rails application has been configured to accept uploads up to 200MB. However, **nginx MUST be configured** to allow larger uploads, otherwise you'll get a "413 Request Entity Too Large" error.

## URGENT: Fix the 413 Error

The 413 error occurs because nginx has a default limit of 1MB for uploads. You MUST increase this in your nginx configuration.

## Required nginx configuration:

**Option 1: Global configuration (recommended)**

Edit `/etc/nginx/nginx.conf` and add inside the `http` block:

```nginx
http {
    # Increase client body size limit to 200MB (for multiple image uploads)
    client_max_body_size 200M;
    
    # Increase buffer sizes for large requests
    client_body_buffer_size 256k;
    
    # Increase timeouts for large uploads
    client_body_timeout 120s;
    client_header_timeout 120s;
    send_timeout 120s;
    
    # ... rest of your nginx config
}
```

**Option 2: Server block configuration (if you can't edit global config)**

Edit your site-specific nginx config (usually `/etc/nginx/sites-available/your-site` or `/etc/nginx/conf.d/your-site.conf`):

```nginx
server {
    listen 80;
    server_name dealo.ie www.dealo.ie;
    
    # CRITICAL: Increase client body size limit to 200MB
    client_max_body_size 200M;
    client_body_buffer_size 256k;
    client_body_timeout 120s;
    client_header_timeout 120s;
    send_timeout 120s;
    
    # ... rest of server config ...
}
```

## After updating nginx config:

1. **Test the configuration:**
   ```bash
   sudo nginx -t
   ```

2. **If test passes, reload nginx:**
   ```bash
   sudo systemctl reload nginx
   ```
   OR
   ```bash
   sudo service nginx reload
   ```

3. **If reload doesn't work, restart nginx:**
   ```bash
   sudo systemctl restart nginx
   ```

## Current Rails Configuration:

The Rails application has been configured with:
- `config.action_dispatch.parameter_size_limit = 200.megabytes` in both `config/application.rb` and `config/environments/production.rb`

## Important Notes:

- **The nginx configuration MUST be updated** - Rails settings alone won't fix the 413 error
- The default nginx limit is 1MB, which is why you're getting the error
- After updating nginx, restart your Rails application if needed
- Test with a few large images to verify it works
