#!/usr/bin/env bash
#
# Copyright 2017-2018 Sciamlab s.r.l. (@sciamlab)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
echo "==========================================================="
echo "This shell script is going to setup a running CKAN instance"
echo "==========================================================="

echo "Provisioning using privileged user: "$USER
echo -n "user home: "; echo ~
echo "PWD: "$PWD
echo "HOME: "$HOME 
export VMUSER=vagrant

echo "# ENVIRONMENT"
echo "alias v='ls -l'">.bash_aliases
echo "alias upd='sudo apt-get update; sudo apt-get -y upgrade; sudo apt-get -y dist-upgrade; sudo apt-get -y autoremove'">>.bash_aliases
sed -i -e 's/01;32m/01;36m/g' .bashrc

echo "# SET LANGUAGE"
sudo locale-gen it_IT.UTF-8
echo "export LANGUAGE=en_US.UTF-8" >> .bashrc
echo "export LANG=en_US.UTF-8" >> .bashrc
echo "export LC_ALL=en_US.UTF-8" >> .bashrc

echo `hostname -I | cut -d" " -f2`" ckan.local ckan">> /etc/hosts

echo "# ADDING THE PostgreSQL APT Repository (TO GET THE POSTGRESQL 10 DISTRO)"
wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | sudo apt-key add -
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'

echo "# UPDATE/UPGRADE"
sudo apt-get update; sudo apt-get -y upgrade; sudo apt-get -y dist-upgrade; sudo apt-get -y autoremove

echo "# DEPENDENCIES"
sudo apt-get install -y python-dev postgresql-10 postgresql-10-postgis-2.4 libpq-dev python-pip python-virtualenv git-core openjdk-8-jdk unzip redis-server
sudo apt-get install -y apache2 libapache2-mod-wsgi libapache2-mod-rpaf
sudo apt-get install -y libxml2-dev libxslt1-dev libgeos-c1v5 expect

echo "# POSTGRESQL / POSTGIS"
sudo -u postgres createuser -S -D -R ckan
sudo -u postgres psql -c "ALTER USER ckan WITH PASSWORD 'ckan2017';"
sudo -u postgres createdb -O ckan ckandb -E utf-8
sudo -u postgres psql -d ckandb -f /usr/share/postgresql/10/contrib/postgis-2.4/postgis.sql
sudo -u postgres psql -d ckandb -f /usr/share/postgresql/10/contrib/postgis-2.4/spatial_ref_sys.sql
sudo -u postgres psql -d ckandb -c 'ALTER VIEW geometry_columns OWNER TO ckan;'
sudo -u postgres psql -d ckandb -c 'ALTER TABLE spatial_ref_sys OWNER TO ckan;'
sudo -u postgres psql -d ckandb -c "SELECT postgis_full_version()"

echo "# GET AND SETUP APACHE SOLR 7.3.0"
echo "#################################"

wget -q http://mirror.23media.de/apache/lucene/solr/7.3.0/solr-7.3.0.tgz
tar -xzf solr-7.3.0.tgz solr-7.3.0/bin/install_solr_service.sh --strip-components=2
sudo ./install_solr_service.sh solr-7.3.0.tgz
sudo -u solr /opt/solr/bin/solr create -c ckan
sudo service solr stop
sudo cp /var/solr/data/ckan/conf/solrconfig.xml /vagrant/confsave/solrconfig_730_pre.xml

sudo -u solr sed -i '103d' /var/solr/data/ckan/conf/solrconfig.xml
sudo -u solr sed -i '103i  <schemaFactory class="ClassicIndexSchemaFactory"/>' /var/solr/data/ckan/conf/solrconfig.xml
sudo -u solr sed -i '855i  <!--' /var/solr/data/ckan/conf/solrconfig.xml
sudo -u solr sed -i '857i  -->' /var/solr/data/ckan/conf/solrconfig.xml
sudo -u solr sed -i '1163i <!-- removed to avoid This Indexschema is not mutable Error' /var/solr/data/ckan/conf/solrconfig.xml
sudo -u solr sed -i '1172d' /var/solr/data/ckan/conf/solrconfig.xml
sudo -u solr sed -i '1192i -->' /var/solr/data/ckan/conf/solrconfig.xml
sudo -u solr sed -i '1195d' /var/solr/data/ckan/conf/solrconfig.xml  
sudo -u solr sed -i '1195i   <updateRequestProcessorChain name="add-unknown-fields-to-the-schema" default="${update.autoCreateFields:false}"' /var/solr/data/ckan/conf/solrconfig.xml
sudo -u solr sed -i '1196d' /var/solr/data/ckan/conf/solrconfig.xml
sudo -u solr sed -i '1196i            processor="uuid,remove-blank,field-name-mutating,parse-boolean,parse-long,parse-double,parse-date">' /var/solr/data/ckan/conf/solrconfig.xml
sudo -u solr sed -i '761i      <str name="q.op">AND</str>' /var/solr/data/ckan/conf/solrconfig.xml
sudo -u solr sed -i '694i      <str name="q.op">AND</str>' /var/solr/data/ckan/conf/solrconfig.xml

sudo cp /var/solr/data/ckan/conf/solrconfig.xml /vagrant/confsave/solrconfig_730_post.xml

sudo -u solr cp /vagrant/artifacts/schema.xml /var/solr/data/ckan/conf/schema.xml
echo "# ADD JTS TO THE SOLR SETUP"
unzip /vagrant/artifacts/jts-release-1.15.0-bin.zip -d jts
sudo cp jts/lib/* /opt/solr/server/lib/
echo "# START SOL SERVICE"
sudo service solr start
rm install_solr_service.sh ; rm solr-7.3.0.tgz; rm -r jts


## CKAN
echo "# INSTALL THE CKAN 2.7.3"
echo "################################"
mkdir $PWD/sciamlab-ckan
mkdir $PWD/sciamlab-ckan/etc
sudo ln -sf $PWD/sciamlab-ckan/ /usr/lib/ckan
sudo ln -sf $PWD/sciamlab-ckan/etc /etc/ckan
cd $PWD/sciamlab-ckan
virtualenv --no-site-packages /usr/lib/ckan
. /usr/lib/ckan/bin/activate

# Let's update the pip just in case is not the latest
pip install --upgrade pip

# latest 2.7.3 release 
pip install -e 'git+https://github.com/ckan/ckan.git@ckan-2.7.3#egg=ckan'

# current development version
#pip install -e 'git+https://github.com/ckan/ckan.git#egg=ckan'

# WORKAROUND: In order to support PostgreSQL 10 the psycopg2
#             version should be set to  2.7.3.1 in requirement.txt
sed -i '33d' /usr/lib/ckan/src/ckan/requirements.txt
sed -i '33i psycopg2==2.7.3.1' /usr/lib/ckan/src/ckan/requirements.txt

pip install -r /usr/lib/ckan/src/ckan/requirements.txt
deactivate
. /usr/lib/ckan/bin/activate

# WORAROUND TO A STRANGE BEAVOUR OF THE setuptools
# @see https://github.com/ckan/ckan/pull/3544
pip install setuptools==20.4
#than going back to version 35.0.0
pip install setuptools==35.0.0


echo "# CONFIGURE THE CKAN 2.7.3"
echo "################################"
paster make-config ckan /etc/ckan/development.ini

cp /etc/ckan/development.ini /vagrant/confsave/development_273.ini

sed -i '48d' /etc/ckan/development.ini
sed -i '48i sqlalchemy.url = postgresql://ckan:ckan2017@localhost/ckandb' /etc/ckan/development.ini
sed -i '59d' /etc/ckan/development.ini
sed -i '59i ckan.site_url = http://'`hostname -I | cut -d" " -f2` /etc/ckan/development.ini
#2.8a sed -i '60d' /etc/ckan/development.ini
#2.8a sed -i '60i ckan.site_url = http://'`hostname -I | cut -d" " -f2` /etc/ckan/development.ini
sed -i '78d' /etc/ckan/development.ini
sed -i '78i ckan.site_id = ckan.local' /etc/ckan/development.ini
sed -i '79d' /etc/ckan/development.ini
sed -i '79i solr_url = http://127.0.0.1:8983/solr/ckan' /etc/ckan/development.ini
#2.8a sed -i '79d' /etc/ckan/development.ini
#2.8a sed -i '79i ckan.site_id = ckan.local' /etc/ckan/development.ini
#2.8a sed -i '80d' /etc/ckan/development.ini
#2.8a sed -i '80i solr_url = http://127.0.0.1:8983/solr/ckan' /etc/ckan/development.ini


# SETUP LOCAL STORAGE FOR CKAN 
mkdir /var/lib/ckan
chown -R www-data:$VMUSER /var/lib/ckan

#uncomment the ckan.storage setting
sed -i '152s/.//' /etc/ckan/development.ini
#2.8a sed -i '158s/.//' /etc/ckan/development.ini

cd /usr/lib/ckan/src/ckan
paster db init -c /etc/ckan/development.ini


# setup the datastore
# add the datastore plugin configuration
sudo -u postgres createuser -S -D -R -l ckan_ro
sudo -u postgres psql -c "ALTER USER ckan_ro WITH PASSWORD 'ckan2017';"
sudo -u postgres createdb -O ckan datastore_default -E utf-8
sed -i '50d' /etc/ckan/development.ini
sed -i '50i ckan.datastore.write_url = postgresql://ckan:ckan2017@localhost/datastore_default' /etc/ckan/development.ini
sed -i '51d' /etc/ckan/development.ini
sed -i '51i ckan.datastore.read_url = postgresql://ckan_ro:ckan2017@localhost/datastore_default' /etc/ckan/development.ini

# add the datastore and datapusher plugins to the conf file and configure it
sed -i '103s/$/ resource_proxy datastore datapusher/' /etc/ckan/development.ini
#2.8a sed -i '104s/$/ resource_proxy datastore datapusher/' /etc/ckan/development.ini

#uncomment the datapusher.url setting
sed -i '161s/.//' /etc/ckan/development.ini
#2.8a sed -i '167s/.//' /etc/ckan/development.ini

paster --plugin=ckan datastore set-permissions -c /etc/ckan/development.ini | sudo -u postgres psql --set ON_ERROR_STOP=1


# enable additional resource viewers
sed -i '103s/$/ recline_grid_view recline_graph_view recline_map_view webpage_view/' /etc/ckan/development.ini
#2.8a sed -i '104s/$/ recline_grid_view recline_graph_view recline_map_view webpage_view/' /etc/ckan/development.ini

echo "# SETUP CKAN SPATIAL PLUGIN & GEOVIEW #"
echo "#######################################"
cd /home/$VMUSER/sciamlab-ckan/src
pip install -e "git+https://github.com/okfn/ckanext-spatial.git#egg=ckanext-spatial"
cd /home/$VMUSER/sciamlab-ckan/src/ckanext-spatial
pip install -r pip-requirements.txt
# add the plugin to the CKAN configuration
sed -i '103s/$/ spatial_metadata spatial_query/' /etc/ckan/development.ini
sed -i '178i # Spatial Extension Settings' /etc/ckan/development.ini
sed -i '179i ckan.spatial.srid = 4326' /etc/ckan/development.ini
#2.8a sed -i '104s/$/ spatial_metadata spatial_query/' /etc/ckan/development.ini
#2.8a sed -i '184i # Spatial Extension Settings' /etc/ckan/development.ini
#2.8a sed -i '185i ckan.spatial.srid = 4326' /etc/ckan/development.ini

# add geoview to the virtualenv
pip install ckanext-geoview
sed -i '103s/$/ geo_view geojson_view wmts_view/' /etc/ckan/development.ini
#2.8a sed -i '104s/$/ geo_view geojson_view wmts_view/' /etc/ckan/development.ini




echo "# ENABLE CKAN PAGE TRACKING #"
echo "#############################"
sed -i '180i ckan.tracking_enabled = true' /etc/ckan/development.ini
#2.8a sed -i '186i ckan.tracking_enabled = true' /etc/ckan/development.ini
crontab -u $VMUSER /vagrant/artifacts/crontab


## WSGI
echo "# CONFIGURE APACHE AND THE WSGI"
echo "################################"
#add required apache2 modules
a2enmod headers

cp /vagrant/artifacts/ckan.conf /etc/apache2/sites-available
a2ensite ckan
sed -i '3i ServerAlias '`hostname -I | cut -d" " -f2` /etc/apache2/sites-available/ckan.conf


cp /vagrant/artifacts/apache.wsgi /etc/ckan/apache.wsgi
ln -s /usr/lib/ckan/src/ckan/who.ini /etc/ckan/who.ini
# create a production.ini
cp /etc/ckan/development.ini /etc/ckan/production.ini

sudo chown -R $VMUSER:$VMUSER /home/$VMUSER

apache2ctl restart

echo "# CONFIGURE CKAN DEFAULT USER  #"
echo "################################"
cd /home/$VMUSER/sciamlab-ckan/src/ckan
# add sysadmin rights to the ckan.local user 
paster sysadmin add ckan.local -c /etc/ckan/production.ini
# set the password of the ckan.local user
expect /vagrant/artifacts/paster.spawn


# SETUP THE DATAPUSHER
cd /home/$VMUSER/
deactivate
mkdir $PWD/datapusher
sudo ln -sf $PWD/datapusher /usr/lib/datapusher
cd /usr/lib/datapusher
virtualenv --no-site-packages /usr/lib/datapusher
. /usr/lib/datapusher/bin/activate
#mkdir /usr/lib/datapusher/src
#cd /usr/lib/datapusher/src
sudo git clone -b 0.0.13 https://github.com/ckan/datapusher.git src
cd /usr/lib/datapusher/src
../bin/pip install -r requirements.txt
../bin/python setup.py develop
cp /vagrant/datapusher.apache2-4.conf /etc/apache2/sites-available/datapusher.conf
cp /vagrant/datapusher.wsgi /etc/ckan/ 
cp deployment/datapusher_settings.py /etc/ckan/
sudo sh -c 'echo "NameVirtualHost *:8800" >> /etc/apache2/ports.conf'
sudo sh -c 'echo "Listen 8800" >> /etc/apache2/ports.conf'
sudo a2ensite datapusher

echo "# COMPLETED!!"
echo " you can connect to http://"`hostname -I | cut -d" " -f2`
#paster serve /etc/ckan/development.ini
