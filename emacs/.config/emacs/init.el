;; Specify specific custom-file location to avoid flooding init.el
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file t)

;; Change error level to errors. Warnings are so noisy and there doesn't seem to be a way to stop the
;; buffer from appearing
(setq warning-minimum-level :error)

;; Load elpaca
(load (expand-file-name "elpaca-setup.el" user-emacs-directory))

;; Disable menu bar
(menu-bar-mode -1)

;; Disable tool bar
(tool-bar-mode -1)

;; Remove the splash screen
(setq-default inhibit-splash-screen t)

;; Disable scroll bar
(setq-default cursor-type 'bar) 
(scroll-bar-mode -1)

;; Lock files cause issues on emacs-mac
(setq create-lockfiles nil)

;; Standardize autosave files to common directory
(setq auto-save-file-name-transforms
      '((".*" "~/.config/emacs/auto-save-list/" t))
      backup-directory-alist
      '((".*", "~/.config/emacs/backups/")))

;; Use scroll offset
(pixel-scroll-precision-mode 1)
(setq scroll-margin 5
      scroll-step 1
      scroll-conservatively 10000
      scroll-preserve-screen-position 1)

;; Set recentf mode
(recentf-mode 1)

;; Basic configuration tweaks
;; Set font
(set-face-attribute 'default nil :font "ComicShannsMono Nerd Font Mono" :height 120)

;; Use relative line numbers
(setq display-line-numbers-type 'relative)

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

(load (expand-file-name "private.el" user-emacs-directory))

(use-package prog-mode
  :ensure nil
  :config
  (setq truncate-lines t)
  :hook
  (prog-mode . (lambda ()
		 (apheleia-mode)
		 (company-mode)
		 (display-line-numbers-mode)
		 (display-fill-column-indicator-mode)
		 (diff-hl-mode)
		 (electric-indent-mode)
		 (electric-pair-mode)
		 (envrc-mode)
		 (yas-minor-mode))))

(use-package transient
  :ensure t)

(use-package colorful-mode)

(use-package gruber-darker-theme)

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
  (setq doom-modeline-project-detection 'auto
	doom-modeline-icon t
	doom-modeline-analogue-clock nil
	doom-modeline-lsp-icon t
	doom-modeline-modal t
	doom-modeline-modal-modern-icon t))

(use-package nerd-icons
  :config
  (setq nerd-icons-scale-factor 1.1
	nerd-icons-font-family "ComicShannsMono Nerd Font Mono")
  )

;; evil-mode configuration
(use-package evil
  :init
  (setq evil-want-keybinding nil)
  :config
  (setq evil-want-integration t
	evil-vsplit-window-right t
	evil-auto-indent t
	evil-split-window-below t)
  (evil-mode)
  (define-key evil-normal-state-map (kbd "C-u") 'evil-scroll-up)
  (evil-set-undo-system 'undo-redo))

(use-package evil-nerd-commenter
  :after evil
  :defer 5)

;; Additional evil-mode bindings
(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

;; Evil mode multi-cursor support
(use-package evil-mc
  :after evil
  :defer 5
  :config
  (setq evil-mc-mode-line-text-cursor-color t)
  (global-evil-mc-mode 1))

;; Evil surround
(use-package evil-surround
  :after evil
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
  (setq vertico-cycle t
	vertico-count 10)
  (vertico-mode))

(use-package savehist
  :ensure nil
  :config
  (savehist-mode))

;; Denote for note taking
(use-package denote
  :config
  (setq denote-directory "~/Nextcloud/Documents/Notes/"))

(use-package consult)

(use-package consult-denote
  :defer 10)

(use-package consult-lsp
  :defer 5)

(use-package consult-todo
  :after hl-todo)

(use-package orderless
  :config
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides '((file (styles partial-completion)))
	read-buffer-completion-ignore-case t))

;; Display nerd-icons in margin for buffers
(use-package nerd-icons-completion
  :after marginalia
  :config
  (nerd-icons-completion-mode))

;; Add additional information to completions
(use-package marginalia
  :hook
  (marginalia-mode . #'nerd-icons-completion-marginalia-setup)
  :config
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
  :config
  (magit-todos-mode 1))

(use-package org-superstar
  :after org
  :config
  (setq org-hide-leading-stars nil)
  ;; This line is necessary.
  (setq org-superstar-leading-bullet ?\s)
  ;; If you use Org Indent you also need to add this, otherwise the
  ;; above has no effect while Indent is enabled.
  (setq org-indent-mode-turns-on-hiding-stars nil))

(use-package org
  :hook
  (org-mode . (lambda ()
		(visual-line-mode)
		(display-line-numbers-mode)
		(org-superstar-mode)
		(org-indent-mode)
		(yas-minor-mode)))
  :config
  (setq org-todo-keywords
        '((sequence "TODO(t)" "PROG(p)" "PROJ(j)" "SENT(s)" "|" "DONE(d)" "CANC(c)" "PASS(a)")))
  (setq org-todo-keyword-faces
        '(("TODO" . "#ff5555") ("PROG" . "#ffb86c") ("PROJ" . "#8be9fd") ("SENT" . "#ff79c6")
          ("DONE" . "#50fa7b") ("CANC" . "#a4fcba") ("PASS" . "#44475a")))
  ;; Add these files to the agenda
  (setq org-clock-sound (expand-file-name "timer.wav" user-emacs-directory)
	org-agenda-files '("~/org/agenda"))
  ;; Save Org buffers after refiling!
  (advice-add 'org-refile :after 'org-save-all-org-buffers))

(use-package lsp-mode
  :commands lsp
  :config
  (setq lsp-diagnostics-flycheck-enable t
	lsp-keymap-prefix "C-l"
	lsp-idle-delay 0.5)
  )

;; Packages for programming
(use-package fancy-compilation
  :after compile
  :commands (fancy-compilation-mode)
  :config
  (setq fancy-compilation-override-colors nil)
  :init
  (with-eval-after-load 'compile
    (fancy-compilation-mode))
  )

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
  :config
  ;; This removes the need to add rustfmt.toml files into the project root
  (add-to-list 'apheleia-formatters '(rustfmt . ("rustfmt" "--quiet" "--emit" "stdout" "--edition" "2021"))))

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

(use-package svelte-mode
  :after company
  :config
  (setq svelte-basic-offset 2))

;; Justfile integration
(use-package just-mode
  )

(use-package markdown-mode
  :ensure nil
  :hook ((markdown-mode . (lambda () (set-fill-column 80)))
	 (markdown-mode . display-fill-column-indicator-mode))
  )

(use-package nix-ts-mode
  :mode
  (("\\.nix\\'" . nix-ts-mode)
   ("flake.lock\\'" . js-json-mode))
  )

(use-package js-json-mode
  :ensure nil
  :mode ("\\.json\\'"))

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

;; Groovy script
(use-package groovy-mode)

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

;; Typescript mode
(use-package typescript-ts-mode
  :ensure nil
  :mode ("\\.ts\\'" . typescript-ts-mode))

;; ------------------------------------------------

;; Support for direnv
;;
;; This seems to work way better than direnv, since direnv does a 
(use-package envrc) 

(use-package expreg)

;; Templating system
(use-package yasnippet
  :ensure
  :config
  (setq yas-snippet-dirs '("~/.config/emacs/snippets/")
	yas-triggers-in-field t)
  (yas-reload-all))

;; Common templates
(use-package yasnippet-snippets)

;; Highlight diffs in gutter
(use-package diff-hl
  :config
  (diff-hl-dired-mode t)
  :hook
  (magit-pre-refresh . diff-hl-magit-pre-refresh)
  (magit-post-refresh . diff-hl-magit-post-refresh))

(use-package eat
  :init
  :hook
  (eshell-load . (lambda ()
		   (#'eat-eshell-mode)
		   (#'eat-eshell-visiual-command-mode)))
  :config
  (setq truncate-partial-width-windows nil
	truncate-lines nil
	eat-shell "nu"))

;; Search via ripgrep
(use-package ripgrep)

(use-package openwith)

(use-package dired
  :ensure nil
  :hook
  (dired-mode . openwith-mode)
  :config
  (setq dired-auto-revert-buffer #'dired-directory-changed-p
	dired-free-space nil
	dired-listing-switches "-AGFhlv --group-directories-first --time-style=long-iso"
	openwith-associations '(
				("\\.pdf\\'" "zathura" (file)))))

(use-package seq
  :ensure t)

(use-package blamer
  :ensure t
  :defer 10
  :config
  (setq blamer-idle-time 0.3
	blamer-min-offset 70)
  :custom-face
  (blamer-face ((t :foreground "#484741"
                   :background nil
                   :height 120
                   :italic t))))

;; Magit for obvious reasons
(use-package magit
  :after seq
  :config
  (with-eval-after-load 'magit-mode
    (add-hook 'after-save-hook 'magit-after-save-refresh-status t))
  (setq magit-show-long-lines-warning nil))

;; I've used company for a long time, in 2024 I switched to corfu for
;; a while, but after about 8 months I found the experience
;; inconsistent, sometimes triggering crashes when used with lsp-mode
;; I've switched back to company mode and all is well
(use-package company
  :ensure t
  :hook (prog-mode . company-mode)
  :config
  (setq company-idle-delay 0.2 
	company-minimum-prefix-length 2
	company-tooltip-align-annotations t
	company-tooltip-limit 5
	company-tooltip-minimum 5
	company-tooltip-offset-display 'lines
	company-format-margin-function 'company-vscode-dark-icons-margin)
  :bind
  (:map company-active-map
	("<tab>" . company-complete-selection)
	("C-n" . company-select-next)
	("C-p" . company-select-previous)
	("M-<" . company-select-first)
	("M->" . company-select-last))
  )

(use-package cape
  :ensure t
  :bind ("C-c f" . cape-file)
  :init
  (add-hook 'completion-at-point-functions #'cape-file)
  (add-hook 'completion-at-point-functions #'cape-emoji)
  :config
  ;; Silence then pcomplete capf, no errors or messages!
  (advice-add 'pcomplete-completions-at-point :around #'cape-wrap-silent)
  ;; Ensure that pcomplete does not write to the buffer
  ;; and behaves as a pure `completion-at-point-function'.
  (advice-add 'pcomplete-completions-at-point :around #'cape-wrap-purify))

;; Load my keybindings
(load (expand-file-name "keys.el" user-emacs-directory))
