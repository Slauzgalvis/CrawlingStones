# -*- coding: utf-8 -*-
# Generated by Django 1.10 on 2017-05-03 21:07
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('app_main', '0007_auto_20170423_1637'),
    ]

    operations = [
        migrations.AlterModelOptions(
            name='pagedata',
            options={'ordering': ['snapshots_date']},
        ),
        migrations.AlterField(
            model_name='pagedata',
            name='snapshots_date',
            field=models.DateTimeField(),
        ),
    ]
