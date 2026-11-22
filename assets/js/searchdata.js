---
layout: null
is_wiki_page: false
---
{% if site.search_engine == "js" %}
{% assign search_pages = site.posts | concat: site.html_pages | where_exp: "item", "item.sitemap != false" %}
var jsondata = [
  {% for item in search_pages %}
  {
    "title": {{ item.title | default: item.name | jsonify }},
    "category": {{ item.category | default: "" | jsonify }},
    "tags": {{ item.tags | join: ", " | jsonify }},
    "url": {{ item.url | relative_url | jsonify }},
    "date": {{ item.date | default: "" | jsonify }},
    "content": {{ item.content | jsonify }}
  }{% unless forloop.last %},{% endunless %}
  {% endfor %}
];

var sjs = SimpleJekyllSearch({
  searchInput: document.getElementById('search-input'),
  resultsContainer: document.getElementById('results-container'),
  json: jsondata,
  searchResultTemplate: '<li><a href="{url}" title="{desc}">{title}</a></li>',
  noResultsText: 'No results found',
  limit: 10,
  fuzzy: false,
  exclude: []
});
{% endif %}
