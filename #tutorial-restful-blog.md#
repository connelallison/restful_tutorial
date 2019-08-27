Tutorial: Restful Blog
========

### Introduction

This tutorial will guide you through building a simple blog site with RESTful endpoints, where you can create new blog posts and read, update, or delete existing ones. This assumes you have a `zz.tcl` as outlined in the [request handler tutorial](setting-up.md) - if not, complete that first.

If you encounter unexpected errors or have difficulty in getting things to work, start by checking your logs - you may find you can find and correct the problem yourself. The command `less /var/log/naviserver/qcode.log` (replacing "qcode.log" with whatever name you chose for your [full config file](qc-config.tcl)) will show you the server's logs - the End key will take you straight to the bottom, where you will find your error.

## Introducing RESTful



## Database setup

Before writing the site itself, we will create a basic database where its data will be stored. In psql, run the following commands:

```sql
create table entries (
		      entry_id int primary key,
		      entry_title plain_string,
		      entry_content text
		      );

create sequence entry_id_seq;
```

If you have gone through the [database tutorial](tutorial-6-database.md), this should be familiar and require no further explanation.

Now, create a new file called blog.tcl in the /var/www/alpha.co.uk/tcl directory. Add the following code to it:

```tcl
register GET /entries/new {} {
    set form {
	<label>Blog Title:</label>
	<br>
	<input type="text" name="entry_title">
	<br>
	<label>Blog Content:</label>
	<br>
	<textarea name="entry_content" style="width: 400px; height: 120px;"></textarea>
	<br>
	<input type="submit" name="submit" value="Submit">
    }

    return [qc::form method POST action /entries $form]
}
```

Save the file. Restart naviserver using the command `systemctl restart naviserver@qcode` (as with viewing the logs, replace "qcode" with whatever name you chose for your config file). When naviserver has restarted, visit `localhost/entries/new` - you should see a form for submitting a new blog post.

At present, if you click submit, you will see "Not Found", and your browser's address bar should read `localhost/entries` - the button is set up to tell the server to create a new blog entry, but the server has not been told how to deal with such an instruction. To remedy this, start by adding the following code:

```tcl
register POST /entries {entry_title entry_content} {
    #| Create a new blog entry
    set entry_id [entry_create $entry_title $entry_content]
    ns_returnredirect [qc::url "/entries/$entry_id"]
}
```

If you try the submit button now (after saving the file and restarting naviserver), it will still not work, but you should now see "Internal Server Error" instead of "Not Found". Try checking the logs - they should say something like `App:Error: invalid command name "entry_create"` - this is because we have not created `entry_create` yet. Add the following code to your file (for neatness, I suggest grouping the procs together at the bottom):

```tcl
proc entry_create {entry_title entry_content} {
    #| Create a new blog entry
    set entry_id [db_seq entry_id_seq]
    db_dml "insert into entries\
           [sql_insert entry_id entry_title entry_content]"
    return $entry_id
}
```

Save, restart, and try submitting a blog with "test" for the title and content. You should now get "Not Found" again. However, you should see the address is now `localhost/entries/1`, unlike before. Go into psql, and run `SELECT * FROM entries;` and you will see that your blog has in fact been successfully submitted.

The reason you are seeing "Not Found" is because you have been redirected to the address that should show you the details of your new blog entry, but the server has not yet been given instructions to deal with that request. To fix that, add this code:

```tcl
register GET /entries/:entry_id {entry_id} {
    #| View an entry
    return [entry_get $entry_id]
}
```

You should now be getting "Internal Server Error" once again. Check the logs if you like, or just look at the code we just added - we are trying use an "entry_get" proc that we haven't written yet. Add the following to your code:

```tcl
proc entry_get {entry_id} {
    #| 
    db_1row {
	select
	entry_title,
	entry_content
	from
	entries
	where entry_id=:entry_id
    }
    set html ""
    append html [h h1 $entry_title]
    append html [h div $entry_content]
    return $html
}
```

After saving and restarting, try submitting a blog post. You should, at last, be able to see the post you have submitted (and you should be able to see your previous posts if you change your address to have their entry_id instead).

You have now added create and read functionality to your site. Before moving on, let's review the code we've added, how it works, and what procs we have been using.

The first code we added - the new entry form - 