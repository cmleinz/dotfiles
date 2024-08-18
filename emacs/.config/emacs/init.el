;; Specify specific custom-file location to avoid flooding init.el
(setq custom-file "~/.config/emacs/custom.el")
(load custom-file t)

;; Load elpaca
(load "~/.config/emacs/elpaca-setup.el")

(setq user-full-name "Caleb Leinz"
      user-mail-address "caleb@leinz.io")

;; Set recentf mode
(recentf-mode 1)

;; Basic configuration tweaks
;; Set font
(set-face-attribute 'default nil :font "ComicShannsMono Nerd Font Mono" :height 120)

;; Use relative line numbers
(setq display-line-numbers-type 'relative)

(defun my-prog-mode-hook ()
  (setq truncate-lines t)
  (display-line-numbers-mode 1)
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
  :ensure t
  )

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

(use-package colorful-mode)

(use-package ef-themes
  :config
  (setq ef-themes-to-toggle '(ef-autumn ef-melissa-light))
  (ef-themes-select 'ef-autumn))

(use-package doom-themes)

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
  (setq nerd-icons-font-family "ComicShannsMono Nerd Font Mono")
  )

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
  (evil-set-undo-system 'undo-redo)
  )

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
  (setq evil-mc-mode-line-text-cursor-color t)
  )

;; Evil surround
(use-package evil-surround
  :ensure t
  :config
  (global-evil-surround-mode 1)
  ;; The default behavior is to have a space between the delimiters
  ;; if you use the opening version of the paren, and no-space if
  ;; you use the closing paren. I prefer the opposite behavior
  (setq-default evil-surround-pairs-alist
		'(
		  (?\( . ("(" . ")"))
		  (?\< . ("<" . ">"))
		  (?\[ . ("[" . "]"))
		  (?\{ . ("{" . "}"))
		  (?\) . ("( " . " )"))
		  (?\> . ("< " . " >"))
		  (?\] . ("[ " . " ]"))
		  (?\} . ("{ " . " }"))
		  (?\` . ("`" . "`"))
		  ))
  )

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
  (vertico-mode)
  )

(use-package savehist
  :ensure nil
  :init
  (savehist-mode)
  )

;; Denote for note taking
(use-package denote
  :config
  (setq denote-directory "~/Nextcloud/Documents/Notes/")
  )

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
  (setq completion-styles '(basic orderless)
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

(use-package org-superstar
  :after org
  :config
  (setq org-hide-leading-stars nil)
  ;; This line is necessary.
  (setq org-superstar-leading-bullet ?\s)
  ;; If you use Org Indent you also need to add this, otherwise the
  ;; above has no effect while Indent is enabled.
  (setq org-indent-mode-turns-on-hiding-stars nil)
  )

(use-package org
  :hook
  (org-mode . visual-line-mode)
  (org-mode . display-line-numbers-mode)
  (org-mode . (lambda () (org-superstar-mode 1)))
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

;; On NixOS jinx doesn't play nicely with the libraries
;; ;; An improved spell-checker
;; (use-package jinx
;;   :hook (emacs-startup . global-jinx-mode)
;;   )

(use-package lsp-mode
  :init
  (setq lsp-keymap-prefix "C-l")
  :commands lsp
  :config
  (setq lsp-diagnostics-flycheck-enable t)
  (setq lsp-idle-delay 0.5)
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
  ;; This removes the need to add rustfmt.toml files into the project root
  (add-to-list 'apheleia-formatters '(rustfmt . ("rustfmt" "--quiet" "--emit" "stdout" "--edition" "2021")))
  
  )

(use-package pyvenv)

;; Language Support and Tree Sitter 🌳 Integrations
;; ------------------------------------------------

(use-package c-ts-mode
  :mode (("\\.c\\'" . c-ts-mode)
	 ("\\.h\\'" . c-ts-mode))
  :ensure nil
  :hook (c-ts-mode . lsp-deferred)
  )

;; Dockerfile integration
(use-package dockerfile-mode
  )

(use-package go-ts-mode
  :mode ("\\.go\\'" . go-ts-mode)
  :ensure nil
  :hook (go-ts-mode . lsp-deferrde)
  )

;; Hare
(use-package hare-mode
  :ensure (:repo "https://git.sr.ht/~laumann/hare-mode" :depth 1)
  :mode ("\\.ha\\'" . hare-mode)
  )

;; Haskell
(use-package hs-ts-mode
  :mode ("\\.hs\\'" . hs-ts-mode)
  :ensure nil
  :hook (hs-ts-mode . lsp-deferred)
  )

;; ☕ Java
(use-package java-ts-mode
  :after lsp-java
  :mode ("\\.java\\'" . java-ts-mode)
  :ensure nil
  :hook (java-ts-mode . lsp-deferred)
  )

;; Justfile integration
(use-package just-mode
  )

(use-package markdown-mode
  :ensure nil
  :hook ((markdown-mode . (lambda () (set-fill-column 80)))
	 (markdown-mode . display-fill-column-indicator-mode))
  )

(use-package nix-ts-mode
  :mode "\\.nix\\'")

;; Nushell script mode
(use-package nushell-mode
  )

(use-package odin-mode
  :ensure (:type git
		 :host github
		 :repo "mattt-b/odin-mode"
		 :depth 1)
  )

;; Google Protobufs
(use-package protobuf-mode
  :ensure (:type git
		 :host github
		 :repo "protocolbuffers/protobuf"
		 :files (:defaults "editors/*.el") 
		 :depth 1)
  :mode ("\\.proto\\'" . protobuf-mode)
  :hook (protobuf-mode . (lambda () (set-fill-column 100)))
  )

;; 🐍 Python
(use-package python-ts-mode
  :mode ("\\.py\\'" . python-ts-mode)
  :ensure nil
  :hook (python-ts-mode . lsp-deferred)
  :defer 30
  )

;; Restructured text
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
  :defer 30
  )

;; Rust
(use-package rust-ts-mode
  :ensure nil
  :mode ("\\.rs\\'" . rust-ts-mode)
  :hook ((rust-ts-mode . lsp-deferred)
	 (rust-ts-mode . (lambda () (set-fill-column 100))))
  :config
  (setq compile-command "cargo b --all-features")
  (setq lsp-rust-analyzer-cargo-watch-command "clippy")
  (setq lsp-rust-features "all"))

;; ------------------------------------------------

;; Support for direnv
(use-package direnv
  :config
  (direnv-mode))

(use-package expreg)

;; Templating system
(use-package yasnippet
  :ensure
  :config
  (setq yas-snippet-dirs
        '("~/.config/emacs/snippets/"))
  (yas-reload-all)
  (setq yas-triggers-in-field t)
  :hook
  (prog-mode . yas-minor-mode)
  )

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
  ;; Disable line wrapping
  (setq truncate-partial-width-windows nil)
  (setq truncate-lines nil)
  (setq )
  (setq eat-shell "nu")
  )

;; Search via ripgrep
(use-package ripgrep)

(use-package openwith)

(use-package dired
  :ensure nil
  :hook
  (dired-mode . openwith-mode)
  :config
  (setq openwith-associations
	'(
	  ("\\.pdf\\'" "zathura" (file)))
	)
  )

(use-package seq
  :ensure t)			      

;; Magit for obvious reasons
(use-package magit
  :after seq
  :config
  (with-eval-after-load 'magit-mode
    (add-hook 'after-save-hook 'magit-after-save-refresh-status t))
  (setq magit-show-long-lines-warning nil))

;; I've used company for a long time, in 2024 I switched to corfu for
;; a while, but after about 6 months I found the experience
;; inconsistent, sometimes triggering crashes when used with lsp-mode
;; I've switched back to company mode and all is well
(use-package company
  :ensure t
  :hook (prog-mode . company-mode)
  :config
  (setq company-idle-delay 0.2) 
  (setq company-minimum-prefix-length 2) 
  (setq company-tooltip-align-annotations t)
  (setq company-tooltip-limit 5)
  (setq company-tooltip-minimum 5)
  (setq company-tooltip-offset-display 'lines)
  (setq company-format-margin-function 'company-vscode-dark-icons-margin)
  :bind
  (:map company-active-map
        ("<tab>" . company-complete-selection)
        ("C-n" . company-select-next)
        ("C-p" . company-select-previous)
        ("M-<" . company-select-first)
        ("M->" . company-select-last))
  )

;; (use-package kind-icon
;;   :ensure t
;;   :after company
;;   :config
;;   (let* ((kind-func (lambda (cand) (company-call-backend 'kind cand)))
;;          (formatter (kind-icon-margin-formatter `((company-kind . ,kind-func)))))
;;     (defun my-company-kind-icon-margin (cand _selected)
;;       (funcall formatter cand))
;;     (setq company-format-margin-function #'my-company-kind-icon-margin)))

(use-package cape
  :ensure t
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

(load "~/.config/emacs/keys.el")
