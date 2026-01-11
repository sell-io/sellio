# Devise Authentication Setup Commands

Run these commands in WSL to set up authentication:

## Step 1: Install Devise gem
```bash
bundle install
```

## Step 2: Install Devise
```bash
rails generate devise:install
```

**IMPORTANT:** When prompted, you'll need to:
1. Set a default URL in `config/environments/development.rb`:
   ```ruby
   config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
   ```
   (This is already done automatically, but check if needed)

## Step 3: Generate User model with Devise (this will add authentication to your existing users table)
```bash
rails generate devise User
```

**Note:** If you get a conflict because User already exists, use:
```bash
rails generate devise User --force
```

## Step 4: Add additional fields to User model (if not already added)
```bash
rails generate migration AddFieldsToUsers name:string phone:string location:string
```

## Step 5: Run migrations
```bash
rails db:migrate
```

## Step 6: Generate Devise views (so we can customize them)
```bash
rails generate devise:views
```

**Note:** The views have already been customized in `app/views/devise/`, so you can skip this if the files already exist.

---

## What's Already Done:

✅ Devise gem added to Gemfile  
✅ Custom login page created (`app/views/devise/sessions/new.html.erb`)  
✅ Custom signup page created (`app/views/devise/registrations/new.html.erb`)  
✅ Login/Signup buttons added to homepage  
✅ Navigation updated to show user info when logged in  
✅ ApplicationController configured for Devise  
✅ Routes configured for Devise  
✅ Styling added for authentication pages  

---

## After Running These Commands:

You'll have:
- ✅ User authentication (login, signup, logout)
- ✅ Password reset functionality
- ✅ Session management
- ✅ Beautiful styled login/signup pages
- ✅ Login/Signup buttons on homepage

The authentication routes will be available at:
- `/users/sign_in` - Login page
- `/users/sign_up` - Signup page  
- `/users/sign_out` - Logout (DELETE request)
- `/users/edit` - Edit account page

---

## Testing:

1. Start your Rails server: `rails server`
2. Visit `http://localhost:3000`
3. Click "Sign Up" to create an account
4. Click "Login" to sign in
5. When logged in, you'll see "My Account" and "Logout" in the navigation
