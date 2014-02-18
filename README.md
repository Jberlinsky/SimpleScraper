= Simple Web Scraper

A simple web scraper that builds a sitemap of page links and static assets within a web site. This sitemap 
is then exported as a graphviz graph in whatever file format (png, jpg, etc.) is specified.

== Requirements

By default, one must have Redis installed and running. This is configurable via the parameters passed to 
Scraper.run:

  `Scraper.run('https://www.joingrouper.com/', storage: Anemone::Storage.MongoDB)`

== Use

  `Scraper.run(url)`

== Options

=== File Extensions

One can specify the file extension to output the sitemap to by passing the 'extension' option to Scraper::run:

  `Scraper.run(url, extension: 'png')`

The scraper outputs 'graph.jpg' by default.

=== URL Exclusions

An array of regular expressions can be passed to the scraper to exclude certain matching patterns. For example, 
to exclude groupergrams from being indexed, one might run:

  `Scraper.run(url, exclusions: [/groupergrams/])`

=== Storage Mechanisms

The underlying library utilized in the scraping process, Anemone, requires temporary storage to efficiently 
scrape the domain that it is passed. By default, Redis will be used, although MongoDB, TokyoCabinet, PStore and 
in-memory hashes are all valid options.

= Author

Jason Berlinsky (jason@jasonberlinsky.com)
