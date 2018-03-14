from django.contrib import admin
from .models import Page, PageData, RejectList, Url_list, Config

admin.site.register(Page)
admin.site.register(PageData)
admin.site.register(RejectList)
admin.site.register(Url_list)
admin.site.register(Config)
