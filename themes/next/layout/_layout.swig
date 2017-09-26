<!doctype html> {% set html_class = 'theme-next ' + theme.scheme %} {% if theme.use_motion %} {% set html_class = html_class + ' use-motion' %} {% endif %}
<html class="{{ html_class | lower }}" lang="{{ config.language }}">

<head>
  {% include '_partials/head.swig' %}
  <title>{% block title %}{% endblock %}</title>
  <!-- canvas-nest背景 -->
  {% if theme.canvas_nest %}
  <script type="text/javascript" src="//cdn.bootcss.com/canvas-nest.js/1.0.0/canvas-nest.min.js"></script>
  {% endif %}
</head>

<body itemscope itemtype="http://schema.org/WebPage" lang="{{ page.lang || page.language || config.language }}">
  {% include '_scripts/third-party/analytics.swig' %} {% set container_class = "container one-collumn " %} {% if theme.sidebar.position %} {% set container_class = container_class + 'sidebar-position-' + theme.sidebar.position %} {% endif %}
  <div class="{{ container_class }} {% block page_class %}{% endblock %} ">
    <div class="headband"></div>
    <!-- fork me 代码段 -->
    <a target="_blank" href="https://github.com/YeomanYe"><img style="position: absolute; top: 0; right: 0; border: 0;z-index: 999" src="https://camo.githubusercontent.com/e7bbb0521b397edbd5fe43e7f760759336b5e05f/68747470733a2f2f73332e616d617a6f6e6177732e636f6d2f6769746875622f726962626f6e732f666f726b6d655f72696768745f677265656e5f3030373230302e706e67" alt="Fork me on GitHub" data-canonical-src="https://s3.amazonaws.com/github/ribbons/forkme_right_green_007200.png"></a>
    <header id="header" class="header" itemscope itemtype="http://schema.org/WPHeader">
      <div class="header-inner"> {%- include '_partials/header.swig' %} </div>
    </header>
    <main id="main" class="main">
      <div class="main-inner">
        <div class="content-wrap">
          <div id="content" class="content">
            {% block content %}{% endblock %}
          </div>
          {% include '_partials/duoshuo-hot-articles.swig' %} {% include '_partials/comments.swig' %}
        </div>
        {% if theme.sidebar.display !== 'remove' %} {% block sidebar %}{% endblock %} {% endif %}
      </div>
    </main>
    <footer id="footer" class="footer">
      <div class="footer-inner">
        {% include '_partials/footer.swig' %} {% include '_scripts/third-party/analytics/busuanzi-counter.swig' %} {% block footer %}{% endblock %}
      </div>
    </footer>
    {% if not theme.sidebar.b2t %}
    <div class="back-to-top">
      <i class="fa fa-arrow-up"></i> {% if theme.sidebar.scrollpercent %}
      <span id="scrollpercent"><span>0</span>%</span>
      {% endif %}
    </div>
    {% endif %}
  </div>
  {% include '_scripts/vendors.swig' %} {% include '_scripts/commons.swig' %} {% set scheme_script = '_scripts/schemes/' + theme.scheme | lower + '.swig' %} {% include scheme_script %} {% block script_extra %}{% endblock %} {% include '_scripts/boostrap.swig' %} {% include '_scripts/third-party/comments.swig' %} {% include '_scripts/third-party/tinysou.swig' %} {% include '_scripts/third-party/localsearch.swig' %} {% include '_scripts/third-party/mathjax.swig' %} {% include '_scripts/third-party/lean-analytics.swig' %} {% include '_scripts/baidu-push.swig' %} {% include '_components/algolia-search/assets.swig' %} {% if theme.exturl %} {% include '_scripts/third-party/exturl.swig' %} {% endif %}
</body>

</html>
