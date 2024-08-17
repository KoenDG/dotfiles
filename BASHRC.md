Bash manpage: https://manpages.org/bash

Good blogpost explanation: https://shreevatsa.wordpress.com/2008/03/30/zshbash-startup-files-loading-order-bashrc-zshrc-etc/

For Bash, they work as follows. Read down the appropriate column. Executes A, then B, then C, etc. The B1, B2, B3 means it executes only the first of those files found.

(Table modified based on manpage):

+----------------+----------------------+--------------+-------+
|                |Login                 |Non-login     |Script |
|                |(Interactive or not)  |Interactive   |       |
+----------------+----------------------+--------------+-------+
|/etc/profile    |          A           |              |       |
+----------------+----------------------+--------------+-------+
|/etc/bash.bashrc|                      |      A       |       |
+----------------+----------------------+--------------+-------+
|~/.bashrc       |                      |      B       |       |
+----------------+----------------------+--------------+-------+
|~/.bash_profile |          B1          |              |       |
+----------------+----------------------+--------------+-------+
|~/.bash_login   |          B2          |              |       |
+----------------+----------------------+--------------+-------+
|~/.profile      |          B3          |              |       |
+----------------+----------------------+--------------+-------+
|BASH_ENV        |                      |              |   A   |
+----------------+----------------------+--------------+-------+
|                |                      |              |       |
+----------------+----------------------+--------------+-------+
|                |                      |              |       |
+----------------+----------------------+--------------+-------+
|~/.bash_logout  |          C           |              |       |
+----------------+----------------------+--------------+-------+

Script is non-login and non-interactive

Another linked source from the blogpost: https://www.solipsys.co.uk/new/BashInitialisationFiles.html

Showing this useful flowchart: ![The flowchart](BashStartupFiles1.png)


