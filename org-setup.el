;;; org-setup.el --- The org clk tangles, exports and names headings with -*- lexical-binding: t; -*-

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

;; Load pinned org-mode from .tangle-deps BEFORE anything else loads the
;; built-in org.  This must happen before (require 'ob-shell) since that
;; transitively loads org.
(let ((org-lisp-dir
       (expand-file-name ".tangle-deps/org/lisp"
                         (file-name-directory (or load-file-name buffer-file-name)))))
  (when (file-directory-p org-lisp-dir)
    (push org-lisp-dir load-path)
    (let ((contrib (expand-file-name "../contrib/lisp" org-lisp-dir)))
      (when (file-directory-p contrib)
        (push contrib load-path)))
    ;; Force load of pinned org (unload built-in if already loaded)
    (require 'org)))

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
Handles both `: value` and `#+begin_example...#+end_example` formats."
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
         ;; : prefixed results
         (t
          (while (looking-at "^[ \t]*: \\(.*\\)$\\|^[ \t]*:$")
            (let ((line (or (match-string 1) "")))
              (push line lines))
            (forward-line 1))
          (mapconcat #'identity (nreverse lines) "\n"))))))))

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
               (concat
                "\n" name "_code () {\n"
                "      <<" name ">>\n"
                "}\n"
                "\n" name "_expected () {\n"
                "      cat<<\"EOEXPECTED\"\n"
                result "\n"
                "EOEXPECTED\n"
                "}\n"
                "\necho 'Run " name "'\n"
                "\n{ " name "_code || true ; } > \"${TMP}/code.txt\" 2>&1\n"
                name "_expected > \"${TMP}/expected.txt\" 2>&1\n"
                "diff -uBw \"${TMP}/code.txt\" \"${TMP}/expected.txt\" || {\n"
                "echo \"Something went wrong when trying " name "\"\n"
                "exit 1\n"
                "}\n")))
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

;;; org-setup.el ends here
