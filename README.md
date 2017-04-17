# hydra-import-scripts

## Example eexport file

```
---
  project_name: wvcp
  time_stamp: 1490476034
  # Export Type can be
  # 1. update : metadata for all objects, but not all digital items
  # 1. update_full : both metadata and digital items for all objects
  # 1. full : Same as update_full, but we assume that there is no data loaded
  #           This would be for an intial load
  # 1. partial : metadata update for some items and/or some digital objects
  export_type: partial
  digital_items_count: 357
  record_count: 357
  # a yaml collection of email addresses to contact on success or failure
  contact_emails:
    - email1@mail.wvu.edu
    - email2@mail.wvu.edu
    - email3@mail.wvu.edu
```
