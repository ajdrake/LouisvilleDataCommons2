# louisvilledatacommons

CKAN Resources

https://docs.ckan.org/en/ckan-2.7.3/user-guide.html

https://docs.ckan.org/en/ckan-2.7.3/maintaining/index.html

Restarting: sudo service nginx reload

Config file: /etc/ckan/default/production.ini

Error log file: tail -f  /var/log/httpd/ckan_error.log

Update Permissions for cert file: chmod 400 (Drag File  here)

Public File Path:  /usr/lib/ckan/default/src/ckan/ckan/public/base/images

DKAN Resources

Follow the instructions in this guide just change the code part of obtaining the drupal source code:

Instead of

wget https://ftp.drupal.org/files/projects/drupal-8.3.4.zip
Download

git clone --branch master https://github.com/GetDKAN/dkan-drops-7.git 

Then follow the guide accordingly
https://www.howtoforge.com/tutorial/how-to-install-and-configure-drupal-on-debian-9/

Google Doc Links:
About Text(about page): https://docs.google.com/document/d/1wq73t1mLUfFTjMU8arMe8oFwhct2Ei0teWmndlPB7r0/edit?usp=sharing
Bylaws: https://docs.google.com/document/d/12FSVXbFbkdq1ydorAyfewKHysIXSmrpAz4UpmvxJ9XI/edit?usp=sharing


Cool CKAN look:
https://github.com/datosgobar/portal-andino-theme
