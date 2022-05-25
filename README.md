# GitHub SSH authorized_keys

This is a simple script that syncs the keys downloaded by GitHub to
`~/.ssh/authorized_keys`. There's an option to either append the missing keys
or replace the whole file (`--replace` or `-r`)

## Usage

```
Usage: ./sync.sh [-h|--help] [-r|--replace] [-e|--enable] [-d|--disable] [-u|--username <github username>]

	-h,	--help		This help message
	-r,	--replace	Replace the authorized keys with the github ones
	-e,	--enable	Enable sync as a cronjob
	-d,	--disable	Disable the cronjob
	-u,	--username=USER	The GitHub username that the keys should be downloaded from
```

> **Note**
> Currently crontab enable might need some tinkering through `crontab -e`

> **Note**
> Currently crontab disable is not implemented
