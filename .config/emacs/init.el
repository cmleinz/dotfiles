;; Minimize garbage collection during startup
(setq gc-cons-threshold most-positive-fixnum)

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
(set-face-attribute 'default nil :font "Comic Code Ligatures" :height 110)
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
  )
;; (add-to-list 'default-frame-alist '(alpha-background . 96))
(add-hook 'prog-mode-hook 'my-prog-mode-hook)
;; Auto pair brackets and parens
(electric-pair-mode 1)
;; Set display fill indicator column
(setq display-fill-column-indicator-column 100)
(setq-default display-fill-column-indicator-column 100)
(add-hook 'prog-mode-hook 'display-fill-column-indicator-mode)
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
;; Some weird dired issues with ls
(when (eq system-type 'darwin)
  (setq insert-directory-program "/opt/homebrew/bin/gls"))
;; Lock files cause issues on emacs-mac
(setq create-lockfiles nil)

(use-package dirvish
  :init (dirvish-override-dired-mode))

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

(use-package nerd-icons
  :custom
  (nerd-icons-font-family  "Iosevka Nerd Font Mono")
  (doom-modeline-major-mode-icon t))

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
  (define-key evil-normal-state-map (kbd "/") 'consult-line)
  (define-key evil-normal-state-map (kbd "gh") 'evil-beginning-of-line)
  (define-key evil-normal-state-map (kbd "gl") 'evil-end-of-line)
  (define-key evil-normal-state-map (kbd "ga") 'evil-switch-to-windows-last-buffer)
  (define-key evil-normal-state-map (kbd "ge") 'end-of-buffer))

(use-package evil-nerd-commenter)

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

;; Vertico for minibuffer magic!
(use-package vertico
  :diminish
  :config
  (setq vertico-cycle t)
  :init
  (vertico-mode))
(use-package savehist
  :elpaca nil
  :init
  (savehist-mode))
(use-package orderless
  :init
  ;; Configure a custom style dispatcher (see the Consult wiki)
  ;; (setq orderless-style-dispatchers '(+orderless-consult-dispatch orderless-affix-dispatch)
  ;;       orderless-component-separator #'orderless-escapable-split-on-space)
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides '((file (styles partial-completion)))))
;; Add additional information to completions
(use-package marginalia
  :init
  (marginalia-mode))
(use-package consult)
;; Integrate consult with lsp
(use-package consult-lsp)

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

;; Packages for programming

;; Apheleia for code formatting
(use-package apheleia
  :hook (prog-mode . apheleia-mode))

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
  (lsp-ui-peek-enable t)
  (lsp-ui-sideline-show-hover nil)
  (lsp-ui-sideline-show-diagnostics t)
  (lsp-ui-sideline--push-info nil)
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
  (setq projectile-completion-system 'default)
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
  (corfu-auto-delay 0.3)
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
  (advice-add 'pcomplete-completions-at-point :around #'cape-wrap-purify)k)

;; Java integration
(use-package lsp-java)

;; Dockerfile integration
(use-package dockerfile-mode)

;; May switch to rust mode
(use-package rustic)

(load "~/.config/emacs/keys.el")

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("e3daa8f18440301f3e54f2093fe15f4fe951986a8628e98dcd781efbec7a46f2" "88267200889975d801f6c667128301af0bc183f3450c4b86138bfb23e8a78fb1" "0340489fa0ccbfa05661bc5c8c19ee0ff95ab1d727e4cc28089b282d30df8fc8" default))
 '(org-agenda-files nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

