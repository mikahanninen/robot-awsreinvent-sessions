# Web scraping AWS re:Invent Sessions

Robot for parsing [re:Invent](https://reinvent.awsevents.com/) sessions.

## To run

1. Install rcc. See instructions at https://github.com/robocorp/rcc.
2. rcc pull https://github.com/mikahanninen/robot-awsreinvent-sessions
3. rcc run

## Configuration

Configure following environment variables:

#### AWS_SESSION_TAG

List only sessions with this tag
```
AWS_SESSION_TAG=databases
```

#### AWS_SESSION_DATE

List sessions only on this date
```
AWS_SESSION_DATE="Dec 17, 2020"
```

#### AWS_SESSION_STATS

Set to any value if you want to see session tag statistics in the console output
```
AWS_SESSION_STATS=1
```

#### AWS_SESSION_DESC

Set to any value if you want to see session description in the console output
```
AWS_SESSION_DESC=1
```

### Language Filter

By default only English language sessions are shown. Modify the `task.robot` variable `@{LANGUAGE_FILTER}` to change what languages are shown.

### Robocloud Vault

Required secrets have been stored into `Robocorp Vault` with key `aws-reinvent` which
needs to hold variables `email` and `password` for the user accessing AWS re:Invent website.

For instructions to set the `Robocorp Vault` see https://robocorp.com/docs/development-howtos/variables-and-secrets/vault.

#### How it works

1. Initialize process variables
2. If file `aws_sessions.html` is missing from the current directory then AWS re:Invent site will be scraped for HTML content. **Note.** This opens a browser window which should be left untouched during the scraping process. Also **note that the process might take quite a long time (10+ minutes)**, because browsing for the sessions if a slow process.
3. Once we have `aws_sessions.html` file then the sessions are extracted from the HTML.
4. Output sessions to the console according to set variables.
