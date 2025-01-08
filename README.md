# mail_to_misp_docker
Docker container for mail_to_misp - email in your threat intelligence

## Volumes

Create a volume for configuration to mount on to /config will be helpful for setting up the config file of mail_to-misp. 
This will contain your settings for sending the email to misp as an event. Fake-smtpd doesn't need a configuration file, as the container handles anything that could be required.
Running the container on a port other than 25 may require additional configuration.
