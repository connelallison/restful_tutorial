#| Url handlers for blog entries

register GET /entries {} {
    #| List all entries
    return [entries_index]
}

register GET /entries/new {} {
    #| Form for submitting new blog entry
    # set form {
    # 	<label>Blog Title:</label>
    # 	<br>
    # 	<input type="text" name="entry_title">
    # 	<br>
    # 	<label>Blog Content:</label>
    # 	<br>
    # 	<textarea name="entry_content" style="width: 400px; height: 120px;"></textarea>
    # 	<br>
    # 	<input type="submit" name="submit" value="Submit">
    # 	<br><br>
    # 	<a href="http://localhost/entries">Return to index</a>
    # }

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
    append form [h br]
    append form [h br]
    append form [h a href "http://localhost/entries" "Return to index"]
    
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

    # set form "
    # 	<label>Blog Title:</label>
    # 	<br>
    # 	<input type=\"text\" name=\"entry_title\" value=\"$entry_title\">
    # 	<br>
    # 	<label>Blog Content:</label>
    # 	<br>
    # 	[h textarea name entry_content style "width: 400px; height: 120px;" $entry_content]
    # 	<br>
    #     <input type=\"hidden\" name=\"_method\" value=\"PUT\">
    # 	<input type=\"submit\" name=\"submit\" value=\"Update\">
    # 	<br><br>
    # 	<a href=\"http://localhost/entries\">Return to index</a>
    # "

    set form ""
    append form [h label "Blog Title:"]
    append form [h input type text name entry_title value $entry_title]
    append form [h br]
    append form [h label "Blog Content:"]
    append form [h br]
    append form [h textarea name entry_content style "width: 400px; height: 120px;" $entry_content]
    append form [h br]
    append form [input type hidden name _method value PUT]
    append form [input type submit name submit value Update]
    append form [h br]
    append form [h br]
    append form [h a href "http://localhost/entries" "Return to index"]
    
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


