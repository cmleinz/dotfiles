(setq gc-cons-threshold (* 50 1000 1000))
(add-hook 'emacs-startup-hook
          (lambda ()
            (message "*** Emacs loaded in %s with %d garbage collections."
                     (format "%.2f seconds"
                             (float-time
                              (time-subtract after-init-time before-init-time)))
                     gcs-done)))

(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("melpa-stable" . "https://stable.melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
 (package-refresh-contents))

(require 'use-package)

(setq use-package-always-ensure t)

(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-i-jump nil)
  :config
  (evil-mode 1)
  (evil-set-undo-system 'undo-redo)
  (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)
  (define-key evil-normal-state-map (kbd "U") 'evil-redo)
  (define-key evil-insert-state-map (kbd "C-h") 'evil-delete-backward-char-and-join)

  ;; Use visual line motions even outside of visual-line-mode buffers
  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)

  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(save-place-mode 1)

(setq display-line-numbers-type 'relative)
(global-display-line-numbers-mode 1)

(setq scroll-step 1)
(setq scroll-margin 5)

(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))

(use-package dired
  :ensure nil
  :commands (dired dired-jump)
  :custom ((dired-listing-switches "-agho --group-directories-first"))
  :config
  (evil-collection-define-key 'normal 'dired-mode-map
    "h" 'dired-up-directory
    "l" 'dired-find-file))
(use-package all-the-icons-dired
  :hook (dired-mode . all-the-icons-dired-mode))

(use-package dashboard
  :ensure t
  :init
  (setq dashboard-set-footer nil)
  (setq dashboard-banner-logo-title nil)
  (setq dashboard-projects-switch-function 'counsel-projectile-switch-project-by-name)
  (setq dashboard-items '((recents . 5)
                          (projects . 5)
                          (agenda . 5)
                          ))
  :config
  (dashboard-setup-startup-hook))

(defun autoinsert-yas-expand()
  "Replace text in yasnippet template."
  (evil-insert-state)
  (yas-expand-snippet (buffer-string) (point-min) (point-max)))

(use-package autoinsert
  :init
  (setq auto-insert-query nil)
  (setq auto-insert-directory (locate-user-emacs-file "templates"))
  (add-hook 'find-file-hook 'auto-insert)
  (auto-insert-mode 1)

  :config
  (define-auto-insert "\\.org$" [ "default-org.org" autoinsert-yas-expand ])
  )

(use-package swiper
  :ensure t
  :bind ("C-s" . swiper))

(use-package counsel
  :bind (
         :map minibuffer-local-map
         ("C-r" . 'counsel-minibuffer-history)))

(use-package ivy
  :diminish
  :bind (
         :map ivy-minibuffer-map
         ("TAB" . ivy-alt-done)	
         ("C-l" . ivy-alt-done)
         ("C-j" . ivy-next-line)
         ("C-k" . ivy-previous-line)
         :map ivy-switch-buffer-map
         ("C-k" . ivy-previous-line)
         ("C-l" . ivy-done)
         ("C-d" . ivy-switch-buffer-kill)
         :map ivy-reverse-i-search-map
         ("C-k" . ivy-previous-line)
         ("C-d" . ivy-reverse-i-search-kill))
  :config
  (ivy-mode 1))

(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1)
  :custom (
           (doom-modeline-height 15)
           (doom-modeline-lsp t)
           (doom-modeline-minor-modes t)
           ))

(use-package minions
  :hook (doom-modeline-mode . minions-mode))

(use-package which-key
  :ensure t
  :config
  (setq which-key-idle-delay 0.1)
  (which-key-mode))

(use-package pdf-tools
  :magic ("%PDF" . pdf-view-mode))

(defun cl/org-mode-setup ()
  (visual-line-mode 1)
  (flyspell-mode 1))

(use-package org
  :hook (org-mode . cl/org-mode-setup)
  :config

  (use-package evil-org
      :ensure t
      :after (evil org)
      :config
      (add-hook 'org-mode-hook 'evil-org-mode)
      (add-hook 'evil-org-mode-hook
            (lambda ()
            (evil-org-set-key-theme '(navigation insert textobjects additional calendar todo))))
      (require 'evil-org-agenda)
      (evil-org-agenda-set-keys))

  (use-package org-bullets
    :after org
    :hook (org-mode . org-bullets-mode))

  (setq org-agenda-start-with-log-mode t)
  (setq org-log-done 'time)
  (setq org-log-into-drawer t)
  (setq org-startup-indented t)
  ;; Set Org-Mode TODO keywords
  (setq org-todo-keywords
        '((sequence "TODO(t)" "PROG(p)" "PROJ(j)" "SENT(s)" "|" "DONE(d)" "CANC(c)" "PASS(a)")))
  ;; Set Org-Mode TODO state colors
  (setq org-todo-keyword-faces
        '(("TODO" . "#ff5555") ("PROG" . "#ffb86c") ("PROJ" . "#8be9fd") ("SENT" . "#ff79c6")
          ("DONE" . "#50fa7b") ("CANC" . "#a4fcba") ("PASS" . "#44475a")))

  ;; Save Org buffers after refiling!
  (advice-add 'org-refile :after 'org-save-all-org-buffers))

(use-package org-transclusion
  :after org)

(use-package centaur-tabs
  :config
  (setq centaur-tabs-set-icons t
        centaur-tabs-show-navigation-buttons t
        centaur-tabs-height 32
        centaur-tabs-set-modified-marker t)
  (centaur-tabs-change-fonts "Fira Code Retina" 120))

(use-package company
  :ensure
  :custom
  (company-idle-delay 0.0) ;; how long to wait until popup
  ;; (company-begin-commands nil) ;; uncomment to disable popup
  :hook (prog-mode . company-mode)
  :bind
  (:map company-active-map
        ("<tab>" . company-complete-selection)
        ("C-n" . company-select-next)
        ("C-p" . company-select-previous)
        ("M-<" . company-select-first)
        ("M->" . company-select-last))
  :config
  (use-package company-jedi)
)

(add-hook 'prog-mode-hook 'display-fill-column-indicator-mode)
(setq-default fill-column 90)

(use-package flycheck
  :ensure t
  :init (global-flycheck-mode))

(use-package paren
  :config
  (set-face-attribute 'show-paren-match-expression nil :background "#363e4a")
  (show-paren-mode 1))

(use-package diff-hl
  :config
  (diff-hl-dired-mode t)
  (add-hook 'magit-pre-refresh-hook 'diff-hl-magit-pre-refresh)
  (add-hook 'magit-post-refresh-hook 'diff-hl-magit-post-refresh)
  :hook (prog-mode . diff-hl-mode))

(use-package lsp-mode
  :ensure t
  :commands lsp
  :hook (prog-mode . lsp-deferred)
  :custom
  (lsp-diagnostics-flycheck-default-level 'warning)
  (lsp-diagnostics-provider :none)
  (lsp-rust-analyzer-cargo-watch-command "clippy")
  ;;(lsp-eldoc-render-all t)
  (lsp-idle-delay 0.5)
  (lsp-rust-analyzer-server-display-inlay-hints t)
  (lsp-rust-analyzer-display-lifetime-elision-hints-enable "skip_trivial")
  (lsp-rust-analyzer-display-chaining-hints t)
  (lsp-rust-analyzer-display-lifetime-elision-hints-use-parameter-names t)
  (lsp-rust-analyzer-display-closure-return-type-hints t)
  (lsp-rust-analyzer-display-parameter-hints t)
  (lsp-rust-analyzer-display-reborrow-hints nil)
  :config
  (add-hook 'lsp-mode-hook 'lsp-ui-mode))

(use-package lsp-ui
  :ensure
  :commands lsp-ui-mode
  :custom
  (lsp-ui-peek-always-show t)
  ;; When peeking definitions it will look for them with lsp-peek, nice!
  (lsp-ui-peek-enable t)
  ;; I might remove this option, it's quite messy/distracting
  (lsp-ui-sideline-show-hover nil)
  (lsp-ui-sideline-show-diagnostics t)
  (lsp-ui-sideline-show-code-actions t)
  (lsp-ui-sideline--push-info nil)
  ;; Read docs with hover
  (lsp-ui-doc-enable t)
  ;; (lsp-ui-doc-delay 2)
  ;; (lsp-ui-doc-show-with-cursor t)
  (lsp-ui-doc-position 'at-point)
  ;; Show file directory when peeking definitions
  (lsp-ui-peek-show-directory t)
  ;; (define-key lsp-ui-doc-frame-mode-map (kbd "ESC") 'lsp-ui-doc-hide)
  :bind
  (:map lsp-mode-map
        ([remap xref-find-definitions] . lsp-ui-peek-find-definitions)
        ([remap xref-find-references] . lsp-ui-peek-find-references)))

(use-package lsp-ivy :commands lsp-ivy-workspace-symbol)

(use-package magit
  :init
  (message "Loading Magit!")
  :config
  (message "Loaded Magit!"))

(use-package evil-nerd-commenter
  :bind ("M-/" . evilnc-comment-or-uncomment-lines))

(use-package projectile
  :ensure t
  :init
  (projectile-mode +1)
  :bind (:map projectile-mode-map
              ("C-c p" . projectile-command-map)))

(use-package counsel-projectile)

(use-package rainbow-delimiters
  :hook
  (prog-mode . rainbow-delimiters-mode)
  (toml-mode . rainbow-delimiters-mode))

(use-package rainbow-mode
  :hook ((css-mode-hook . rainbow-mode)
         (html-mode-hook . rainbow-mode)
         (latex-mode-hook . rainbow-mode)
         (scss-mode-hook . rainbow-mode)))

(use-package ripgrep)

(use-package smartparens
  :hook (prog-mode . smartparens-mode)
        (toml-mode . smartparens-mode))

(use-package yasnippet-snippets)
(use-package yasnippet
  :ensure
  :config
  (setq yas-snippet-dirs
        '("~/.config/emacs/snippets/"))
  (yas-reload-all)
  (yas-global-mode)
  (add-hook 'prog-mode-hook 'yas-minor-mode)
  (add-hook 'text-mode-hook 'yas-minor-mode))

(use-package tree-sitter
  :config
  (use-package tree-sitter-langs)
  (global-tree-sitter-mode)
  (add-hook 'tree-sitter-after-on-hook #'tree-sitter-hl-mode))

(use-package vterm)

(use-package elpy
  :init (add-hook 'python-mode-hook #'elpy-enable)
  :config
  (setq elpy-rpc-python-command "python3")
  (setq python-shell-interpreter "python3")
  (add-hook 'elpy-mode-hook 'lsp))

(use-package blacken
  :init (add-hook 'elpy-mode-hook 'blacken-mode))

(defun cl/rustic-mode-hook ()
  (when buffer-file-name
    (setq-local buffer-save-without-query t)))

(use-package rustic
  :ensure
  :bind (:map rustic-mode-map
              ("M-j" . lsp-ui-imenu)
              ("M-?" . lsp-find-references)
              ("C-c C-c l" . flycheck-list-errors)
              ("C-c C-c a" . lsp-execute-code-action)
              ("C-c C-c r" . lsp-rename)
              ("C-c C-c q" . lsp-workspace-restart)
              ("C-c C-c Q" . lsp-workspace-shutdown)
              ("C-c C-c s" . lsp-rust-analyzer-status))
  :config
  (setq rustic-format-on-save t)
  (setq rustic-format-display-method 'ignore)
  (add-hook 'rustic-mode-hook 'cl/rustic-mode-hook)
  (add-hook 'rust-mode-hook #'tree-sitter-mode))



;; (set-face-attribute 'default nil :font "Fira Code Retina" :height 110)
(set-face-attribute 'default nil :font "Comic Code Ligatures" :height 110)

;; (use-package fira-code-mode
;;   :custom (fira-code-mode-disabled-ligatures '("x", ":"))
;;   :hook prog-mode)

(use-package all-the-icons
  :if (display-graphic-p))

(setq inhibit-startup-message t)

(menu-bar-mode -1)

(tool-bar-mode -1)

(scroll-bar-mode -1) ; Disable scrollbar

;; (global-hl-line-mode t)

(use-package autothemer
  :ensure t)

(add-to-list 'custom-theme-load-path "~/.config/emacs/booberry-theme/")
(load-theme 'booberry t)

(use-package doom-themes
  :ensure t
  :config
  ;; Global settings (defaults)
  (setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
        doom-themes-enable-italic t) ; if nil, italics is universally disabled

  ;; Enable flashing mode-line on errors
  (doom-themes-visual-bell-config)
  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config))

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

    "b"  '(:ignore t :which-key "Buffers")
    "bb" '(counsel-switch-buffer :which-key "Switch buffer")
    "bn" '(evil-next-buffer :which-key "Next buffer")
    "bN" '(evil-prev-buffer :which-key "Previous buffer")
    "bk" '(kill-buffer :which-key "Kill buffer")

    "f"  '(:ignore t :which-key "Files")
    "fd" '(dired-jump :which-key "Open file folder")
    "fs" '(save-buffer :which-key "save-buffer")
    "ff" '(counsel-find-file :which-key "counsel-find-file")
    "fr" '(counsel-recentf :which-key "counsel-recentf")

    "w"  '(:ignore t :which-key "Windows")
    "ws" '(evil-window-new :which-key "Split window horizontally")
    "wv" '(evil-window-vnew :which-key "Split window vertically")
    "wd" '(evil-window-delete :which-key "Delete window")
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
    "ci" '(counsel-imenu :which-key "Counsel Imenu")
    "cs" '(lsp-ui-find-workspace-symbol :which-key "Find Workspace Symbol")
    "cf" '(lsp-ui-peek-find-definitions :which-key "Show function definition")
    "ce" '(flycheck-list-errors :which-key "List Errors")
    "ck" '(lsp-ui-doc-toggle :which-key "Show item docs")
    "cp" '(check-parens :which-key "Check parenthesis errors")
    "ca" '(lsp-execute-code-action :which-key "Perform code actions") 
    "cr" '(lsp-rename :which-key "Rename")

    "p"  '(:ignore t :which-key "Project")
    "pr" '(projectile-run-project :which-key "Run Project")
    "pc" '(projectile-compile-project :which-key "Compile Project")
    "pf" '(counsel-projectile-find-file :which-key "Find File")
    "pd" '(counsel-projectile-find-dir :which-key "Find Dir")
    "pp" '(counsel-projectile-switch-project :which-key "Switch Project")
    "pb" '(counsel-projectile-switch-to-buffer :which-key "Switch Buffer")
    "po" '(counsel-projectile-org-capture :which-key "Org Capture")
    "pg" '(counsel-projectile-rg :which-key "Ripgrep")

    "h"  '(:ignore t :which-key "Helper")
    "ht" '(counsel-load-theme :which-key "Load theme")

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
    "re" '((lambda () (interactive) (find-file "~/.config/emacs/config.org")) :which-key "Open init.el")

    "oy" '(org-store-link :which-key "org-store-link")

    "e"  '(eshell :which-key "Eshell")
    "v"  '(vterm :which-key "vterm")
    "x"  '(counsel-M-x :which-key "M-x")
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
