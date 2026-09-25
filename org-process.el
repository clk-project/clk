;;; org-process.el --- Name, tangle and export the org files of clk -*- lexical-binding: t; -*-

;; org-process.sh loads this file and leaves behind it the org files to work
;; on.  The whole run happens in this one emacs: every heading gets a
;; CUSTOM_ID, the blocks are tangled, and the file is exported to markdown.

(defconst clk-org-root
  (file-name-directory (or load-file-name buffer-file-name))
  "The clk checkout this file lives in.")

(defconst clk-org-lisp-dir
  (expand-file-name ".tangle-deps/org/lisp" clk-org-root)
  "The lisp of the org-mode org-process.sh pinned.")

(defconst clk-org-gfm-dir
  (expand-file-name ".tangle-deps/ox-gfm" clk-org-root)
  "The ox-gfm org-process.sh pinned, the markdown the committed files use.")

;; Provide CL functions used in lp.org's elisp block
(unless (fboundp 'first) (defalias 'first #'car))
(unless (fboundp 'second) (defalias 'second #'cadr))

;; Stub out external dependency so lp.org's #+CALL: block works
(provide 'konix_org-run-session-blocks)

;; Don't prompt for code block evaluation
(setq org-confirm-babel-evaluate nil)
(setq org-src-preserve-indentation nil)

;; An underscore in a command or a variable name is not a subscript
(setq org-export-with-sub-superscripts nil)

;; Write drawers under their heading the way the org files already have them
(setq org-adapt-indentation t)

;; org.el loads org-loaddefs, which the org repository does not keep under
;; version control: write it the first time the clone is used
(let ((loaddefs (expand-file-name "org-loaddefs.el" clk-org-lisp-dir)))
  (when (and (file-directory-p clk-org-lisp-dir)
             (not (file-exists-p loaddefs)))
    (message "Writing %s..." loaddefs)
    (require 'loaddefs-gen nil t)
    (if (fboundp 'loaddefs-generate)
        (loaddefs-generate clk-org-lisp-dir loaddefs)
      (require 'autoload)
      (let ((generated-autoload-file loaddefs))
        (update-directory-autoloads clk-org-lisp-dir)))))

;; Load the pinned org-mode BEFORE anything else loads the built-in org.  This
;; must happen before (require 'ob-shell) since that transitively loads org.
(when (file-directory-p clk-org-lisp-dir)
  (push clk-org-lisp-dir load-path)
  (let ((contrib (expand-file-name "../contrib/lisp" clk-org-lisp-dir)))
    (when (file-directory-p contrib)
      (push contrib load-path)))
  (require 'org))

;; Load babel languages needed for tangling
(require 'ob-shell)

;; Match the project's default header args so tangled and exported output is
;; identical to what the authors get interactively
(setq org-babel-default-header-args
      '((:session . "none")
        (:results . "replace")
        (:exports . "both")
        (:eval . "no-export")
        (:cache . "no")
        (:noweb . "no")
        (:hlines . "no")
        (:comments . "yes")
        (:padline . "yes")
        (:tangle . "no")))

(defun clk-tangle--get-cached-result (name)
  "Extract the #+RESULTS content for block NAME from the current org buffer.
Handles `: value`, `#+begin_example` and `#+begin_export` formats."
  (save-match-data
  (save-excursion
    (goto-char (point-min))
    (when (re-search-forward
           (format "^[ \t]*#\\+RESULTS\\[.*\\]:[ \t]+%s[ \t]*$" (regexp-quote name))
           nil t)
      (forward-line 1)
      (let ((start (point))
            (lines nil))
        (cond
         ;; #+begin_example block — include trailing newline to match org-babel behavior
         ((looking-at "^[ \t]*#\\+begin_example")
          (forward-line 1)
          (while (not (looking-at "^[ \t]*#\\+end_example"))
            (let ((line (buffer-substring-no-properties
                         (line-beginning-position) (line-end-position))))
              (push line lines))
            (forward-line 1))
          (concat (mapconcat #'identity (nreverse lines) "\n") "\n"))
         ;; #+begin_export block — what a block asking for html leaves behind
         ((looking-at "^[ \t]*#\\+begin_export")
          (forward-line 1)
          (while (not (looking-at "^[ \t]*#\\+end_export"))
            (let ((line (buffer-substring-no-properties
                         (line-beginning-position) (line-end-position))))
              (push line lines))
            (forward-line 1))
          (concat (mapconcat #'identity (nreverse lines) "\n") "\n"))
         ;; : prefixed results
         (t
          (while (looking-at "^[ \t]*: \\(.*\\)$\\|^[ \t]*:$")
            (let ((line (or (match-string 1) "")))
              (push line lines))
            (forward-line 1))
          (mapconcat #'identity (nreverse lines) "\n"))))))))

(defconst clk-tangle--check-result-template "
%1$s_code () {
      <<%1$s>>
}

%1$s_expected () {
      local expected
      expected=\"$(cat<<\"EOEXPECTED\"
%2$s
EOEXPECTED
)\"
      # org says nil where the block said nothing
      test \"${expected}\" = nil || echo \"${expected}\"
}

echo 'Run %1$s'

{ %1$s_code || true ; } > \"${TMP}/code.txt\" 2>&1
if [ -n \"${CLK_RECORD_RESULTS-}\" ]
then
    mkdir -p \"${CLK_RECORD_RESULTS}/$(basename \"$0\" .sh)\"
    cp \"${TMP}/code.txt\" \"${CLK_RECORD_RESULTS}/$(basename \"$0\" .sh)/%1$s\"
else
    %1$s_expected > \"${TMP}/expected.txt\" 2>&1
    diff -uBw \"${TMP}/code.txt\" \"${TMP}/expected.txt\" || {
        echo \"Something went wrong when trying %1$s\"
        exit 1
    }
fi
"
  "The shell that check-result(NAME) becomes.
%1$s is the name of the block, %2$s the result it is expected to give.
With CLK_RECORD_RESULTS set, the run writes down what it got there instead
of comparing, in a directory named after the script, which is how the results
in the org files are refreshed.")

;; The check-result advice — transforms check-result(name) into shell test
;; functions during noweb expansion.  Uses inline cached results to avoid
;; re-executing blocks in batch mode (where the cache hash may not match).
(defun konix/org-babel-expand-noweb-references/add-check-result (orig-func info &optional parent-buffer context)
  (let ((code (second info)))
    (setq code
          (replace-regexp-in-string
           "^[ \t]*check-result(\\([a-zA-Z0-9_-]+\\))"
           (lambda (match)
             (let* ((name (match-string 1 match))
                    (result (clk-tangle--get-cached-result name)))
               (unless result
                 (error (concat "No cached #+RESULTS[...] for the block %s."
                                " Run the blocks before tangling")
                        name))
               (format clk-tangle--check-result-template name result)))
           code nil t))
    (funcall
     orig-func
     ;; info with the code replaced
     (cons (first info) (cons code (cddr info)))
     parent-buffer)))
(advice-add 'org-babel-expand-noweb-references :around 'konix/org-babel-expand-noweb-references/add-check-result)

(defun clk-org--slug (heading)
  "Turn HEADING into something that reads well in a URL."
  (let ((slug (downcase heading)))
    (setq slug (replace-regexp-in-string "[^a-z0-9]+" "-" slug))
    (setq slug (replace-regexp-in-string "\\`-+\\|-+\\'" "" slug))
    ;; a heading made of punctuation alone leaves nothing to name it with
    (if (string-empty-p slug) "section" slug)))

(defun clk-add-custom-ids ()
  "Add a CUSTOM_ID to every heading of the current buffer that has none.
Without one, org makes up a new anchor on each export, so the exported
markdown differs every time for no reason."
  (let ((taken (org-map-entries (lambda () (org-entry-get nil "CUSTOM_ID")))))
    (setq taken (delq nil taken))
    (org-map-entries
     (lambda ()
       (unless (org-entry-get nil "CUSTOM_ID")
         (let* ((base (clk-org--slug (org-get-heading t t t t)))
                (id base)
                (n 1))
           (while (member id taken)
             (setq n (1+ n))
             (setq id (format "%s-%d" base n)))
           (push id taken)
           (org-entry-put nil "CUSTOM_ID" id)))))))

(defun clk-org--aha (text)
  "Give back TEXT with the colours it holds turned into html."
  (with-temp-buffer
    (insert text)
    (shell-command-on-region (point-min) (point-max) "aha --no-header" nil t)
    (buffer-string)))

(defun clk-org--paint-results ()
  "Turn every result holding terminal colours into html, for the export.
What the org file keeps is the bytes the command gave, escapes and all.
Only the copy the export works on is changed, so that the markdown shows
the colours rather than the escapes."
  (save-excursion
    (goto-char (point-min))
    (while (re-search-forward "^[ \t]*#\\+RESULTS\\(\\[[^]]*\\]\\)?:.*$" nil t)
      (let ((start (progn (forward-line 1) (point)))
            (lines nil))
        (if (looking-at "^[ \t]*#\\+begin_example")
            (progn
              (forward-line 1)
              (while (and (not (eobp))
                          (not (looking-at "^[ \t]*#\\+end_example")))
                (push (buffer-substring-no-properties
                       (line-beginning-position) (line-end-position))
                      lines)
                (forward-line 1))
              (forward-line 1))
          (while (looking-at "^[ \t]*:\\(?: \\(.*\\)\\)?$")
            (push (or (match-string 1) "") lines)
            (forward-line 1)))
        (let ((body (mapconcat #'identity (nreverse lines) "\n")))
          (when (string-match-p "\e\\[" body)
            (delete-region start (point))
            (insert "#+begin_export html\n"
                    "<pre>\n"
                    (clk-org--aha (concat body "\n"))
                    "</pre>\n"
                    "#+end_export\n")))))))

(defvar clk-org-written nil
  "The files this run wrote, tangled and exported alike.")

(defun clk-org--mentions (regexp)
  "Say whether the current buffer holds REGEXP anywhere."
  (save-excursion
    (goto-char (point-min))
    (re-search-forward regexp nil t)))

(defun clk-org-process-file (file)
  "Name the headings of FILE, then tangle and export it as it asks for."
  (message "Processing %s..." file)
  (with-current-buffer (find-file-noselect file)
    (clk-add-custom-ids)
    (when (buffer-modified-p)
      (save-buffer))
    (when (clk-org--mentions ":tangle")
      (let ((tangled (org-babel-tangle)))
        (unless tangled
          (error "Tangling %s wrote nothing" file))
        (setq clk-org-written
              (append clk-org-written (mapcar #'expand-file-name tangled)))))
    (when (clk-org--mentions "^[ \t]*#\\+EXPORT_FILE_NAME:")
      (push clk-org-gfm-dir load-path)
      (require 'ox-gfm)
      (let ((exported
             ;; in the copy the export works on, where the includes already
             ;; brought their results in
             (let ((org-export-before-parsing-functions
                    (cons (lambda (_backend) (clk-org--paint-results))
                          org-export-before-parsing-functions)))
               (org-gfm-export-to-markdown))))
        (unless (and exported (file-exists-p exported))
          (error "Exporting %s wrote nothing" file))
        (setq clk-org-written
              (append clk-org-written (list (expand-file-name exported))))))
    (set-buffer-modified-p nil)
    (kill-buffer)))

;; What org-process.sh left on the command line is the org files to work on
(let ((files command-line-args-left)
      (written (getenv "CLK_ORG_WRITTEN")))
  (setq command-line-args-left nil)
  (dolist (file files)
    (clk-org-process-file file))
  (when written
    (with-temp-file written
      (dolist (f clk-org-written)
        (insert f "\n")))))

;;; org-process.el ends here
