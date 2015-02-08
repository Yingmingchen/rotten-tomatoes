## Rotten Tomatoes

This is a movies app displaying box office and top rental DVDs using the [Rotten Tomatoes API](http://developer.rottentomatoes.com/docs/read/JSON).

Time spent: `16 hours`

### Features

#### Required

- [x] User can view a list of movies. Poster images load asynchronously.
- [x] User can view movie details by tapping on a cell.
- [x] User sees loading state while waiting for the API.
- [x] User sees error message when there is a network error
- [x] User can pull to refresh the movie list.

#### Optional

- [x] All images in detail view fade in.
- [x] For the larger poster, load the low-res first and switch to high-res when complete.
- [x] Customize the highlight and selection effect of the cell.
- [x] Customize the navigation bar.
- [x] Add a tab bar for Box Office and DVD.
- [x] Add a search bar: pretty simple implementation of searching against the existing table view data. Dynamically update the view while typing.
- [x] Use pan gesture to drag the description scroll view up and down with bouncing effort and show/hide navigation bar.
- [x] Use pinch gesture to switch between table view and collection view (i.e., zoom in to switch to collection view and zoom out to switch back to table view). 

### Walkthrough
![Video Walkthrough](rottenTomatoesDemo.gif)

Credits
---------
* [Rotten Tomatoes API](http://developer.rottentomatoes.com/docs/read/JSON)
* [AFNetworking](https://github.com/AFNetworking/AFNetworking)
