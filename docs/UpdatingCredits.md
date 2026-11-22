# Updating Credits

These instructions cover updating the credits / attribution, both in the repo and application.

Credits are parsed automatically from the `ATTRIBUTION.md` file included with the template.

## Steps

1.  Open `ATTRIBUTION.md` in a text or markdown editor.
2.  Update the file with the project's credits. Refer to [Format Examples](#format-examples).
3.  Save the changes and close the file.
4.  Open `credits_label.tscn`.
5.  Check the `CreditsLabel` has updated with the text.
    1.  Optionally, disable `Auto Update` and customize the text.
6.  Save the scene (even if it shows no changes).

### Alternative
Optionally, `*.md` can be included for export in the _Export_ window's `Resources` tab, and steps 4-6 can be skipped, as `credits_label.tscn` will continue to update from `ATTRIBUTION.md` when exported.

## Format Examples
### Collaborators

> ### Role
> Contributor name  
> [Contributor name w/ link]()  

### Tools or Sourced Assets
> ### [Asset Type]
> #### Tool Name/Asset Name/Use Case
> Author: [Name]()  
> Source: [Domain : webpage.html]()  
> License: [License]()