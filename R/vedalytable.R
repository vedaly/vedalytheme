#' vedalytable
#'
#' Create a themed table for vedalytheme outputs.
#' - html_report: DT::datatable with download buttons + "copy column" dropdown/button
#' - pdf_report:  knitr::kable (static)
#' Unlike DT::datatable, rownames are set to FALSE by default
#'
#' @param x data.frame/tibble
#' @param caption optional caption
#' @param dt_buttons DT Buttons to enable (html)
#' @param copy_columns columns allowed in the copy dropdown (names or indices); default all
#' @param copy_label button label for copy
#' @param ... passed through to DT::datatable (html) or knitr::kable (pdf)
#' @export
vedalytable <- function(
    x,
    caption = NULL,
    digits = NULL,
    dt_buttons = c("copy", "csv", "excel", "pdf", "print"),
    copy_columns = NULL,
    copy_label = "Copy selected column",
    ...
) {
  x <- as.data.frame(x)

  # Identify whether rownames are explicitly turned on
  dots <- list(...)
  rownames_on <- dplyr::case_when(
    is.null(dots$rownames) ~ FALSE,
    is.character(dots$rownames) ~ TRUE,
    is.logical(dots$rownames) ~ isTRUE(dots$rownames),
    .default = FALSE
  )

  if (knitr::is_html_output()) {
    if (!requireNamespace("DT", quietly = TRUE)) stop("DT package is required for html_report.")
    if (!requireNamespace("htmltools", quietly = TRUE)) stop("htmltools package is required for html_report.")

    # Columns allowed to copy
    cols_dropdown_items <- names(x)
    if (!is.null(copy_columns)) {
      cols_idx <- ifelse(is.numeric(copy_columns), copy_columns, match(copy_columns, cols_dropdown_items))
      cols_idx <- cols_idx[!is.na(cols_idx) & cols_idx >= 1 & cols_idx <= ncol(x)]
      cols_dropdown_items <- cols_dropdown_items[cols_idx]
    }

    # if rownames are included, add it as a dropdown option to copy
    if (rownames_on) cols_dropdown_items <- c("__rownames__", cols_dropdown_items)

    # Element id for JS access
    tbl_id <- paste0("vedalytable_", as.integer(stats::runif(1, 1, 1e9)))

    # Build select + button (copies currently filtered/ordered values)
    select_id <- paste0(tbl_id, "_colsel")
    btn_id <- paste0(tbl_id, "_copybtn")

    ui <- htmltools::tags$div(
      style = "display:flex; gap:0.5rem; align-items:center; margin:0.25rem 0 0.5rem 0;",
      htmltools::tags$label(
        `for` = select_id,
        style = "margin:0; font-weight:600;",
        "Copy column:"
      ),
      htmltools::tags$select(
        id = select_id,
        style = "padding:0.25rem 0.4rem;",
        lapply(cols_dropdown_items, function(val) {
          lab <- ifelse(identical(val, "__rownames__"), "Row names", val)
          htmltools::tags$option(value = val, lab)
        })
      ),
      htmltools::tags$button(
        id = btn_id,
        type = "button",
        class = "oc-button",
        copy_label
      )
    )

    col_defs <- lapply(seq_along(names(x)), function(i) {
      list(targets = i - 1 + as.integer(rownames_on), name = names(x)[i])
    })
    # add rownames element if rownames are on
    if (rownames_on) {
      col_defs = c(
        list(list(targets = 0, name = "__rownames__")),
        col_defs
      )
    }

    buttons = lapply(dt_buttons, function(b) {
      list( extend = b, className = "oc-button")
    })

    dt <- DT::datatable(
      x,
      caption = caption,
      extensions = "Buttons",
      elementId = tbl_id,
      colnames = names(x),
      rownames = rownames_on,
      options = list(
        dom = "Bfrtip",
        buttons = buttons,
        columnDefs = col_defs
      ),
      ...
    )

    js <- htmltools::HTML(sprintf("
      (function(){
        function simplePopup(el, msg, ms){
          ms = ms || 2000;

          var div = document.createElement('div');
          div.id = 'vedaly-simple-popup';
          div.textContent = msg;

          // simple styling
          div.style.position = 'fixed';
          // div.style.right = '16px';
          // div.style.bottom = '16px';
          div.style.zIndex = '99999';
          div.style.padding = '10px 12px';
          div.style.borderRadius = '10px';
          div.style.boxShadow = '0 8px 24px rgba(0,0,0,0.18)';
          div.style.background = 'rgba(20,20,20,0.92)';
          div.style.color = '#fff';
          div.style.maxWidth = '360px';
          div.style.fontSize = '14px';

          document.body.appendChild(div);

          // position near the button (above it, centered)
          if (el && el.getBoundingClientRect) {
            var r = el.getBoundingClientRect();
            var top = Math.max(8, r.top - 10);     // a bit above
            var left = r.left + (r.width / 2);
            div.style.left = left + 'px';
            div.style.top = top + 'px';
            // IMPORTANT: ensure it doesn't stretch
            div.style.right = 'auto';
            div.style.bottom = 'auto';
            div.style.transform = 'translate(-50%%, -100%%)';
          } else {
            // fallback: bottom-right
            div.style.left = 'auto';
            div.style.top = 'auto';
            div.style.right = '16px';
            div.style.bottom = '16px';
            div.style.transform = 'none';
          }

          setTimeout(function(){
            div.style.transition = 'opacity 0.35s';
            div.style.opacity = '0';
            setTimeout(function(){
              if (div && div.parentNode) div.parentNode.removeChild(div);
            }, 400);
          }, ms);
        }

        function init(){
          var container = document.getElementById('%s');
          if(!container) return;

          if(!window.jQuery || !jQuery.fn || !jQuery.fn.dataTable) { setTimeout(init, 50); return; }

          var $table = jQuery('#%s table');
          if($table.length === 0) { setTimeout(init, 50); return; }

          var dt = $table.DataTable();

          var btn = document.getElementById('%s');
          var sel = document.getElementById('%s');
          if(!btn || !sel) return;

          btn.addEventListener('click', function(){
            var colName = sel.value;
            var idx = dt.column(colName + ':name').index();
            if(idx === undefined || idx === null){
              simplePopup(btn, 'Column not found: ' + colName);
              return;
            }
            var arr = dt.column(idx, {search:'applied', order:'applied'}).data().toArray();

            // Copy values (one per line)
            var vals = arr.join(String.fromCharCode(10));

            if (navigator.clipboard && navigator.clipboard.writeText) {
              navigator.clipboard.writeText(vals)
              .then(simplePopup(btn, 'Copied ' + arr.length + ' values', 1000))
              .catch(function(){
                alert('Clipboard blocked by browser permissions.');
              });
            } else {
              var ta = document.createElement('textarea');
              ta.value = vals;
              document.body.appendChild(ta);
              ta.select();
              try { document.execCommand('copy'); } catch(e) {}
              document.body.removeChild(ta);
              simplePopup(btn, 'Copied ' + arr.length + ' values', 1000);
            }
          });
        }
        init();
      })();
    ", tbl_id, tbl_id, btn_id, select_id))

    return(htmltools::tagList(ui, dt, htmltools::tags$script(js)))
  }

  # pdf_report (LaTeX) or anything non-HTML: static
  knitr::kable(x, caption = caption, digits = 2, row.names = rownames_on, ...)
}
