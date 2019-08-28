#| Url handlers for blog entries

register GET /entries {} {
    #| List all entries
    return [entry_index]
}

register GET /entries/new {} {
    #| Form for submitting new blog entry
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
    #| Form for editing a specific blog entry
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
    #| Update an entry
    entry_update $entry_id $entry_title $entry_content
    ns_returnredirect [qc::url "/entries/$entry_id"]
}

register DELETE /entries/:entry_id {entry_id} {
    #| Delete an entry
    entry_delete $entry_id
    ns_returnredirect [qc::url "/entries"]
}


