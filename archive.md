---
title: 归档文章
permalink: /archive/
---

# 归档文章

这里收录的是王垠在不同时间发布的历史文章。正文保留作者当时的表达，不代表本站观点，也未经本站事实核验。来源链接区分原始发布、网页存档和第三方存档；不同存档版本可能有修订，日期有疑问的条目另行标注。

如发现日期、来源、缺失链接或正文完整性问题，请[提交资料修正](https://github.com/yinwang-wiki/yinwang-wiki.github.io/issues/new)。维护原则见[编辑与归档政策]({{ '/EDITORIAL_POLICY.html' | relative_url }})。

{% assign topics = site.posts | map: "topic" | uniq | sort %}
{% for topic in topics %}
## {{ topic }}

{% assign topic_posts = site.posts | where: "topic", topic | sort: "date" | reverse %}
{% for post in topic_posts %}
- {{ post.original_date | date: "%Y-%m-%d" }}{% if post.date_uncertain %}（日期待考）{% endif %} · [{{ post.title }}]({{ post.url | relative_url }}){% if post.source_status == "documented" %} · [{% if post.source_kind == "mirror" %}第三方存档{% else %}来源{% endif %}]({{ post.source_url }}){% else %} · 来源待补{% endif %}
{% endfor %}

{% endfor %}
