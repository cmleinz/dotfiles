;; Minimize garbage collection during startup
(setq gc-cons-threshold most-positive-fixnum)

;; Specify specific custom-file location to avoid flooding init.el
(setq custom-file "~/.config/emacs/custom.el")
(load custom-file t)

;; Lower threshold back to 8 MiB (default is 800kB)
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (expt 2 23))))
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
  ;; Enable :ensure use-package keyword.
  (elpaca-use-package-mode)
  ;; Assume :ensure t unless otherwise specified.
  (setq elpaca-use-package-by-default t))

;; Block until current queue processed.
(elpaca-wait)

(setq user-full-name "Caleb Leinz"
      user-mail-address "caleb@leinz.io")

;; Set recentf mode
(recentf-mode 1)

;; Basic configuration tweaks
;; Set font
(if (eq system-type 'darwin)
    (set-face-attribute 'default nil :font "ComicShannsMono Nerd Font Mono" :height 160)
  (set-face-attribute 'default nil :font "ComicShannsMono Nerd Font Mono" :height 120)
  )

;; Disable menu bar
(menu-bar-mode -1)

;; Disable tool bar
(tool-bar-mode -1)

;; Disable scroll bar
(setq-default cursor-type 'bar) 
(scroll-bar-mode -1)

;; Use relative line numbers
(setq display-line-numbers-type 'relative)

(global-display-line-numbers-mode 1)

(defun my-prog-mode-hook ()
  (setq truncate-lines t)
  (display-fill-column-indicator-mode 1))

(add-hook 'prog-mode-hook 'my-prog-mode-hook)

(electric-pair-mode 1)
(electric-indent-mode 1)

(setq display-buffer-alist
      '(
	((or ((derived-mode . flymake-diagnostics-buffer-mode)
	      (derived-mode . flymake-project-diagnostics-mode)
	      (derived-mode . compilation-mode)) )
	 ;; List of display functions
	 (display-buffer-reuse-window
	  display-buffer-at-bottom)
	 ;; Parameters
	 (window-height . 15)
	 (dedicated . t)
	 (body-function . select-window)
	 )

	("\\*eldoc*"
	 (display-buffer-reuse-window
	  display-buffer-at-bottom)
	 (window-height . fit-window-to-buffer)
	 (dedicated . t)
	 (body-function . select-window)
	 )

	("\\*lsp-help*"
	 (display-buffer-reuse-window
	  display-buffer-at-bottom)
	 (window-height . fit-window-to-buffer)
	 (dedicated . t)
	 (body-function . select-window)
	 )
	)
      )

(use-package transient
  :ensure t)

;; Change error level to errors. Warnings are so noisy and there doesn't seem to be a way to stop the
;; buffer from appearing
(setq warning-minimum-level :error)

;; Use scroll offset
(pixel-scroll-precision-mode 1)
(setq scroll-margin 5
      scroll-step 1
      scroll-conservatively 10000
      scroll-preserve-screen-position 1)

;; Avoid making backup files
(setq make-backup-files nil)

;; Lock files cause issues on emacs-mac
(setq create-lockfiles nil)

;; Standardize autosave files to common directory
(setq auto-save-file-name-transforms
      '((".*" "~/.config/emacs/auto-save-list/" t))
      backup-directory-alist
      '((".*", "~/.config/emacs/backups")))

;; Some weird dired issues with ls
(when (eq system-type 'darwin)
  (setq insert-directory-program "/opt/homebrew/bin/gls"))

(use-package dashboard
  :ensure t
  :config
  (setq dashboard-banner-logo-title nil)
  (setq dashboard-center-content t)
  (setq dashboard-startup-banner 2)
  (setq dashboard-items '((projects . 5)
                          (recents . 5)
                          (bookmarks . 5)))
  (setq dashboard-display-icons-p t)     ; display icons on both GUI and terminal
  (setq dashboard-icon-type 'nerd-icons) ; use `nerd-icons' package
  (add-hook 'elpaca-after-init-hook #'dashboard-insert-startupify-lists)
  (add-hook 'elpaca-after-init-hook #'dashboard-initialize)
  (dashboard-setup-startup-hook))

(use-package ef-themes
  :config
  (load-theme 'ef-autumn t))

(use-package doom-modeline
  :ensure t
  :init
  (doom-modeline-mode 1)
  (display-time-mode t)
  :config
  (setq doom-modeline-project-detection 'auto)
  (setq doom-modeline-icon t)
  (setq doom-modeline-analogue-clock nil)
  (setq doom-modeline-lsp-icon t)
  (setq doom-modeline-modal t)
  (setq doom-modeline-modal-modern-icon t))

(use-package nerd-icons
  :config
  (setq nerd-icons-scale-factor 1.1)
  (setq nerd-icons-font-family "ComicShannsMono Nerd Font Mono"))

;; evil-mode configuration
(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-vsplit-window-right t)
  (setq evil-split-window-below t)
  (evil-mode)
  :config
  (setq evil-auto-indent t)
  (define-key evil-normal-state-map (kbd "C-u") 'evil-scroll-up)
  (evil-set-undo-system 'undo-redo))

(use-package evil-nerd-commenter)

;; Additional evil-mode bindings
(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

;; Evil mode multi-cursor support
(use-package evil-mc
  :init
  (global-evil-mc-mode 1)
  :config
  (setq evil-mc-mode-line-text-cursor-color t))

;; Evil surround
(use-package evil-surround
  :ensure t
  :config
  (global-evil-surround-mode 1))

(use-package which-key
  :config
  (setq which-key-idle-delay 0.5)
  (which-key-mode))

;; Visual undo tree
(use-package vundo)

;; Vertico for minibuffer magic!
(use-package vertico
  :config
  (setq vertico-cycle t)
  (setq vertico-count 10)
  :init
  (vertico-mode))

(use-package savehist
  :ensure nil
  :init
  (savehist-mode))

;; Denote for note taking
(use-package denote
  :config
  (setq denote-directory "~/Nextcloud/Documents/Notes/"))

(use-package consult)

(use-package consult-denote)

(use-package consult-lsp)

(use-package consult-todo
  :after hl-todo)

(use-package orderless
  :init
  ;; Configure a custom style dispatcher (see the Consult wiki)
  ;; (setq orderless-style-dispatchers '(+orderless-consult-dispatch orderless-affix-dispatch)
  ;;       orderless-component-separator #'orderless-escapable-split-on-space)
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides '((file (styles partial-completion)))
	read-buffer-completion-ignore-case t))

;; Display nerd-icons in margin for buffers
(use-package nerd-icons-completion
  :after marginalia
  :config
  (nerd-icons-completion-mode)
  (add-hook 'marginalia-mode-hook #'nerd-icons-completion-marginalia-setup))

;; Add additional information to completions
(use-package marginalia
  :init
  (marginalia-mode))

(use-package hl-todo
  :ensure (:type git
		 :host github
		 :repo "tarsius/hl-todo"
		 :version elpaca-latest-tag
		 :depth nil)
  :config
  (global-hl-todo-mode 1))

(use-package magit-todos
  :after magit
  :config (magit-todos-mode 1))

(use-package org-modern
  :after org)

(use-package org
  :hook
  (org-mode . visual-line-mode)
  (org-mode . display-line-numbers-mode)
  (org-mode . org-modern-mode)
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

;; An improved spell-checker
(use-package jinx
  :hook (emacs-startup . global-jinx-mode))

(use-package lsp-mode
  :init
  (setq lsp-keymap-prefix "C-l")
  :commands lsp
  :custom
  (lsp-diagnostics-flycheck-enable t)
  (lsp-idle-delay 0.5)
  :hook
  (lsp-mode . lsp-ui-mode)
  )

(use-package lsp-ui
  :commands lsp-ui-mode
  :custom
  (lsp-ui-sideline-show-hover nil)
  (lsp-ui-doc-enable nil)
  (lsp-ui-doc-enable t)
  (lsp-ui-doc-show-with-cursor nil)
  (lsp-ui-doc-show-with-mouse nil)
  (lsp-ui-doc-position 'at-point)
  )

(use-package ansi-color
  :ensure nil
  :hook (compilation-filter . ansi-color-compilation-filter))

;; Packages for programming
(use-package compile
  :ensure nil
  :config
  (setq compilation-scroll-output t))

;; Avy for jumping to characters quickly
(use-package avy
  :config
  (setq avy-all-windows t))

;; Apheleia for code formatting
(use-package apheleia
  :hook (prog-mode . apheleia-mode)
  :config
  (add-to-list 'apheleia-formatters '(rustfmt . ("rustfmt" "--quiet" "--emit" "stdout" "--edition" "2021")))
  )

(use-package hare-mode
  :ensure (:host github :repo "nikita-popov/hare-mode")
  :mode ("\\.ha\\'" . hare-mode))

(use-package protobuf-mode
  :ensure nil
  :load-path "~/.config/emacs/protobuf-mode.el"
  :mode ("\\.proto\\'" . protobuf-mode)
  :hook (protobuf-mode . (lambda () (set-fill-column 100))))

(use-package pyvenv)

(use-package python-ts-mode
  :mode ("\\.py\\'" . python-ts-mode)
  :ensure nil
  :hook (python-ts-mode . eglot-ensure))

(use-package c-ts-mode
  :mode (("\\.c\\'" . c-ts-mode)
	 ("\\.h\\'" . c-ts-mode))
  :ensure nil
  :hook (c-ts-mode . lsp-deferred))

(use-package java-ts-mode
  :mode ("\\.java\\'" . java-ts-mode)
  :ensure nil
  :hook (java-ts-mode . eglot-ensure))

(use-package hs-ts-mode
  :mode ("\\.hs\\'" . hs-ts-mode)
  :ensure nil
  :hook (hs-ts-mode . eglot-ensure))

(use-package go-ts-mode
  :mode ("\\.go\\'" . go-ts-mode)
  :ensure nil
  :hook (go-ts-mode . eglot-ensure))

(use-package odin-mode
  :ensure (:type git
		 :host github
		 :repo "mattt-b/odin-mode"
		 :depth nil))

(use-package markdown-mode
  :ensure nil
  :hook ((markdown-mode . (lambda () (set-fill-column 80)))
	 (markdown-mode . display-fill-column-indicator-mode))
  )

(use-package rust-ts-mode
  :mode ("\\.rs\\'" . rust-ts-mode)
  :ensure nil
  :hook ((rust-ts-mode . lsp-deferred)
	 (rust-ts-mode . (lambda () (set-fill-column 100))))
  :config
  (setq compile-command "cargo b")
  )

(use-package rst
  :ensure nil
  :hook ((rst-mode . eglot-ensure)
	 (rst-mode . display-line-numbers-mode)
	 (rst-mode . display-fill-column-indicator-mode)
	 (rst-mode . (lambda () (set-fill-column 80)))
	 (rst-mode . flymake-mode))
  :config
  (setq-local compilation-ask-about-save nil)
  (setq compile-command "make -k")

  (with-eval-after-load
      'eglot (add-to-list
	      'eglot-server-programs
	      '(rst-mode . ("esbonio")))
      )
  )

;; Templating system
(use-package yasnippet
  :ensure
  :config
  (setq yas-snippet-dirs
        '("~/.config/emacs/snippets/"))
  (yas-reload-all)
  (setq yas-triggers-in-field t)
  :hook
  (prog-mode . yas-minor-mode))

;; Common templates
(use-package yasnippet-snippets)

;; Highlight diffs in gutter
(use-package diff-hl
  :config
  (diff-hl-dired-mode t)
  (add-hook 'magit-pre-refresh-hook 'diff-hl-magit-pre-refresh)
  (add-hook 'magit-post-refresh-hook 'diff-hl-magit-post-refresh)
  :hook (prog-mode . diff-hl-mode))

(use-package eat
  :init
  (add-hook 'eshell-load-hook #'eat-eshell-mode)
  (add-hook 'eshell-load-hook #'eat-eshell-visual-command-mode)
  :config
  (setq eat-shell "nu")
  ;; Fix flickering
  (when (eq system-type 'darwin)
    (setopt eat-very-visible-cursor-type '(t nil nil))
    (setopt eat-default-cursor-type '(t nil nil))
    (setopt eat-shell-prompt-annotation-correction-delay 0)
    (setopt eat-shell-prompt-annotation-delay 0)
    )
  )

;; Search via ripgrep
(use-package ripgrep)

(use-package dirvish
  :hook
  (dired-mode . auto-revert-mode)
  :config
  (dirvish-peek-mode)
  (dirvish-override-dired-mode)
  (setq delete-by-moving-to-trash t))

(use-package seq
  :ensure t)			      

;; Magit for obvious reasons
(use-package magit
  :after seq
  :config
  (with-eval-after-load 'magit-mode
    (add-hook 'after-save-hook 'magit-after-save-refresh-status t))
  (setq magit-show-long-lines-warning nil))

;; Code completion
(use-package corfu
  :ensure t
  ;; Optional customizations
  :custom
  (corfu-cycle t)                 ; Allows cycling through candidates
  (corfu-auto t)                  ; Enable auto completion
  (corfu-auto-prefix 2)
  (corfu-auto-delay 0.2)
  (corfu-popupinfo-delay '(0.3 . 0.2))
  (corfu-preview-current 'insert) ; insert previewed candidate
  (corfu-preselect 'prompt)
  (corfu-on-exact-match nil)      ; Don't auto expand tempel snippets
  ;; Optionally use TAB for cycling, default is `corfu-complete'.
  :bind (:map corfu-map
	      ("C-n"        . corfu-next)
	      ("C-p"      . corfu-previous)
	      ("RET"        . corfu-insert))
  :init
  (global-corfu-mode)
  (corfu-history-mode)
  (corfu-popupinfo-mode) ; Popup completion info
  :config
  (add-hook 'eat-mode-hook
            (lambda () (setq-local corfu-quit-at-boundary t
                                   corfu-quit-no-match t
                                   corfu-auto nil)
	      (corfu-mode))))

;; Add symbols to corfu code completions
(use-package kind-icon
  :ensure t
  :after corfu
  :config
  (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter))

(use-package cape
  :ensure t
  :defer 10
  :bind ("C-c f" . cape-file)
  :init
  ;; Add `completion-at-point-functions', used by `completion-at-point'.
  ;; (defalias 'dabbrev-after-2 (cape-capf-prefix-length #'cape-dabbrev 2))
  ;; (add-to-list 'completion-at-point-functions 'dabbrev-after-2 t)
  (cl-pushnew #'cape-file completion-at-point-functions)
  :config
  ;; Silence then pcomplete capf, no errors or messages!
  (advice-add 'pcomplete-completions-at-point :around #'cape-wrap-silent)
  ;; Ensure that pcomplete does not write to the buffer
  ;; and behaves as a pure `completion-at-point-function'.
  (advice-add 'pcomplete-completions-at-point :around #'cape-wrap-purify))

;; Dockerfile integration
(use-package dockerfile-mode)

;; Justfile integration
(use-package just-mode)

;; Nushell script mode
(use-package nushell-mode)

(load "~/.config/emacs/keys.el")
