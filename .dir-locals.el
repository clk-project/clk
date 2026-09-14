;;; Directory Local Variables            -*- no-byte-compile: t -*-
;;; For more information see (info "(emacs) Directory Variables")

((nil . ((konix/agent-shell-tool-blacklist-project . (("^\\./tangle\\.sh" . "./tangle-n-export.sh")
                                                      ("^./doc/use_cases/generate-index.sh$" . "this is done in a pre-commit hook")
                                                      ("^Edit tests/use_cases/" . "Never touch that file. It is tangled from ./doc/use_cases/")))
         (konix/agent-shell-tool-whitelist-project . (("^\\./custom-ids\\.sh" . "")
                                                      ("^\\./tangle-n-export\\.sh" . "")
                                                      ("^clk python -m pytest" . "")))
         (konix/agent-shell-mcp-project-servers . ("konix-emacs-code-review"
                                                   "konix-emacs-workspace"))))
 (org-mode . ((ispell-dictionary . "american")
              (org-id-link-to-org-use-id . nil)
              (org-babel-default-header-args:python . ((:preserve-indentation . t))))))
