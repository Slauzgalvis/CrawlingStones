from django.shortcuts import render
from app_main.models import Page, PageData


def index(request):
    pages = Page.objects.all()
    print(pages)
    context = {'all_pages': pages}
    return render(request, 'app_main/body.html', context)


def page_data(request, page_id):
    selected_page = Page.objects.get(pk=page_id)
    context = {'selected_page': selected_page, 'page_id':page_id}
    return render(request, 'app_main/display_snaps.html', context)


def get_index(request, snap_id, page_id):
    selected_snap = PageData.objects.get(pk=snap_id)
    selected_page = Page.objects.get(pk=page_id)
    path = 'fs/'+ selected_page.page_url + '/' + selected_snap.snapshots_date + '/index.html'
    context = {'selected_snap': selected_snap, 'selected_page': selected_page, 'path': path, 'page_id': page_id}
    return render(request, 'app_main/display_page.html', context)
