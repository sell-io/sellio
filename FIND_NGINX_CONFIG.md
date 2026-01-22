# How to Find Your Nginx Configuration File

## Quick Commands to Find Nginx Config

Run these commands on your server to locate the nginx configuration:

### 1. Find the main nginx config file:
```bash
nginx -t
```
This will show you the path to the main config file (usually `/etc/nginx/nginx.conf`)

### 2. Find where nginx is looking for configs:
```bash
nginx -V 2>&1 | grep -o '\-\-conf-path=\S*'
```

### 3. Common locations to check:

**On Ubuntu/Debian:**
- Main config: `/etc/nginx/nginx.conf`
- Site configs: `/etc/nginx/sites-available/your-site-name`
- Enabled sites: `/etc/nginx/sites-enabled/your-site-name`

**On CentOS/RHEL:**
- Main config: `/etc/nginx/nginx.conf`
- Site configs: `/etc/nginx/conf.d/your-site.conf`

**If compiled from source:**
- `/usr/local/nginx/conf/nginx.conf`
- `/opt/nginx/conf/nginx.conf`

## For Your Site (dealo.ie)

Since your site is `dealo.ie`, look for:
- `/etc/nginx/sites-available/dealo.ie`
- `/etc/nginx/sites-enabled/dealo.ie`
- `/etc/nginx/conf.d/dealo.ie.conf`
- Or check the main `/etc/nginx/nginx.conf` file

## How to Edit

1. **SSH into your server**
2. **Find the config file** using the commands above
3. **Edit with sudo:**
   ```bash
   sudo nano /etc/nginx/nginx.conf
   # OR
   sudo nano /etc/nginx/sites-available/your-site-name
   ```

4. **Add these lines** (inside the `http` block for global, or `server` block for site-specific):
   ```nginx
   client_max_body_size 200M;
   client_body_buffer_size 256k;
   client_body_timeout 120s;
   client_header_timeout 120s;
   ```

5. **Test and reload:**
   ```bash
   sudo nginx -t
   sudo systemctl reload nginx
   ```

## If You're Using a Hosting Service

If you're using a managed hosting service (like Heroku, DigitalOcean App Platform, etc.), you may need to:
- Check their documentation for nginx configuration
- Use their control panel/UI to adjust settings
- Contact their support for help

## Still Can't Find It?

Run this command to see all nginx-related files:
```bash
sudo find /etc -name "*nginx*" -type f 2>/dev/null
```
