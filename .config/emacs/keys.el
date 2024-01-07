(defun neo-open-file-hide (full-path &optional arg)
  "Open a file node and hides tree."
  (neo-global--select-mru-window arg)
  (find-file full-path)
  (neotree-hide))

(defun neotree-enter-hide (&optional arg)
  "Enters file and hides neotree directly"
  (interactive "P")
  (neo-buffer--execute arg 'neo-open-file-hide 'neo-open-dir))

(use-package general
  :config
  (general-evil-setup t)
  (general-override-mode)
  (general-define-key
   :states '(normal visual insert emacs)
   :keymaps 'override
   :prefix "SPC"
   :non-normal-prefix "C-SPC"
   "o"  '(:ignore t :which-key "Org")
   "x"  '(execute-extended-command :which-key "M-x")
   "d"  '(neotree-toggle :which-key "neotree-toggle")
   "k"  '(lsp-ui-doc-glance :which-key "lsp-ui-doc-show")

   "b"  '(:ignore t :which-key "Buffers")
   "bb" '(consult-buffer :which-key "Switch buffer")
   "bn" '(evil-next-buffer :which-key "Next buffer")
   "bp" '(evil-prev-buffer :which-key "Previous buffer")
   "bk" '(kill-buffer :which-key "Kill buffer")

   "f"  '(:ignore t :which-key "Files")
   "fd" '(dired-jump :which-key "Open file folder")
   "fs" '(save-buffer :which-key "save-buffer")
   "ff" '(find-file :which-key "counsel-find-file")
   "fr" '(consult-recent-file :which-key "counsel-recentf")

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
   "cgd" '(lsp-find-definition :which-key "Find Definition")
   "cgr" '(lsp-find-references :which-key "Find References")
   "cgn" '(lsp-ui-find-next-reference :which-key "Find Next Reference")
   "cgN" '(lsp-ui-find-prev-reference :which-key "Find Previous Reference")
   "cgi" '(lsp-find-implementation :which-key "Find Implementation")
   "cgc" '(lsp-find-declaration :which-key "Find Declaration")
   "ci" '(consult-imenu :which-key "Imenu")
   "cs" '(lsp-ui-find-workspace-symbol :which-key "Find Workspace Symbol")
   "cf" '(lsp-ui-peek-find-definitions :which-key "Show function definition")
   "ce" '(flycheck-list-errors :which-key "List Errors")
   "ck" '(lsp-ui-doc-toggle :which-key "Show item docs")
   "cp" '(check-parens :which-key "Check parenthesis errors")
   "ca" '(lsp-execute-code-action :which-key "Perform code actions") 
   "cr" '(lsp-rename :which-key "Rename")
   "cx" '(consult-flymake :which-key "Flymake")
   "cX" '(lsp-treemacs-errors-list :which-key "Errors List")

   "p"  '(:ignore t :which-key "Project")
   "pr" '(projectile-run-project :which-key "Run Project")
   "pc" '(projectile-compile-project :which-key "Compile Project")
   "pi" '(consult-imenu-multi :which-key "Imenu Project")
   "pf" '(projectile-find-file :which-key "Find File")
   "pd" '(projectile-find-dir :which-key "Find Dir")
   "pp" '(projectile-switch-project :which-key "Switch Project")
   "pb" '(projectile-switch-to-buffer :which-key "Switch Buffer")
   "po" '(projectile-org-capture :which-key "Org Capture")
   "pg" '(consult-ripgrep :which-key "Ripgrep")

   "h"  '(:ignore t :which-key "Helper")
   "ht" '(consult-theme :which-key "Load theme")
   "hv" '(describe-variable :which-key "Describe variable")
   "hv" '(describe-function :which-key "Describe function")

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

   "oa" '(org-agenda :which-key "org-agenda")
   "oy" '(org-store-link :which-key "org-store-link")
   "op" '(neotree-projectile-action :which-key "neotree-toggle")

   "e"  '(eshell :which-key "Eshell")
   "v"  '(vterm :which-key "vterm")
   "/"  '(evilnc-comment-or-uncomment-lines :which-key "Un/Comment lines")
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
