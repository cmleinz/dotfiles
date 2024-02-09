(use-package general
  :config
  (general-evil-setup t)
  (general-override-mode)

  ;; EViL bindings
  (general-define-key
   :keymaps 'prog-mode-map
   :states '(normal visual emacs)
   "U"  'evil-redo
   "C"  'evil-mc-make-cursor-move-next-line
   "%"  'mark-whole-buffer
   )

  (general-define-key
   :states '(normal visual emacs)
   :keymaps 'prog-mode-map
   :prefix "g"
   "a" 'evil-switch-to-windows-last-buffer
   "h" 'evil-beginning-of-line
   "l" 'evil-end-of-line
   "g" 'beginning-of-buffer
   "e" 'end-of-buffer
   "d" 'xref-find-definitions
   "r" 'xref-find-references
   )

  (general-define-key
   :states '(normal visual emacs)
   :keymaps 'prog-mode-map
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
   "e"  'eshell
   "v"  'vterm
   "/"  'evilnc-comment-or-uncomment-lines
   "x"  'execute-extended-command
   "d"  'flymake-show-buffer-diagnostics
   "D"  'flymake-show-project-diagnostics
   "s"  'consult-imenu
   "S"  'consult-imenu-multi
   "l"  'consult-line
   "L"  'consult-line-multi

   "b"  '(:ignore t :which-key "Buffers")
   "br" '(rename-buffer :which-key "Rename buffer")
   "bb" '(consult-buffer :which-key "Switch buffer")
   "bn" '(evil-next-buffer :which-key "Next buffer")
   "bp" '(evil-prev-buffer :which-key "Previous buffer")
   "bk" '(kill-buffer :which-key "Kill buffer")

   "f"  '(:ignore t :which-key "Files")
   "fn" 'consult-notes
   "fd" 'dired-jump
   "fs" 'save-buffer
   "ff" 'find-file
   "fr" 'consult-recent-file

   "w"  '(:ignore t :which-key "Windows")
   "ws" '(evil-window-split :which-key "Split window horizontally")
   "wv" '(evil-window-vsplit :which-key "Split window vertically")
   "wq" '(evil-window-delete :which-key "Delete window")
   "wo" '(delete-other-windows :which-key "Delete other window")
   "wj" '(evil-window-down :which-key "Switch to window down")
   "wk" '(evil-window-up :which-key "Switch to window up")
   "wh" '(evil-window-left :which-key "Switch to window left")
   "wl" '(evil-window-right :which-key "Switch to window right")
   "wJ" '(evil-window-move-very-bottom :which-key "Move window down")
   "wK" '(evil-window-move-very-top :which-key "Move window up")
   "wH" '(evil-window-move-far-left :which-key "Move window left")
   "wL" '(evil-window-move-far-right :which-key "Move window right")

   ;; LSP Mode bindings
   "c"  '(:ignore t :which-key "Code")
   "cg" '(:ignore t :which-key "goto")
   "cc"  '(recompile :which-key "recompile")
   "cgd" '(eglot-find-typeDefinition :which-key "Find Definition")
   "ci" '(consult-imenu :which-key "Imenu")
   "ce" '(flycheck-list-errors :which-key "List Errors")
   "ck" 'eldoc-doc-buffer
   "ca" 'eglot-code-actions
   "cr" 'eglot-rename

   "p"  '(:ignore t :which-key "Project")
   "pc" 'project-compile
   "pi" 'consult-imenu-multi
   "pf" 'project-find-file
   "pd" 'project-find-dir
   "pp" 'project-switch-project
   "pb" 'project-switch-to-buffer
   "pg" 'consult-ripgrep
   "pv" 'project-run-vterm

   "h"  '(:ignore t :which-key "Helper")
   "ht" '(consult-theme :which-key "Load theme")
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

   "o"  '(:ignore t :which-key "Org")
   "oa" '(org-agenda :which-key "org-agenda")
   "oy" '(org-store-link :which-key "org-store-link")
   )

  ;; Org-mode specific bindings
  (general-define-key
   :states '(normal visual emacs)
   :keymaps '(org-mode-map)
   :prefix "SPC"
   "of" '(org-open-at-point :which-key "org-open-at-point")
   "oi" '(org-insert-link :which-key "org-insert-link")
   )

  ;; Rust specific bindings
  (general-define-key
   :states '(normal visual emacs)
   :keymaps '(rustic-mode-map)
   :prefix "SPC"
   "cr" '(rustic-cargo-run :which-key "cargo run")
   "cb" '(rustic-cargo-build-arguments '("--release") :which-key "cargo build --release")
   "cc" '(rustic-cargo-build :which-key "cargo build")
   "cd" '(rustic-cargo-build-doc :which-key "cargo doc")
   "ch" '(lsp-rust-analyzer-inlay-hints-mode :which-key "toggle-inlay-hints") 
   )
  )
