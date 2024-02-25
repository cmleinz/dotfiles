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
  ;; Enable :elpaca use-package keyword.
  (elpaca-use-package-mode)
  ;; Assume :elpaca t unless otherwise specified.
  (setq elpaca-use-package-by-default t))

;; Block until current queue processed.
(elpaca-wait)

(setq user-full-name "Caleb Leinz"
      user-mail-address "caleb@leinz.io")

;; Set recentf mode
(recentf-mode 1)

;; Basic configuration tweaks
;; Set font
(when (eq system-type 'gnu/linux)
  (setq default-text-properties '(line-spacing 0.25 line-height 1.25))
  (set-face-attribute 'default nil :font "Comic Code Ligatures" :height 110))
(when (eq system-type 'darwin)
  (set-face-attribute 'default nil :font "Comic Code Ligatures" :height 130))

;; Disable menu bar
(menu-bar-mode -1)

;; Disable tool bar
(tool-bar-mode -1)

;; Disable scroll bar
(setq-default cursor-type 'bar) 
(scroll-bar-mode -1)

;; Use relative line numbers
(setq display-line-numbers-type 'relative)

(defun my-prog-mode-hook ()
  (display-line-numbers-mode 1)
  (flyspell-prog-mode)
  (display-fill-column-indicator-mode 1))

(add-hook 'prog-mode-hook 'my-prog-mode-hook)

;; Auto pair brackets and parens
(setq electric-pair-pairs
      '(
        (?\( . ?\))
        (?\{ . ?\})
        (?\[ . ?\])
        (?< . ?>)
        ))
(electric-pair-mode 1)
(electric-indent-mode 1)

;; Set display fill indicator column
(setq display-fill-column-indicator-column 100)
(setq-default display-fill-column-indicator-column 100)

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
	)
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

;; Some weird dired issues with ls
(when (eq system-type 'darwin)
  (setq insert-directory-program "/opt/homebrew/bin/gls"))

(use-package exec-path-from-shell
  :ensure t
  :config
  (when (memq window-system '(mac ns x))
    (exec-path-from-shell-initialize)))

(use-package nerd-icons
  :custom
  (nerd-icons-font-family  "Iosevka Nerd Font Mono")
  (doom-modeline-major-mode-icon t))

;; Theme
(use-package gruber-darker-theme
  :config
  (load-theme 'gruber-darker t))

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

;; Use all the Icons
(use-package all-the-icons
  :if (display-graphic-p)
  :commands all-the-icons-install-fonts
  :init (unless (find-font (font-spec :name "all-the-icons"))
	  (all-the-icons-install-fonts t)))


;; Include fun icons in dired-mode
(use-package all-the-icons-dired
  :hook
  (dired-mode . all-the-icons-dired-mode))

;; Vertico for minibuffer magic!
(use-package vertico
  :config
  (setq vertico-cycle t)
  :init
  (vertico-mode))

(use-package savehist
  :elpaca nil
  :init
  (savehist-mode))

;; Denote for note taking
(use-package denote)

(use-package consult)

(use-package consult-todo
  :after hl-todo)

(use-package consult-notes
  :config
  (consult-notes-denote-mode))

(use-package orderless
  :init
  ;; Configure a custom style dispatcher (see the Consult wiki)
  ;; (setq orderless-style-dispatchers '(+orderless-consult-dispatch orderless-affix-dispatch)
  ;;       orderless-component-separator #'orderless-escapable-split-on-space)
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides '((file (styles partial-completion)))
	read-buffer-completion-ignore-case t))

;; Add additional information to completions
(use-package marginalia
  :init
  (marginalia-mode))

(use-package hl-todo
  :elpaca (:type git
		 :host github
		 :repo "tarsius/hl-todo"
		 :version elpaca--latest-tag
		 :depth nil)
  :config
  (global-hl-todo-mode 1))

(use-package magit-todos
  :after magit
  :config (magit-todos-mode 1))

;; Dim inactive buffers
(use-package dimmer
  :config
  (dimmer-configure-which-key)
  (dimmer-mode t))

(use-package org-modern
  :after org)

(use-package org
  :hook
  (org-mode . visual-line-mode)
  (org-mode . display-line-numbers-mode)
  (org-mode . flyspell-mode)
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

;; Built-in Eglot as LSP
(use-package eglot
  :elpaca nil
  :hook ((eglot-managed-mode . eldoc-mode)
	 (eglot-managed-mode . flymake-mode))
  )

(use-package ansi-color
  :elpaca nil
  :hook (compilation-filter . ansi-color-compilation-filter))

;; Packages for programming
(use-package compile
  :elpaca nil
  :config
  (setq compilation-scroll-output t))

;; Apheleia for code formatting
(use-package apheleia
  :hook (prog-mode . apheleia-mode))

(use-package pyvenv)

(use-package python-ts-mode
  :mode ("\\.py\\'" . python-ts-mode)
  :elpaca nil
  :hook (python-ts-mode . eglot-ensure)
  )

(use-package c-ts-mode
  :mode (("\\.c\\'" . c-ts-mode)
	 ("\\.h\\'" . c-ts-mode))
  :elpaca nil
  :hook ((c-ts-mode . eglot-ensure)
	 (c-ts-mode . eldoc-mode)))

(use-package java-ts-mode
  :mode ("\\.java\\'" . java-ts-mode)
  :elpaca nil
  :hook ((java-ts-mode . eglot-ensure)
	 (java-ts-mode . eldoc-mode)))

(use-package hs-ts-mode
  :mode ("\\.hs\\'" . hs-ts-mode)
  :elpaca nil
  :hook ((hs-ts-mode . eglot-ensure)
	 (hs-ts-mode . eldoc-mode)))

(use-package rust-ts-mode
  :mode ("\\.rs\\'" . rust-ts-mode)
  :elpaca nil
  :hook ((rust-ts-mode . eglot-ensure)
	 (rust-ts-mode . eldoc-mode))
  :config
  ;; Disable inlay hints for rust. A bit too noisy
  (setq eglot-ignored-server-capabilities '(:inlayHintProvider))
  ;; Set the default compile command
  (setq compile-command "cargo b")
  ;; Tell eglot to prefer rust-analyzer, normally prompts for rust-analyzer of rls
					; Also configure rust analyzer
  (add-to-list
   'eglot-server-programs
   '(
     rust-ts-mode .
     ("rust-analyzer" :initializationOptions (
					      :check (:command "clippy")
					      :cargo (:features "all")))))
  )

(use-package rst
  :elpaca nil
  :ensure t
  :hook ((rst-mode . eglot-ensure)
	 (rst-mode . display-line-numbers-mode)
	 (rst-mode . flyspell-mode)
	 (rst-mode . flymake-mode))
  :config
  ;; This is the only place I use RST currently
  (setq compile-command "sphinx-build -j \"auto\" -a ./docs/source/ ./docs/source/_build/")
  (add-to-list
   'eglot-server-programs
   '(rst-mode . ("esbonio")))
  )

;; Templating system
(use-package yasnippet
  :ensure
  :config
  (setq yas-snippet-dirs
        '("~/.config/emacs/snippets/"))
  (yas-reload-all)
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

;; Vterm
(use-package vterm
  :config
  (setq vterm-shell "~/.cargo/bin/nu"))

(use-package multi-vterm)

;; Search via ripgrep
(use-package ripgrep)

(use-package seq
  :ensure t)			      

;; Magit for obvious reasons
(use-package magit
  :after seq
  :config
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
  (corfu-popupinfo-delay '(0.5 . 0.2))
  (corfu-preview-current 'insert) ; insert previewed candidate
  (corfu-preselect 'prompt)
  (corfu-on-exact-match nil)      ; Don't auto expand tempel snippets
  ;; Optionally use TAB for cycling, default is `corfu-complete'.
  :bind (:map corfu-map
	      ("M-SPC"      . corfu-insert-separator)
	      ("TAB"        . corfu-next)
	      ([tab]        . corfu-next)
	      ("S-TAB"      . corfu-previous)
	      ([backtab]    . corfu-previous)
	      ("S-<return>" . corfu-insert)
	      ("RET"        . nil))

  :init
  (global-corfu-mode)
  (corfu-history-mode)
  (corfu-popupinfo-mode) ; Popup completion info
  :config
  (add-hook 'eshell-mode-hook
            (lambda () (setq-local corfu-quit-at-boundary t
                                   corfu-quit-no-match t
                                   corfu-auto nil)
	      (corfu-mode))))

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

(load "~/.config/emacs/modeline.el")

(load "~/.config/emacs/hare-mode.el")
