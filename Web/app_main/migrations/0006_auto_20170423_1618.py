# -*- coding: utf-8 -*-
# Generated by Django 1.10.6 on 2017-04-23 13:18
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('app_main', '0005_auto_20170423_1448'),
    ]

    operations = [
        migrations.AlterField(
            model_name='pagepath',
            name='page_path',
            field=models.CharField(max_length=100),
        ),
    ]
