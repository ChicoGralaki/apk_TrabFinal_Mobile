const int pageSize = 12;

int visibleItemCount(int total, {int current = pageSize}) =>
    total < current ? total : current;

int nextVisibleItemCount(int total, {int current = pageSize}) =>
    (current + pageSize) < total ? current + pageSize : total;
