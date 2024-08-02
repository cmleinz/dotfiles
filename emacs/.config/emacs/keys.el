(use-package general
  :config
  (general-evil-setup t)
  (general-override-mode)

  ;; EViL bindings
  (general-define-key
   :states '(normal visual emacs)
   :keymaps 'override
   "U"  'evil-redo
   "C"  'evil-mc-make-cursor-move-next-line
   "%"  'mark-whole-buffer
   "_"  'expreg-expand
   "-"  'expreg-contract
   )

  (general-define-key
   :states '(normal visual emacs)
   :keymaps 'override
   :prefix "g"
   "a" 'evil-switch-to-windows-last-buffer
   "h" 'evil-beginning-of-line
   "l" 'evil-end-of-line
   "g" 'beginning-of-buffer
   "e" 'end-of-buffer
   "d" 'lsp-find-definition
   "r" 'lsp-find-references
   "s" 'avy-goto-char-timer
   )

  (general-define-key
   :states '(normal visual emacs)
   :keymaps '(dired-mode-map)
   "h" 'dired-up-directory
   "l" 'dired-find-file
   )


  (general-define-key
   :states '(normal visual emacs)
   :keymaps 'override
   :prefix "m"
   "s" 'evil-surround-region
   "r" 'evil-surround-change
   "d" 'evil-surround-delete
   )

  (general-define-key
   :states '(normal visual insert emacs)
   :keymaps 'override
   :prefix "SPC"
   :non-normal-prefix "C-SPC"
   "e"  'eat
   "/"  'evilnc-comment-or-uncomment-lines
   "x"  'execute-extended-command
   "d"  '(:ignore t :which-key "Diagnostics")
   "dd" 'flymake-show-buffer-diagnostics
   "dD" 'flymake-show-project-diagnostics
   "D"  'consult-flymake
   "s" 'consult-lsp-file-symbols
   "S" 'consult-lsp-symbols
   "l"  'consult-line
   "L"  'consult-line-multi

   "b"  '(:ignore t :which-key "Buffers")
   "br" '(rename-buffer :which-key "Rename buffer")
   "bw" '(toggle-truncate-lines :which-key "Truncate lines")
   "bb" '(consult-buffer :which-key "Switch buffer")
   "bn" '(evil-next-buffer :which-key "Next buffer")
   "bp" '(evil-prev-buffer :which-key "Previous buffer")
   "bk" '(kill-buffer :which-key "Kill buffer")

   "f"  '(:ignore t :which-key "Files")
   "fn" 'consult-notes
   "fd" 'dired-jump
   "fs" 'save-buffer
   "ff" 'find-file
   "fF" 'fzf
   "fr" 'consult-recent-file

   "w"  '(:ignore t :which-key "Window")
   "ws" '(evil-window-split :which-key "H Split")
   "wv" '(evil-window-vsplit :which-key "V Split")
   "wq" '(evil-window-delete :which-key "Delete window")
   "wo" '(delete-other-windows :which-key "Delete other windows")
   "wj" '(evil-window-down :which-key "Switch window down")
   "wk" '(evil-window-up :which-key "Switch window up")
   "wh" '(evil-window-left :which-key "Switch window left")
   "wl" '(evil-window-right :which-key "Switch window right")
   "wJ" '(evil-window-move-very-bottom :which-key "Move window down")
   "wK" '(evil-window-move-very-top :which-key "Move window up")
   "wH" '(evil-window-move-far-left :which-key "Move window left")
   "wL" '(evil-window-move-far-right :which-key "Move window right")

   ;; LSP Mode bindings
   "c"  '(:ignore t :which-key "Code")
   "cg" '(:ignore t :which-key "goto")
   "cC"  '(compile :which-key "compile")
   "cc"  '(recompile :which-key "recompile")
   "ci" 'lsp-ui-imenu
   "cgd" '(eglot-find-typeDefinition :which-key "Find Definition")
   "ce" '(flycheck-list-errors :which-key "List Errors")
   "ck" 'lsp-describe-thing-at-point
   "cK" 'lsp-ui-doc-glance
   "ca" 'lsp-execute-code-action
   "cr" 'lsp-rename
   "cs" 'consult-imenu
   "cS" 'consult-imenu-multi
   "cd" 'consult-lsp-diagnostics

   "p"  '(:ignore t :which-key "Project")
   "pe" 'eat-project
   "pc" 'project-compile
   "pi" 'consult-imenu-multi
   "pf" 'project-find-file
   "pF" 'fzf-find-file
   "pd" 'project-find-dir
   "pp" 'project-switch-project
   "pb" 'consult-project-buffer
   "pg" 'consult-ripgrep
   "pv" 'project-run-vterm
   "pt" 'consult-todo-project
   "p!" 'project-shell-command

   "h"  '(:ignore t :which-key "Helper")
   "ht" '(consult-theme :which-key "Load theme")
   "hk" '(describe-key :which-key "Describe key")
   "hv" '(describe-variable :which-key "Describe variable")
   "hf" '(describe-function :which-key "Describe function")

   "g"  '(:ignore t :which-key "Magit")
   "gg" '(magit-status :which-key "magit-status")
   "gf" '(magit-fetch :which-key "magit-fetch") 
   "gF" '(magit-fetch-all :which-key "magit-fetch-all") 
   "gb" '(magit-branch :which-key "magit-branch")
   "gp" '(magit-push-to-remote :which-key "magit-push")
   "gs" '(magit-stage-modified :which-key "magit-stage-modified")
   "gc" '(magit-commit :which-key "magit-commit")

   "r"  '(:ignore t :which-key "Configuration changes")
   "rr" '((lambda () (interactive) (load-file "~/.config/emacs/init.el")) :which-key "Reload init.el")
   "re" 'eval-buffer

   "!"  'shell-command

   "o"  '(:ignore t :which-key "Org")
   "oa" '(org-agenda :which-key "org-agenda")
   "oc" 'org-clock-in
   "oC" 'org-clock-out
   "oy" '(org-store-link :which-key "org-store-link")
   )

  ;; Org-mode specific bindings
  (general-define-key
   :states '(normal visual emacs)
   :keymaps '(org-mode-map)
   :prefix "SPC"
   "of" '(org-open-at-point :which-key "org-open-at-point")
   "oi" '(org-insert-link :which-key "org-insert-link")
   "t"  'org-todo
   )

  (general-define-key
   :states '(normal visual emacs)
   :keymaps '(magit-mode-map)
   "m" 'magit-merge
   "g" '(:ignore t :which-key "G")
   "gr" 'magit-refresh
   )
  )
