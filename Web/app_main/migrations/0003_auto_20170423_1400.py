# -*- coding: utf-8 -*-
# Generated by Django 1.10.6 on 2017-04-23 11:00
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('app_main', '0002_auto_20170423_1328'),
    ]

    operations = [
        migrations.AlterField(
            model_name='pagepath',
            name='page_path',
            field=models.FilePathField(path='/fs/<django.db.models.query_utils.DeferredAttribute object at 0x00000161DA818710><django.db.models.query_utils.DeferredAttribute object at 0x00000161DA818AC8>'),
        ),
    ]
