# nexus-formula

Formula to set up and configure a Sonatype Nexus server.

I've changed this formula's dependency on `sun-java` to my own JDK8 formula found here:

[https://github.com/rakhbari/saltstack-formula-jdk8.git](https://github.com/rakhbari/saltstack-formula-jdk8.git "JDK8 SaltStack Formula")

You must configure your `gitfs_remotes` in your minion config to point to the above repo for it to work.

Why? Because the SaltStack `sun-java` formula is just way too complex and even as of now still broken. Whereas the above JDK8 formula simply uses WebUpd8 Oracle JDK PPA to install it and it works flawlessly every time.


.. note::

    See the full `Salt Formulas installation and usage instructions
    <http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html>`_.

Available states
================

``nexus``
---------

Downloads the tarball in version nexus:version (currently defaults to 2.8.0) from sonatype configured as either a pillar or grain. 
Then unpacks the archive into nexus:prefix (defaults to /srv/nexus).
Depends on the sun-java-formula for its JDK.

Tested on RedHat/CentOS 5.X/6.X and Ubuntu trusty64

