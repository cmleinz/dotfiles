(defvar elpaca-installer-version 0.6)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-repos-directory (expand-file-name "repos/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                              :ref nil
                              :files (:defaults "elpaca-test.el" (:exclude "extensions"))
                              :build (:not elpaca--activate-package)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-repos-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (< emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
        (if-let ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                 ((zerop (call-process "git" nil buffer t "clone"
                                       (plist-get order :repo) repo)))
                 ((zerop (call-process "git" nil buffer t "checkout"
                                       (or (plist-get order :ref) "--"))))
                 (emacs (concat invocation-directory invocation-name))
                 ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
                                       "--eval" "(byte-recompile-directory \".\" 0 'force)")))
                 ((require 'elpaca))
                 ((elpaca-generate-autoloads "elpaca" repo)))
            (progn (message "%s" (buffer-string)) (kill-buffer buffer))
          (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (load "./elpaca-autoloads")))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))

;; Install use-package support
(elpaca elpaca-use-package
  ;; Enable :elpaca use-package keyword.
  (elpaca-use-package-mode)
  ;; Assume :elpaca t unless otherwise specified.
  (setq elpaca-use-package-by-default t))

;; Block until current queue processed.
(elpaca-wait)

;; Basic configuration tweaks
; Set font
(set-face-attribute 'default nil :font "Comic Code Ligatures" :height 130)
; Disable menu bar
(menu-bar-mode -1)
; Disable tool bar
(tool-bar-mode -1)
; Disable scroll bar
(scroll-bar-mode -1)
; Use relative line numbers
(setq display-line-numbers-type 'relative)

(defun my-display-numbers-hook ()
  (display-line-numbers-mode 1)
  )
(add-hook 'prog-mode-hook 'my-display-numbers-hook)
(add-hook 'text-mode-hook 'my-display-numbers-hook)
; Auto pair brackets and parens
(electric-pair-mode 1)
; Set display fill indicator column
(setq display-fill-column-indicator-column 100)
(setq-default display-fill-column-indicator-column 100)
(add-hook 'prog-mode-hook 'display-fill-column-indicator-mode)
; Use scroll offset
(setq redisplay-dont-pause t
  scroll-margin 5
  scroll-step 1
  scroll-conservatively 10000
  scroll-preserve-screen-position 1)

;; Avoid making backup files
(setq make-backup-files nil)
;; Some weird dired issues with ls
(when (eq system-type 'darwin)
  (setq insert-directory-program "/opt/homebrew/bin/gls"))
;; Lock files cause issues on emacs-mac
(setq create-lockfiles nil)

(use-package diminish
  :ensure t
  :config
  (diminish 'auto-revert-mode)
  (diminish 'eldoc-mode))

(use-package exec-path-from-shell
  :ensure t
  :config
  (when (memq window-system '(mac ns x))
  (exec-path-from-shell-initialize)))

;; use-package with Elpaca:
(use-package dashboard
  :config
  (setq dashboard-set-footer nil)
  (setq dashboard-startup-banner 2)
  (setq dashboard-center-content t)
  (setq dashboard-projects-backend 'projectile)
  (setq dashboard-projects-switch-function 'counsel-projectile-switch-project-by-name)
  (add-hook 'elpaca-after-init-hook #'dashboard-insert-startupify-lists)
  (add-hook 'elpaca-after-init-hook #'dashboard-initialize)
  (add-to-list 'dashboard-items '(projects . 5) t)
  (dashboard-setup-startup-hook))

;; Themes
(use-package doom-themes
  :ensure t
  :config
  (load-theme 'doom-gruvbox))
(use-package modus-themes
  :ensure t
  :config
  (setq modus-themes-mode-line '(borderless))
  (setq modus-themes-bold-constructs t)
  (setq modus-themes-paren-match '(bold)))

;; evil-mode configuration
(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-vsplit-window-right t)
  (setq evil-split-window-below t)
  (evil-mode)
  :config
  (evil-set-undo-system 'undo-redo)
  (define-key evil-normal-state-map (kbd "U") 'evil-redo)
  (define-key evil-normal-state-map (kbd "gh") 'evil-beginning-of-line)
  (define-key evil-normal-state-map (kbd "gl") 'evil-end-of-line)
  (define-key evil-normal-state-map (kbd "ga") 'evil-switch-to-windows-last-buffer)
  (define-key evil-normal-state-map (kbd "ge") 'end-of-buffer))

;; Additional evil-mode bindings
(use-package evil-collection
  :diminish evil-collection-unimpaired-mode
  :after evil
  :config
  (evil-collection-init))

(use-package which-key
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 0.5)
  (which-key-mode))

(use-package doom-modeline
  :after all-the-icons
  :init
  (doom-modeline-mode)
  :config
  (setq doom-modeline-height 15)
  (setq doom-modeline-lsp t)
  (setq doom-modeline-minor-modes t))

;; Add evil-based directory navigation to dired
(use-package dired
  :elpaca nil
  :ensure nil
  :commands (dired dired-jump)
  :custom ((dired-listing-switches "-agho --group-directories-first"))
  :config
  (evil-collection-define-key 'normal 'dired-mode-map
    "h" 'dired-up-directory
    "l" 'dired-find-file))

;; Use all the Icons
(use-package all-the-icons
  :if (display-graphic-p)
  :commands all-the-icons-install-fonts
  :init (unless (find-font (font-spec :name "all-the-icons"))
	  (all-the-icons-install-fonts t)))


;; Include fun icons in dired-mode
(use-package all-the-icons-dired
  :diminish all-the-icons-dired-mode
  :hook
  (dired-mode . all-the-icons-dired-mode))

;; Ivy for autocompletion
(use-package ivy
  :diminish
  :config
  (ivy-mode))

;; Counsel for better versions of native emacs commands
(use-package counsel)
(use-package counsel-projectile
  :after counsel
  :after projectile)

;; Swiper for better search
(use-package swiper)

;; Treemacs integration
(use-package hydra
  :diminish)
(use-package treemacs
  :after hydra)
(use-package lsp-treemacs
  :after treemacs
  :config
  (lsp-treemacs-sync-mode))

;; Neotree for navigation in a project
(use-package neotree
  :config
  (setq neo-theme (if (display-graphic-p) 'icons 'arrow))
  (setq projectile-switch-project-action 'neotree-projectile-action))

(use-package org-bullets
  :after org)

(use-package org
  :hook
  (org-mode . visual-line-mode)
  (org-mode . flyspell-mode)
  (org-mode . org-bullets-mode)
  (org-mode . org-indent-mode)
  :config
  (setq org-todo-keywords
        '((sequence "TODO(t)" "PROG(p)" "PROJ(j)" "SENT(s)" "|" "DONE(d)" "CANC(c)" "PASS(a)")))
  (setq org-todo-keyword-faces
        '(("TODO" . "#ff5555") ("PROG" . "#ffb86c") ("PROJ" . "#8be9fd") ("SENT" . "#ff79c6")
          ("DONE" . "#50fa7b") ("CANC" . "#a4fcba") ("PASS" . "#44475a")))
  ;; Add these files to the agenda
  (setq org-agenda-files '("~/org/agenda"))
  ;; Save Org buffers after refiling!
  (advice-add 'org-refile :after 'org-save-all-org-buffers))

;; Spotify playback
(use-package smudge
  :bind-keymap ("C-c ." . smudge-command-map)
  :config
  (global-smudge-remote-mode 1)
  (setq smudge-oauth2-client-id "4e833643f65540e78869f1f689b1590e")
  (setq smudge-oauth2-client-secret "bdf6c29920184600b95fb3a138272bbb")
  (setq smudge-oauth2-callback-port "8088"))

;; Packages for programming

(use-package tree-sitter
  :diminish tree-sitter-mode
  :config
  (add-hook 'tree-sitter-after-on-hook #'tree-sitter-hl-mode)
  :hook
  (prog-mode . tree-sitter-mode))

(use-package tree-sitter-langs
  :after tree-sitter)

(use-package lsp-mode
  :diminish lsp-lens-mode
  :ensure t
  :commands lsp
  :hook
  (prog-mode . lsp-deferred)
  :custom
  (lsp-diagnostics-flycheck-default-level 'warning)
  (lsp-rust-analyzer-cargo-watch-command "clippy")
  (lsp-idle-delay 0.5)
  (lsp-rust-analyzer-display-chaining-hints t)
  (lsp-rust-analyzer-display-lifetime-elision-hints-use-parameter-names t)
  (lsp-rust-analyzer-display-closure-return-type-hints t)
  (lsp-rust-analyzer-display-parameter-hints t)
  (lsp-rust-analyzer-display-reborrow-hints nil))

(use-package lsp-ui
  :after lsp-mode
  :ensure
  :commands lsp-ui-mode
  :custom
  (lsp-ui-peek-always-show t)
  ;; When peeking definitions it will look for them with lsp-peek, nice!
  (lsp-ui-peek-enable t)
  ;; I might remove this option, it's quite messy/distracting
  (lsp-ui-sideline-show-hover nil)
  (lsp-ui-sideline-show-diagnostics t)
  (lsp-ui-sideline--push-info nil)
  ;; (lsp-ui-doc-show-with-cursor t)
  (lsp-ui-doc-position 'at-point)
  ;; Show file directory when peeking definitions
  (lsp-ui-peek-show-directory t)
  :hook
  (lsp-mode . lsp-ui-mode)
  :bind
  (:map lsp-mode-map
        ([remap xref-find-definitions] . lsp-ui-peek-find-definitions)
        ([remap xref-find-references] . lsp-ui-peek-find-references)))


;; Templating system
(use-package yasnippet
  :diminish yas-minor-mode
  :ensure
  :config
  (setq yas-snippet-dirs
        '("~/.config/emacs/snippets/"))
  (yas-reload-all)
  :hook
  (prog-mode . yas-minor-mode))

;; Common templates
(use-package yasnippet-snippets)

;; Flycheck checker
(use-package flycheck
  :diminish flycheck-mode
  :hook
  (prog-mode . flycheck-mode))

;; Highlight diffs in gutter
(use-package diff-hl
  :config
  (diff-hl-dired-mode t)
  (add-hook 'magit-pre-refresh-hook 'diff-hl-magit-pre-refresh)
  (add-hook 'magit-post-refresh-hook 'diff-hl-magit-post-refresh)
  :hook (prog-mode . diff-hl-mode))

;; Project managment
(use-package projectile
  :diminish
  :config
  (setq projectile-completion-system 'ivy)
  (setq projectile-indexing-method 'alien)
  (setq projectile-enable-caching t)
  (projectile-mode))

;; Vterm
(use-package vterm
  :config
  (setq vterm-shell "~/.cargo/bin/nu"))

;; Testing Eat
(use-package eat
  :ensure t)

;; Search via ripgrep
(use-package ripgrep)

(use-package seq
  :elpaca nil)

;; Magit for obvious reasons
(use-package magit
  :after seq
  :config
  (setq magit-show-long-lines-warning nil))

;; Code completion
(use-package company
  :diminish
  :config
  (setq company-idle-delay 0.2) ;; how long to wait until popup
  :hook
  (prog-mode . company-mode))

;; Java integration
(use-package lsp-java)

;; Dockerfile integration
(use-package dockerfile-mode)

;; May switch to rust mode
(use-package rustic
  :config
  (setq rustic-format-on-save t)
  (setq rustic-format-display-method 'ignore))

(load "~/.config/emacs/keys.el")

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("e3daa8f18440301f3e54f2093fe15f4fe951986a8628e98dcd781efbec7a46f2"
     "88267200889975d801f6c667128301af0bc183f3450c4b86138bfb23e8a78fb1"
     "0340489fa0ccbfa05661bc5c8c19ee0ff95ab1d727e4cc28089b282d30df8fc8"
     default)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

