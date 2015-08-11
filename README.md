# Fluent::Plugin::Mysql::Table

## Overview
It is now possible to obtain the table of the change difference of MySQL fluentd

## Usage

fluentd.conf

use change_mysql_table
```
<source>
  type in_mysql_table
  tag mysql.table
  host mysqlserver
  username username
  password password
  database database_name
  port     3306
  interval 60
</source>

<filter mysql.table>
  type change_mysql_table
  host mysqlserver
  username username
  password password
  port     3306
  interval 1
  database database_name
</filter>

<match mysql.table>
  type stdout
</match>
```

use change_prev_record
```
<source>
  type in_mysql_table
  tag mysql.table
  host mysqlserver
  username username
  password password
  database database_name
  port     3306
  interval 60
</source>

<filter mysql.table>
  type change_prev_record 
</filter>

<match mysql.table>
  type stdout
</match>
```

## Copyright

Copyright (c) 2015- Onishi Shigure
License   Apache License, Version 2.0
