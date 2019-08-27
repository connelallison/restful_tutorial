register GET /entries {} {
    return [entry_index]
}

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
	<br><br>
	<a href="http://localhost/entries">Return to index</a>
    }

    return [qc::form method POST action /entries $form]
}

register POST /entries {entry_title entry_content} {
    #| Create a new blog entry
    set entry_id [entry_create $entry_title $entry_content]
    ns_returnredirect [qc::url "/entries/$entry_id"]
}

register GET /entries/:entry_id/edit {entry_id} {
    db_1row {
        select
	entry_title,
	entry_content
	from
	entries
	where entry_id=:entry_id
    }

    set form "
	<label>Blog Title:</label>
	<br>
	<input type=\"text\" name=\"entry_title\" value=\"$entry_title\">
	<br>
	<label>Blog Content:</label>
	<br>
	<textarea name=\"entry_content\" style=\"width: 400px; height: 120px;\">$entry_content</textarea>
	<br>
        <input type=\"hidden\" name=\"_method\" value=\"PUT\">
	<input type=\"submit\" name=\"submit\" value=\"Update\">
	<br><br>
	<a href=\"http://localhost/entries\">Return to index</a>
    "

    return [qc::form method POST action "/entries/$entry_id" $form]
}

register GET /entries/:entry_id {entry_id} {
    #| View an entry
    return [entry_get $entry_id]
}

register PUT /entries/:entry_id {entry_id entry_title entry_content} {
    entry_update $entry_id $entry_title $entry_content
    ns_returnredirect [qc::url "/entries/$entry_id"]
}

register DELETE /entries/:entry_id {entry_id} {
    entry_delete $entry_id
    ns_returnredirect [qc::url "/entries"]
}


proc entry_create {entry_title entry_content} {
    #| Create a new blog entry
    set entry_id [db_seq entry_id_seq]
    db_dml "insert into entries\
           [sql_insert entry_id entry_title entry_content]"
    return $entry_id
}

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
    append html [h br]
    append html [h a href "http://localhost/entries/$entry_id/edit" "Edit this blog"]
    append html [h br]
    append html [form method DELETE action /entries/$entry_id [h input type submit name submit value "Delete this blog"]]
    append html [h br]
    append html [h a href "http://localhost/entries/new" "Submit another blog"]
    append html [h br]
    append html [h a href "http://localhost/entries" "Return to index"]

    return $html
}

proc entry_index {} {
    set html ""
    append html [h h1 "All Entries"]
    append html [h br]
    db_foreach { select entry_id, entry_title from entries order by entry_id asc } {
	append html [h a href "http://localhost/entries/$entry_id" $entry_title]
	append html [h br]
    }
    append html [h br]
    append html [h a href "http://localhost/entries/new" "Submit another blog"]
    
    return $html
}

proc entry_update {entry_id entry_title entry_content} {
    db_dml "update entries set [sql_set entry_title entry_content] where entry_id=:entry_id"
    ns_returnredirect [qc::url "/entries/$entry_id"]
}

proc entry_delete {entry_id} {
    db_dml "delete from entries where entry_id=:entry_id"
}
