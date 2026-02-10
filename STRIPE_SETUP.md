# Stripe Payment Links – Success URL setup

The app uses **Stripe Payment Links** (no custom checkout, no webhooks). After payment, Stripe redirects the customer to a URL you configure in the Stripe Dashboard. **If that URL is wrong or not set, customers are not redirected back and do not get their upgrade (e.g. Verified Seller).**

## What to set in Stripe

1. Open [Stripe Dashboard](https://dashboard.stripe.com) → **Product catalog** → **Payment links**.
2. For each link, open it and **customize** the payment experience.

### Boost listing (7 days)

- **After payment** → **Redirect to a page**
- Set the URL to:
  - **Production (dealo.ie):** `https://dealo.ie/payment-success?type=boost`
  - **Local:** `http://localhost:3000/payment-success?type=boost` (only for testing)
- Optional: you can append `&listingId=123` if you pass the listing server-side; otherwise the app uses the session.

### Verified Seller (€1.99/month)

- **After payment** → **Redirect to a page**
- Set the URL to:
  - **Production (dealo.ie):** `https://dealo.ie/payment-success?type=verified`
  - **Local:** `http://localhost:3000/payment-success?type=verified` (only for testing)

## If someone already paid but wasn't redirected

1. Fix the success URL in Stripe (above) so future payments work.
2. In **Admin → Users**, find the user and click **"Mark verified"** (or **"Remove verified"** to undo). That sets their Verified Seller status without a new payment.

## Summary (dealo.ie)

| Payment link   | Success URL (copy into Stripe) |
|----------------|---------------------------------|
| Boost listing  | `https://dealo.ie/payment-success?type=boost` |
| Verified Seller| `https://dealo.ie/payment-success?type=verified` |

Without these URLs, Stripe may show its own "Thank you" page and never send the user back to your site, so the app never runs the success logic and the user does not get the upgrade.
