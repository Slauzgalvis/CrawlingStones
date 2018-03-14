from django.db import models


class Page(models.Model):
    page_name = models.CharField(max_length=100)
    page_url = models.CharField(max_length=100)

    class Meta:
        managed = False
        db_table = 'Page'
	ordering = ['page_name']

    def __str__(self):
        return self.page_name


class PageData(models.Model):
    selected_page = models.ForeignKey(Page, on_delete=models.CASCADE)
    snapshots_date = models.CharField(max_length=100)


    class Meta:
        managed = False
        db_table = 'PageData'

    def __str__(self):
        return '%s: %s' % (self.selected_page, self.snapshots_date)

class Url_list(models.Model):
        page_url = models.CharField(max_length=100)

        class Meta:
            managed = False
            db_table = 'Url_list'

        def __str__(self):
            return self.page_url

class RejectList(models.Model):
        page_url = models.CharField(max_length=100)
        extension_list = models.CharField(max_length=1000)

        class Meta:
            managed = False
            db_table = 'RejectList'

        def __str__(self):
            return self.page_url

class Config(models.Model):
    percentage_limit = models.IntegerField()
    line_limit = models.IntegerField()
    path = models.CharField(max_length=1000)

    class Meta:
        verbose_name = 'Checking configuration'
        managed = False
        db_table = 'Config'

    def __str__(self):
        return "Config settings"
