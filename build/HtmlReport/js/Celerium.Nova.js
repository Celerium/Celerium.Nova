/*
 * Celerium.Nova HTML report script (no dependencies)
 *
 *  - Sidebar toggle (collapses on desktops, slides over the page on phones)
 *  - Tables (.psn-datatable): sort by any column, search, page size, paging, & row count
 */
(function () {
    'use strict';

    /* ---------------------------------------------------------------------------------- */
    /* Sidebar                                                                            */
    /* ---------------------------------------------------------------------------------- */

    var PageBody = document.body;
    var IsSmallScreen = function () { return window.matchMedia('(max-width: 767.98px)').matches; };

    document.querySelectorAll('[data-psn-sidebar-toggle]').forEach(function (Button) {
        Button.addEventListener('click', function () {
            PageBody.classList.toggle(IsSmallScreen() ? 'psn-sidebar-open' : 'psn-sidebar-collapsed');
        });
    });

    document.querySelectorAll('.psn-sidebar-backdrop, .psn-sidebar .nav-link').forEach(function (Element) {
        Element.addEventListener('click', function () { PageBody.classList.remove('psn-sidebar-open'); });
    });

    /* ---------------------------------------------------------------------------------- */
    /* Tables                                                                             */
    /* ---------------------------------------------------------------------------------- */

    var Collator = new Intl.Collator(undefined, { numeric: true, sensitivity: 'base' });
    var NumberPattern = /^[-+]?(\d+\.?\d*|\.\d+)$/;
    var DatePattern = /^\d{4}-\d{2}-\d{2}([ T]\d{2}:\d{2}(:\d{2})?)?/;

    function CellValue(Row, Index) {
        var Cell = Row.cells[Index];
        if (!Cell) { return ''; }
        var Explicit = Cell.getAttribute('data-sort');
        return (Explicit !== null ? Explicit : Cell.textContent).trim();
    }

    function ColumnType(Rows, Index) {
        var IsNumber = true;
        var IsDate = true;
        var HasValue = false;

        for (var i = 0; i < Rows.length; i++) {
            var Value = CellValue(Rows[i], Index);
            if (Value === '') { continue; }
            HasValue = true;
            if (!NumberPattern.test(Value)) { IsNumber = false; }
            if (!DatePattern.test(Value) || isNaN(Date.parse(Value.replace(' ', 'T')))) { IsDate = false; }
            if (!IsNumber && !IsDate) { break; }
        }

        if (!HasValue) { return 'text'; }
        return IsNumber ? 'number' : (IsDate ? 'date' : 'text');
    }

    function Compare(A, B, Type) {
        // Empty values are always last when sorting ascending
        if (A === '' && B === '') { return 0; }
        if (A === '') { return 1; }
        if (B === '') { return -1; }

        if (Type === 'number') { return parseFloat(A) - parseFloat(B); }
        if (Type === 'date') { return Date.parse(A.replace(' ', 'T')) - Date.parse(B.replace(' ', 'T')); }
        return Collator.compare(A, B);
    }

    function InitTable(Container) {
        var Table = Container.querySelector('table.psn-table');
        var Body = Table.tBodies[0];
        var Headers = Array.prototype.slice.call(Table.tHead.rows[0].cells);
        var Search = Container.querySelector('.psn-table-search');
        var PageSizeSelect = Container.querySelector('.psn-page-size');
        var Info = Container.querySelector('.psn-table-info');
        var Pager = Container.querySelector('.psn-pager');

        var AllRows = Array.prototype.slice.call(Body.rows);
        var Filtered = AllRows.slice();
        var Sorted = { Index: -1, Direction: 1 };
        var PageSize = parseInt(Container.getAttribute('data-page-size'), 10) || 10;
        var Page = 1;

        var EmptyRow = document.createElement('tr');
        EmptyRow.className = 'psn-table-empty';
        EmptyRow.innerHTML = '<td colspan="' + Headers.length + '">No matching records found</td>';

        AllRows.forEach(function (Row, Index) { Row.setAttribute('data-psn-index', Index); });

        function Render() {
            var Total = Filtered.length;
            var Size = PageSize > 0 ? PageSize : Math.max(Total, 1);
            var Pages = Math.max(1, Math.ceil(Total / Size));
            if (Page > Pages) { Page = Pages; }

            var Start = (Page - 1) * Size;
            var End = Math.min(Start + Size, Total);

            while (Body.firstChild) { Body.removeChild(Body.firstChild); }

            if (Total === 0) { Body.appendChild(EmptyRow); }
            else { for (var i = Start; i < End; i++) { Body.appendChild(Filtered[i]); } }

            if (Info) {
                Info.textContent = Total === 0 ? 'Showing 0 entries' : 'Showing ' + (Start + 1) + ' to ' + End + ' of ' + Total + ' entries' +
                    (Total !== AllRows.length ? ' (filtered from ' + AllRows.length + ' total entries)' : '');
            }

            RenderPager(Pages);
        }

        function PageItem(Text, Target, Disabled, Active, Label) {
            var Item = document.createElement('li');
            Item.className = 'page-item' + (Disabled ? ' disabled' : '') + (Active ? ' active' : '');
            var Link = document.createElement('a');
            Link.className = 'page-link';
            Link.href = '#';
            Link.textContent = Text;
            if (Label) { Link.setAttribute('aria-label', Label); }
            if (Active) { Link.setAttribute('aria-current', 'page'); }
            Link.addEventListener('click', function (Event) {
                Event.preventDefault();
                if (!Disabled && Page !== Target) { Page = Target; Render(); }
            });
            Item.appendChild(Link);
            return Item;
        }

        function RenderPager(Pages) {
            if (!Pager) { return; }
            while (Pager.firstChild) { Pager.removeChild(Pager.firstChild); }
            if (Pages <= 1) { return; }

            Pager.appendChild(PageItem('\u00AB', 1, Page === 1, false, 'First page'));
            Pager.appendChild(PageItem('\u2039', Page - 1, Page === 1, false, 'Previous page'));

            var First = Math.max(1, Page - 2);
            var Last = Math.min(Pages, First + 4);
            First = Math.max(1, Last - 4);
            for (var i = First; i <= Last; i++) { Pager.appendChild(PageItem(String(i), i, false, i === Page)); }

            Pager.appendChild(PageItem('\u203A', Page + 1, Page === Pages, false, 'Next page'));
            Pager.appendChild(PageItem('\u00BB', Pages, Page === Pages, false, 'Last page'));
        }

        function Sort() {
            if (Sorted.Index < 0) {
                Filtered.sort(function (A, B) { return A.getAttribute('data-psn-index') - B.getAttribute('data-psn-index'); });
                return;
            }

            var Type = ColumnType(AllRows, Sorted.Index);
            Filtered.sort(function (A, B) {
                var Result = Compare(CellValue(A, Sorted.Index), CellValue(B, Sorted.Index), Type);
                if (Result === 0) { return A.getAttribute('data-psn-index') - B.getAttribute('data-psn-index'); }
                // Empty values stay last in both directions
                var AEmpty = CellValue(A, Sorted.Index) === '';
                var BEmpty = CellValue(B, Sorted.Index) === '';
                if (AEmpty || BEmpty) { return Result; }
                return Result * Sorted.Direction;
            });
        }

        function Filter() {
            var Terms = (Search ? Search.value : '').toLowerCase().split(/\s+/).filter(Boolean);
            Filtered = AllRows.filter(function (Row) {
                if (Terms.length === 0) { return true; }
                var Text = Row.textContent.toLowerCase();
                return Terms.every(function (Term) { return Text.indexOf(Term) !== -1; });
            });
            Sort();
            Page = 1;
            Render();
        }

        function SortBy(Index) {
            Sorted.Direction = (Sorted.Index === Index && Sorted.Direction === 1) ? -1 : 1;
            Sorted.Index = Index;

            Headers.forEach(function (Header, HeaderIndex) {
                if (HeaderIndex === Index) { Header.setAttribute('aria-sort', Sorted.Direction === 1 ? 'ascending' : 'descending'); }
                else { Header.removeAttribute('aria-sort'); }
            });

            Sort();
            Page = 1;
            Render();
        }

        Headers.forEach(function (Header, Index) {
            Header.setAttribute('tabindex', '0');
            Header.setAttribute('role', 'columnheader');
            Header.setAttribute('title', 'Click to sort');
            Header.addEventListener('click', function () { SortBy(Index); });
            Header.addEventListener('keydown', function (Event) {
                if (Event.key === 'Enter' || Event.key === ' ') { Event.preventDefault(); SortBy(Index); }
            });
        });

        if (Search) { Search.addEventListener('input', Filter); }

        if (PageSizeSelect) {
            PageSizeSelect.value = String(PageSize);
            if (PageSizeSelect.value !== String(PageSize)) { PageSizeSelect.selectedIndex = 0; PageSize = parseInt(PageSizeSelect.value, 10); }
            PageSizeSelect.addEventListener('change', function () {
                PageSize = parseInt(PageSizeSelect.value, 10);
                Page = 1;
                Render();
            });
        }

        Render();
    }

    document.querySelectorAll('.psn-datatable').forEach(InitTable);
})();
