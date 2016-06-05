include:
  - jdk8.env

{%- from 'nexus/settings.sls' import nexus with context %}
{%- from 'jdk8/settings.sls' import java with context %}

{{ nexus.prefix }}:
  file.directory:
    - makedirs: True

{{ nexus.username }}:
  user.present

{{ nexus.download_dir }}:
  file.directory:
    - makedirs: True

{{ nexus.workdir }}/nexus:
  file.directory:
    - makedirs: True
    - user: {{ nexus.username }}
    - group: {{ nexus.group }}
    - recurse:
      - user
      - group

{{ nexus.piddir }}:
  file.directory:
    - makedirs: True
    - user: {{ nexus.username }}
    - group: {{ nexus.group }}
    - recurse:
      - user
      - group

unpack-nexus-tarball:
  cmd.run:
    - name: curl -L '{{ nexus.source_url }}' | tar xz
    - cwd: {{ nexus.download_dir }}
    - unless: test -d {{ nexus.home }}
    - require:
      - file: {{ nexus.prefix }}
      - file: {{ nexus.download_dir }}

{{ nexus.download_dir }}/sonatype_work:
  file.absent

move-nexus-dist:
  cmd.run:
    - name: mv {{ nexus.download_dir }}/nexus-* {{ nexus.real_home }}
    - unless: test -d {{ nexus.home }}

{{ nexus.real_home }}/conf:
  file.directory:
    - user: {{ nexus.username }}
    - group: {{ nexus.group }}
    - require:
      - cmd: unpack-nexus-tarball

{{ nexus.real_home }}/logs:
  file.directory:
    - user: {{ nexus.username }}
    - group: {{ nexus.group }}
    - require:
      - cmd: unpack-nexus-tarball

{{ nexus.real_home }}/tmp:
  file.directory:
    - user: {{ nexus.username }}
    - group: {{ nexus.group }}
    - require:
      - cmd: unpack-nexus-tarball

{{ nexus.home }}:
  file.symlink:
    - target: {{ nexus.real_home }}
    - force: True

/etc/init.d/nexus:
  file.managed:
    - mode: 755
    - source: salt://nexus/files/nexus.init
    - template: jinja
    - context:
      nexus_home: {{ nexus.home }}
      nexus_user: {{ nexus.username }}
      nexus_piddir: {{ nexus.piddir }}

{{ nexus.home }}/conf/nexus.properties:
  file.managed:
    - mode: 755
    - source: salt://nexus/files/nexus.properties
    - template: jinja
    - context:
      nexus_home: {{ nexus.home }}
      nexus_port: {{ nexus.port }}
      nexus_workdir: {{ nexus.workdir }}
      java_home: {{ java.java_home }}
    - require:
      - file: {{ nexus.real_home }}/conf

{{ nexus.home }}/bin/jsw/conf/wrapper.conf:
  file.replace:
    - pattern: wrapper.java.command=java
    - repl: wrapper.java.command={{ java.java_home }}/bin/java
    - onlyif: 'test -f {{ nexus.home }}/bin/jsw/conf/wrapper.conf'

#start-nexus-service:
#  service.running:
#    - name: nexus
#    - enable: true
