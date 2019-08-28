Tutorial: Restful Blog
========

### Introduction

This tutorial will guide you through building a simple blog site with RESTful endpoints, where you can create new blog posts and read, update, or delete existing ones. This assumes you have a `zz.tcl` as outlined in the [request handler tutorial](setting-up.md) - if not, complete that first.

If you encounter unexpected errors or have difficulty in getting things to work, start by checking your logs - you may find you can find and correct the problem yourself. The command `less /var/log/naviserver/qcode.log` (replacing "qcode.log" with whatever name you chose for your [full config file](qc-config.tcl)) will show you the server's logs - the End key will take you straight to the bottom, where you will find your error. You can also search the logs using `/` followed by the pattern you wish to search for.


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

Now, create two new files in the `/var/www/alpha.co.uk/tcl` directory - one called `entry.tcl` and one called `url_handlers.tcl`. Add the following code to your `url_handlers.tcl` file:

```tcl
register GET /entries/new {} {
    #| Form for submitting new blog entry
    set form ""
    append form [h label "Blog Title:"]
    append form [h br]
    append form [h input type text name entry_title]
    append form [h br]
    append form [h label "Blog Content:"]
    append form [h br]
    append form [h textarea name entry_content style "width: 400px; height: 120px;"]
    append form [h br]
    append form [h input type submit name submit value Submit]

    return [qc::form method POST action /entries $form]
}
```

Save the file. Restart naviserver using the command `systemctl restart naviserver@qcode` (as with viewing the logs, replace "qcode" with whatever name you chose for your config file). When naviserver has restarted, visit `localhost/entries/new` - you should see a form for submitting a new blog post.

At present, if you click submit, you will see "Not Found", and your browser's address bar should read `localhost/entries` - the button is set up to tell the server to create a new blog entry, but the server has not been told how to deal with such an instruction. To remedy this, start by adding the following code, again to `url_handlers`:

```tcl
register POST /entries {entry_title entry_content} {
    #| Create a new blog entry
    set entry_id [entry_create $entry_title $entry_content]
    ns_returnredirect [qc::url "/entries/$entry_id"]
}
```

If you try the submit button now (after saving the file and restarting naviserver), it will still not work, but you should now see "Internal Server Error" instead of "Not Found". Try checking the logs - they should say something like `App:Error: invalid command name "entry_create"` - this is because we have not created `entry_create` yet. It, and our other procs, will go in the `entry.tcl` file. In `entry.tcl`, add this code:

```tcl
proc entry_create {entry_title entry_content} {
    #| Create a new blog entry
    set entry_id [db_seq entry_id_seq]
    db_dml "insert into entries\
           [sql_insert entry_id entry_title entry_content]"
    return $entry_id
}
```

Save, restart, and try submitting a blog with "test" for the title and content. You should now get "Not Found" again. However, you should see the address is now `localhost/entries/1`, unlike before. Go into psql and run `SELECT * FROM entries;` and you will see that your blog has in fact been successfully submitted.

The reason you are seeing "Not Found" is because you have been redirected to the address that should show you the details of your new blog entry, but the server has not yet been given instructions to deal with that request. To fix that, add this code to your `url_handlers`:

```tcl
register GET /entries/:entry_id {entry_id} {
    #| View an entry
    return [entry_get $entry_id]
}
```

You should now be getting "Internal Server Error" once again. Check the logs if you like, or just look at the code we just added - we are trying use an `entry_get` proc that we haven't written yet. Add the following to `entry.tcl`:

```tcl
proc entry_get {entry_id} {
    #| Return html summary for this entry 
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

We have made use of the `register` proc throughout the `url_handlers.tcl` file. This is used to register a path, so that the server has instructions in place for how to deal with, for example, a request such as `GET entries/1`. For more detail, see its documentation [here](registration.md).

When constructing our form (and later in the `entry_get` proc), we used the `h` proc to generate html elements for us. The first argument you pass it is the type of html element you want. After specifying the type, any additional elements will be interpreted as alternating key value pairs. If the final argument is unpaired, it is placed in the body of the element. Consider this example:

```tcl
h a href "http://localhost/entries/new" "Submit another blog"
```

This will return a string containing the HTML for an <a> element that reads "Submit another blog" and links back to the new entry form. It is preferable to use the `h` proc instead of writing strings of raw HTML yourself, and essential for anything that involves variable substitution - aside from making construction of HTML easier, it also takes care of sanitising your data and preventing critical security vulnerabilities such as SQL injection. 

We also used the `form` proc to construct the form you passed to the user. It will return a form element, using the arguments you pass it as key-value pairs and the final unpaired argument you pass it (if applicable) placed in the body of the element. See our example:

```tcl
return [qc::form method POST action /entries $form]
```

Here, it returns a form element with `method="POST"` and `action="/entries"`, and then places the html we have stored in the `form` string variable inside the body of the form. Use this proc when you are constructing forms - aside from not having to write out the full HTML, it also takes care of attaching a hidden authenticity token - if you see an error that refers to there being no authenticity token, you should check to see if you have skipped over using this proc (or a similar one), which would have taken care of it for you.