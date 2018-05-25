
<div class="copyright" >
  {% set current = date(Date.now(), "YYYY") %}
  &copy; 
  {% if theme.since and theme.since != current %} 
	{{ theme.since }} - 
  {% endif %}
  <span itemprop="copyrightYear">{{ current }}</span>
  <span class="with-love">
    <i class="fa fa-{{ theme.authoricon }}"></i>
  </span>
  <span class="author" itemprop="copyrightHolder">{{ config.author }}
  
  &nbsp;&nbsp;|&nbsp;&nbsp;
  <script src="https://s4.cnzz.com/z_stat.php?id=1261194950&web_id=1261194950" language="JavaScript"></script>
  
  &nbsp;&nbsp;|&nbsp;&nbsp;<span><a href="/sitemap.xml">Google网站地图</a></span>
  &nbsp;&nbsp;|&nbsp;&nbsp;<span><a href="/baidusitemap.xml">百度网站地图</a></span>
  &nbsp;&nbsp;|&nbsp;&nbsp;<span>Hosted by <a href="https://pages.coding.me">Coding Pages</a></span>
  
  </span>
</div>

{% if theme.copyright %}
<div class="powered-by">
  {{ __('footer.powered', '<a class="theme-link" href="https://hexo.io">Hexo</a>') }}
</div>

<div class="theme-info">
  {{ __('footer.theme') }} -
  <a class="theme-link" href="https://github.com/iissnan/hexo-theme-next">
    NexT.{{ theme.scheme }}
  </a>
</div>
{% endif %}

&nbsp;&nbsp;|&nbsp;&nbsp;本站总点击 <span id="busuanzi_value_site_pv"></span> 次
&nbsp;&nbsp;|&nbsp;&nbsp;您是第 <span id="busuanzi_value_site_uv"></span> 位访客

<script async src="https://dn-lbstatics.qbox.me/busuanzi/2.3/busuanzi.pure.mini.js">
</script>