# OpenAlt z. s. project tracking system

Currently a slightly modified Redmine instance is used. The goal is to have as minimal and clean-looking system as possible.

![screenshot00](2015-07-26-190703_1680x1050+0+0_imlib2_grab.png)
![screenshot01](2015-07-26-190752_1680x1050+0+0_imlib2_grab.png)
![screenshot02](2015-07-26-190834_1680x1050+0+0_imlib2_grab.png)
![screenshot03](2015-07-26-191313_1680x1050+0+0_imlib2_grab.png)

### Steps to reproduce the Redmine setup:

1. setup SQL DB
1. [install current Redmine 3.x](http://www.redmine.org/projects/redmine/wiki/redmineinstall) and setup the SQL DB backend (FIXME: how to migrate existing Redmine DB?)
1. install Redmine plugins `redmine_auto_watchers` `redmine_drafts` and theme `redmine-pepper-theme`

~~~~sh
RM='/usr/local/lib/redmine'
cd "$RM"/plugins/ && git clone --depth 1 https://github.com/thegcat/redmine_auto_watchers
cd "$RM"/plugins/ && git clone --depth 1 https://github.com/jbbarth/redmine_drafts.git
# plugins require "migration"
cd "$RM" && rake redmine:plugins:migrate RAILS_ENV=production
# themes require only web server restart
cd "$RM"/public/themes/ && git clone --depth 1 https://github.com/koppen/redmine-pepper-theme.git

# make the text field visible (without clicking on the tiny icon and with more lines of text shown)
cp ~/redmine_setup_howto/app/views/issues/_form.html.erb "$RM"/app/views/issues/
# change subjects of all emails to "#ID Issue full name", exchange the issue description for the change diff
cp ~/redmine_setup_howto/app/models/mailer.rb "$RM"/app/models/
# make the dotted line in history being above each of the records, not below
cp ~/redmine_setup_howto/public/stylesheets/application.css "$RM"/public/stylesheets/

/etc/init.d/apache2 restart  # or nginx restart
~~~~

1. in Redmine Administration

    * set the default theme to "redmine-pepper-theme"
    * have only one queue (Issues)
    * only two issue states (Open/Closed)
    * two roles (Worker, Project Manager)
    * permissions for everything (except for creating/deleting top-level projects in case of "Worker" and except for "Create private notes" for anyone)
    * make as few fields visible as possible (e.g. no queue, no category, no version, etc.)
    * default columns in project issues list: issue numerical id, issue name, assignee, date of completion, state, priority
    * text syntax "Redmine Markdown"

1. in each project

    * make everything public and switch off all plugins/extensions except for *issues*
    * create a subproject with the same name and postfix *" - private"* and switch on the *wiki* and *files* plugins

### TODO

* find commonmark/markdown edit live preview module
* make the empty vertical space between the top bar and search bar much smaller
* remove the huge issue type (e.g. "Issue") + id (e.g. " #3494") from the page and add the id to the issue name instead
* remove user queries (they remained in the DB after some plugin)
* try plugins: marius-balteanu/redmine-theme-gitmike, marius-balteanu/redmine_mention_plugin, marius-balteanu/redmine_autostatus, marius-balteanu/redmine_new_issue_view

### Maintenance

* uninstall plugins

    ~~~~sh
cd /usr/local/lib/redmine/
rake redmine:plugins:migrate NAME=plugin_name VERSION=0 RAILS_ENV=production
rm -r plugins/plugin_name/
/etc/init.d/apache2 restart  # or nginx restart
~~~~

* backup DB

    ~~~~sh
# ask for password
mysqldump --skip-extended-insert --compact -u UserName -p --default-character-set utf8 internal_db_name > dump00.sql
~~~~

### Usage

* do NOT use "URL" field in project settings (it looks ugly on the project dashboard) and use the description text field instead
* do NOT use Redmine groups, but rather special users representing a group (because such *group user* has usually some mailing list email address and therefore lots of duplicate work is avoided and also in mailing lists, there are usually more people than in Redmine)
* create a default query which shows all tasks in a tree and make sure, that only leafs are tasks to be done (in other words, the tree should be a WBS where non-leaf nodes only describe their siblings and can't be procured themself in comparison to their siblings) - so the nodes will become general descriptions (meta information about the actual work to be done) and leafs the actual implementation (the work to be done in the form of tasks)
