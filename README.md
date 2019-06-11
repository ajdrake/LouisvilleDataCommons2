# Intro to the Louisville Data Commons project 
[About Text (about page)]

[Bylaws]

[About Text (about page)]: https://docs.google.com/document/d/1wq73t1mLUfFTjMU8arMe8oFwhct2Ei0teWmndlPB7r0/edit?usp=sharing
[Bylaws]: https://docs.google.com/document/d/12FSVXbFbkdq1ydorAyfewKHysIXSmrpAz4UpmvxJ9XI/edit?usp=sharing


# CKAN Resources

[CKAN user guide]

[Maintaining CKAN]

[CKAN user guide]: https://docs.ckan.org/en/ckan-2.7.3/user-guide.html

[Maintaining CKAN]: https://docs.ckan.org/en/ckan-2.7.3/maintaining/index.html

Config file: ``/etc/ckan/default/production.ini``

Error log file: ``tail -f  /var/log/httpd/ckan_error.log``

Update Permissions for cert file: chmod 400 (Drag File  here)

Public File Path:  ``/usr/lib/ckan/default/src/ckan/ckan/public/base/images``

[CKAN andino theme]

[CKAN andino theme]: https://github.com/datosgobar/portal-andino-theme

# NGINX commands

Restarting: ``sudo service nginx reload``

# Drupal resources 
Then follow the guide accordingly
[Install and configure Drupal]

[Install and configure Drupal]: https://www.howtoforge.com/tutorial/how-to-install-and-configure-drupal-on-debian-9/

# DKAN Resources

Follow the instructions in this guide just change the code part of obtaining the drupal source code:

Instead of

wget https://ftp.drupal.org/files/projects/drupal-8.3.4.zip
Download

git clone --branch master https://github.com/GetDKAN/dkan-drops-7.git 

# Ways to integrate CKAN with Wordpress

All pages but data are on a wordpress site and the data is a separate CKAN site:

See: [Post 1] & [Post 2] & [Slides]

Sites: [York Open Data Site] & [Data.gov]

[York Open Data Site]: https://www.yorkopendata.org
[Post 1]: https://www.yorkopendata.org/ckan-and-wordpress-integration-blog-by-castlegate-it/
[Post 2]: https://www.castlegateit.co.uk/2015/03/ckan-and-wordpress-integration/
[Slides]: https://metaodi.ch/posts/2016/10/how-we-combined-wordpress-with-ckan/
[Data.gov]: https://www.data.gov
