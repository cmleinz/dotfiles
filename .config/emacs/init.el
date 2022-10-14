;; AUTHOR: Caleb Leinz
;; EMACS_VERSION: 28.1

;; The default is 800 kilobytes.  Measured in bytes.
(setq gc-cons-threshold (* 50 1000 1000))

;; Profile emacs startup
(add-hook 'emacs-startup-hook
          (lambda ()
            (message "*** Emacs loaded in %s with %d garbage collections."
                     (format "%.2f seconds"
                             (float-time
                              (time-subtract after-init-time before-init-time)))
                     gcs-done)))

;; Initialize package sources
(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("melpa-stable" . "https://stable.melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
 (package-refresh-contents))

;; Ensure we have use-package setup
(require 'use-package)
(setq use-package-always-ensure t)

;; Disable splashscreen
(setq inhibit-startup-message t)

;; Change scrolling behavior to scroll prior to end of view
(setq scroll-step 1)
(setq scroll-margin 5)

;; Make Emacs more minimal
(menu-bar-mode -1) ; Disable menubar
(tool-bar-mode -1) ; Disable toolbar
(scroll-bar-mode -1) ; Disable scrollbar

;; Enable global line numbers
(setq display-line-numbers-type 'relative)
(global-display-line-numbers-mode 1)

;; Move all backup and autosave files
(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))

(save-place-mode 1)

;; Set font to Fira Code
(set-face-attribute 'default nil :font "Fira Code Retina" :height 110)

;; Use the Iosvkem theme from the doom themese package
;; (use-package soothe-theme
;;   :config
;;   (load-theme 'soothe t))

(use-package doom-themes
  :ensure t
  :config
  ;; Global settings (defaults)
  (setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
        doom-themes-enable-italic t) ; if nil, italics is universally disabled

  ;; Enable flashing mode-line on errors
  (load-theme 'doom-dracula t)
  (doom-themes-visual-bell-config)
  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config))

;; Use swiper for supercharged searching
(use-package swiper
  :ensure t)

;; Use counsel
(use-package counsel
  :bind (
         :map minibuffer-local-map
         ("C-r" . 'counsel-minibuffer-history)))

;; Use Ivy for all sorts of useful autocompletion
(use-package ivy
  :diminish
  :bind (("C-s" . swiper)
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

(use-package minions
  :hook (doom-modeline-mode . minions-mode))

;; Enable the doom modeline
(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1)
  :custom (
	   (doom-modeline-height 15)
	   (doom-modeline-lsp t)
	   (doom-modeline-minor-modes t)
	   ))


(use-package evil-nerd-commenter
  :bind ("M-/" . evilnc-comment-or-uncomment-lines))

;; Use the general package to setup space bindings
(use-package general
  :config
  (general-evil-setup t)
  (general-override-mode)
  (general-define-key
   :states '(normal visual insert emacs)
   :keymaps 'override
   :prefix "SPC"
   :non-normal-prefix "M-SPC"
    "b"  '(:ignore t :which-key "Buffers")
    "bb" '(counsel-switch-buffer :which-key "Switch buffer")
    "bl" '(evil-next-buffer :which-key "Next buffer")
    "bh" '(evil-prev-buffer :which-key "Next buffer")
    "bk" '(kill-buffer :which-key "Kill buffer")

    "f"  '(:ignore t :which-key "Files")
    "ff" '(counsel-find-file :which-key "Find file")
    "fr" '(counsel-recentf :which-key "Recent file")

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

    "l"  '(:ignore t :which-key "LSP")
    "lf" '(lsp-ui-peek-find-definitions :which-key "Show function definition")
    "lk" '(lsp-ui-doc-show :which-key "Show item docs")
    "lh" '(lsp-ui-doc-hide :which-key "Hide item docs")
    "la" '(lsp-execute-code-action :which-key "Perform code actions") 

    "g"  '(:ignore t :which-key "Magit")
    "gg"  '(magit-status :which-key "Magit status")

    "r"  '(:ignore t :which-key "Configuration changes")
    "rr" '((lambda () (interactive) (load-file "~/.config/emacs/init.el")) :which-key "Reload init.el")
    "re" '((lambda () (interactive) (find-file "~/.config/emacs/init.el")) :which-key "Open init.el")

    "p"  '(:ignore t :which-key "Project")
    "p/" '(counsel-git-grep :which-key "Grep project")

    "e"  '(eshell :which-key "Eshell")
   )
)

;; Enable rainbow-delimiters
(use-package rainbow-delimiters
  :hook
  (prog-mode . rainbow-delimiters-mode)
  (toml-mode . rainbow-delimiters-mode))

;; Enable rainbow mode in css files
(use-package rainbow-mode
  :hook ((css-mode-hook . rainbow-mode)
	 (html-mode-hook . rainbow-mode)
	 (latex-mode-hook . rainbow-mode)
	 (scss-mode-hook . rainbow-mode)))

;; ;; Enable autopairs in prog hook
;; (use-package smartparens
;;   :hook
;;   (prog-mode . smartparens-mode)
;;   (toml-mode . smartparens-mode))

;; (use-package evil-smartparens
;;   :hook (smartparens-mode . evil-smartparens-mode))

(use-package pdf-tools
  :magic ("%PDF" . pdf-view-mode))

;; Setup Evil-mode, because it's really good
(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-i-jump nil)
  :config
  (evil-mode 1)
  (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)
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
  (setq org-clock-sound "~/.config/emacs/bell-ring.wav")
  ;; Set Org-Mode TODO keywords
  (setq org-todo-keywords
	'((sequence "TODO(t)" "PROG(p)" "PROJ(j)" "SENT(s)" "|" "DONE(d)" "CANC(c)" "PASS(a)")))
  ;; Set Org-Mode TODO state colors
  (setq org-todo-keyword-faces
	'(("TODO" . "#ff5555") ("PROG" . "#ffb86c") ("PROJ" . "#8be9fd") ("SENT" . "#ff79c6")
          ("DONE" . "#50fa7b") ("CANC" . "#a4fcba") ("PASS" . "#44475a")))
 
  (setq org-agenda-files
	'(("~/Nextcloud/Org/Todo.org")("~/Nextcloud/Ord/Life.org")))
 
  (setq org-refile-targets
    '(("~/Nextcloud/Org/Archive.org" :maxlevel . 1)))

  ;; Save Org buffers after refiling!
  (advice-add 'org-refile :after 'org-save-all-org-buffers))

 ;; ----------------DEVELOPMENT SETUP----------------

;; Use tree sitter for syntax highlighting. It is incredible
(use-package tree-sitter
  :config
  (use-package tree-sitter-langs)
  (global-tree-sitter-mode)
  (add-hook 'tree-sitter-after-on-hook #'tree-sitter-hl-mode))

;; Highlight matching parens
(use-package paren
  :config
  (set-face-attribute 'show-paren-match-expression nil :background "#363e4a")
  (show-paren-mode 1))

(use-package diff-hl
  :hook (prog-mode . diff-hl-mode))

;; Use yasnippets
(use-package yasnippet
  :ensure
  :config
  (setq yas-snippet-dirs
	'("~/.config/emacs/snippets/"))
  (yas-reload-all)
  (yas-global-mode)
  (add-hook 'prog-mode-hook 'yas-minor-mode)
  (add-hook 'text-mode-hook 'yas-minor-mode)
  (use-package yasnippet-snippets))

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

(use-package smartparens
  :hook (prog-mode . smartparens-mode))

(use-package centaur-tabs
  :config
  (setq centaur-tabs-set-icons t
	centaur-tabs-show-navigation-buttons t
	centaur-tabs-height 32
	centaur-tabs-set-modified-marker t)
  (centaur-tabs-change-fonts "Fira Code Retina" 120))

;; (use-package treemacs
;;   :init (setq treemacs-show-hidden-files nil)
;;   :config
;;   (setq treemacs-default-visit-action 'treemacs-visit-node-close-treemacs)
;;   (use-package treemacs-evil)
;;   (use-package yasnippet-snippets))

;; Flycheck conducts on-the-fly syntax checking
(use-package flycheck
  :ensure t
  :init (global-flycheck-mode))

(use-package magit
  :init
  (message "Loading Magit!")
  :config
  (message "Loaded Magit!")
  :bind (("C-x g" . magit-status)
         ("C-x C-g" . magit-status)))

;; ----------------PYTHON SETUP----------------
;; Elpy is the basic framework which provides things like
;; autocompletion, error checking, building, etc.
(use-package elpy
  :init (add-hook 'python-mode-hook #'elpy-enable)
  :config
  (setq elpy-rpc-python-command "python3")
  (setq python-shell-interpreter "python3")
  (add-hook 'elpy-mode-hook 'lsp)
;;  (add-hook 'elpy-mode-hook 'ligature-mode)
  )

;; Code formatting on save with black
(use-package blacken
  :init (add-hook 'elpy-mode-hook 'blacken-mode))

;;
;; ----------------RUST SETUP----------------
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
  ;; uncomment for less flashiness
  ;; (setq lsp-eldoc-hook nil)
  ;; (setq lsp-enable-symbol-highlighting nil)
  ;; (setq lsp-signature-auto-activate nil)

  ;; comment to disable rustfmt on save
  (setq rustic-format-on-save t)
  (add-hook 'rustic-mode-hook 'rk/rustic-mode-hook)
  (add-hook 'rust-mode-hook #'tree-sitter-mode)
  (setq lsp-rust-analyzer-server-command '("~/.cargo/bin/rust-analyzer")))

(defun rk/rustic-mode-hook ()
  ;; so that run C-c C-c C-r works without having to confirm, but don't try to
  ;; save rust buffers that are not file visiting. Once
  ;; https://github.com/brotzeit/rustic/issues/253 has been resolved this should
  ;; no longer be necessary.
  (when buffer-file-name
    (setq-local buffer-save-without-query t)))

(use-package lsp-mode
  :ensure
  :commands lsp
  :custom
  ;; what to use when checking on-save. "check" is default, I prefer clippy
  (lsp-rust-analyzer-cargo-watch-command "check")
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
  (lsp-ui-sideline--push-info nil)
  ;; Read docs with hover
  (lsp-ui-doc-enable t)
  (lsp-ui-doc-delay 2)
  (lsp-ui-doc-show-with-cursor t)
  (lsp-ui-doc-position 'at-point)
  ;; Show file directory when peeking definitions
  (lsp-ui-peek-show-directory t)
  ;; (define-key lsp-ui-doc-frame-mode-map (kbd "ESC") 'lsp-ui-doc-hide)
  :bind
  (:map lsp-mode-map
	([remap xref-find-definitions] . lsp-ui-peek-find-definitions)
	([remap xref-find-references] . lsp-ui-peek-find-references))
)

(use-package lsp-ivy :commands lsp-ivy-workspace-symbol)

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
;;; 
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("47d5324dac28a85c1bb84b4c1dc3a8dc407cc7369db6e30d3244b16232b1eec4" "e3daa8f18440301f3e54f2093fe15f4fe951986a8628e98dcd781efbec7a46f2" "545ab1a535c913c9214fe5b883046f02982c508815612234140240c129682a68" "0c83e0b50946e39e237769ad368a08f2cd1c854ccbcd1a01d39fdce4d6f86478" "5f128efd37c6a87cd4ad8e8b7f2afaba425425524a68133ac0efd87291d05874" "6945dadc749ac5cbd47012cad836f92aea9ebec9f504d32fe89a956260773ca4" "991ca4dbb23cab4f45c1463c187ac80de9e6a718edc8640003892a2523cb6259" "bf948e3f55a8cd1f420373410911d0a50be5a04a8886cabe8d8e471ad8fdba8e" "aec7b55f2a13307a55517fdf08438863d694550565dee23181d2ebd973ebd6b8" "512ce140ea9c1521ccaceaa0e73e2487e2d3826cc9d287275550b47c04072bc4" "da186cce19b5aed3f6a2316845583dbee76aea9255ea0da857d1c058ff003546" "47db50ff66e35d3a440485357fb6acb767c100e135ccdf459060407f8baea7b2" "c5ded9320a346146bbc2ead692f0c63be512747963257f18cc8518c5254b7bf5" "353ffc8e6b53a91ac87b7e86bebc6796877a0b76ddfc15793e4d7880976132ae" default))
 '(package-selected-packages
   '(diff-hl soothe-theme evil-nerd-commenter toml-mode tree-sitter-langs tree-sitter jupyter ein treemacs-all-the-icons company-jedi lsp-ivy lsp-ui lsp-mode rustic blacken elpy magit smooth-scrolling flycheck yasnippet-snippets yasnippet treemacs centaur-tabs org-bullets evil-org evil-collection pdf-tools evil-smartparens smartparens rainbow-mode rainbow-delimiters general doom-modeline counsel swiper doom-themes use-package))
 '(warning-suppress-types '((comp) (comp))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
