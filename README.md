
== ChurchDirectory

Blazing through some code to get a nice, printable directory for our church.

I normally have good test coverage, but this is just a proof of concept, so no tests :)

We use churchmembershiponline.com for our membership database.  However, their 
membership directories leave something to be desired.  This allows us to import
the Excel files that they export, and then display it nicely.

NOTE: The ChurchMembershipOnline.com export must be re-saved as a normal .xls first.

Suggestions for DB Management:
 - Add birth order number for children so we don't need to store birth year
 - Make sure any ", Jr." or ", Sr." shoudl be at the end of the first_name.  e.g. Charles "Butch", Sr   not Charles, Sr "Butch"
 - For those that are adult children consider having them be non-dependents

### S3 setup (one-time on Heroku)

```bash
heroku config:set AWS_BUCKET=your_bucket_name
heroku config:set AWS_ACCESS_KEY_ID=your_access_key_id
heroku config:set AWS_SECRET_ACCESS_KEY=your_secret_access_key
```

### Heroku Deployment

```bash
git push heroku master
heroku run rake db:migrate
heroku restart
```

Set up a church:

```bash
heroku rake setup_church[churchurn,DRBC]  # won't let you have spaces and quotes
```

Add user to a church:

```bash
heroku rake add_church_user[churchurn,email]
```

Debugging:

```bash
heroku logs
```

Dealing with Database Sizes:

We sometimes get warnings about database sizes being too large.  This is usually due to CSV upload rows.

```bash
heroku rake table_sizes
heroku rake truncate_csv_log
```

