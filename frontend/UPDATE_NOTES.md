# Update notes – requested UI changes

- Profile photos now upload to the backend and are stored in the `staff` / `student` BLOB columns. The signed-in user's photo is loaded when entering the portal.
- The three change-password fields now have visibility toggles.
- Reader catalogue keeps its existing card layout and displays up to six books per page with Previous / Next controls.
- Search now sits above a category dropdown; selecting a category filters the visible books. `Recommended for You` currently preserves the existing general catalogue selection because the project does not currently expose a recommendation-ranking service.
- LMS Settings > Library Information has an Upload Logo action. The logo is read from `library_settings.library_logo` and shown in the landing header and signed-in top bar.


## Inventory, staff, settings, and notifications update

- Inventory search remains available above the inventory area; the inventory list now displays 10 book records per page with Previous/Next controls.
- Inventory columns are fitted to the available page width so a horizontal scrollbar is not required.
- Staff directory now displays 10 staff accounts per page with Previous/Next controls, and its table is fitted to the directory container.
- Librarian notifications are restricted to the most recent 7 days and paginated 10 per page.
- LMS settings now include School Email and School Location. These values are loaded from and saved to the backend and are used in the landing-page Contact Us section.
