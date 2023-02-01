# telegram-ssh-alert

A simple telegram bot that sends a message when someone starts a SSH session on a configured host.

It relies on the user **rc** file, which is a script executed everytime a SSH connection is initiated. 
Located at **~/.ssh/rc**, good for a single user, or at **/etc/ssh/sshrc**, good for the whole system.
The file at the user's home folder takes precedence, but if it doesn't exist, then **/etc/ssh/sshrc** is executed instead.

Allows you to set individual addresses and subnets as trusted.

Can be configured to trigger on all connections, or only on connections made by unauthorized hosts.

# Usage
1. Create a new Telegram Bot by messaging @BotFather, get the API token and chat_id
2. Download the script
3. Make it executable: `$ sudo chmod +x telegram-ssh-alert.sh`
4. Create the file ~/.ssh/rc (if you want it to be triggered when this specific user logs in) or /etc/ssh/sshrc (triggered on all logins iff
there is no rc file for that user)
5. Inside this file, add the absolute path of the script as an executable. Assuming it is located in the home folder: `./~/telegram-ssh-alert.sh`
6. Edit `tg-ssh-alert.sh` and modify these variables with your own values:
    1. `chat_id`
    2. `telegram_api_token`
    3. `allowed_subnets`, CIDR notation, space-separated
    4. `allowed_addresses`, space-separated
    5. `only_unauthorized`







